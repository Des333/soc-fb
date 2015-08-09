
// This module allow read data from Framebuffer with DMA
// (use fpga2sdram or fpga2hps interfaces)
// and send frames to ILI9341 LCD


module lcd_dma #(
  // Default width is 64 bit for fpga2sdram interface in ETN
  parameter AMM_DATA_W = 64,

  // Default clock for ETN is 62.5 MHz
  parameter CLK_FREQ = 62_500_000,
  
  // fpga2sdram use word address,
  // fpga2hps use byte address
  parameter USE_WORD_ADDRESS = 1
) ( 

  input clk_i,

  // fpga2sdram (or fpga2hps) Avalon-MM interface.
  // FPGA is master
  avalon_mm_sdram_if.master      amm_if,

  // LCD control from CPU 
  lcd_ctrl_if.slave              lcd_ctrl_if,

  // Physical interface to ILI9341 LCD
  lcd_bus_if.master              lcd_bus_if
);

// 320 -- LCD width resolution
// 240 -- LCD height resolution
localparam BIT_FOR_PIXEL = 16;
localparam WORD_IN_FRAME = 320 * 240 / ( AMM_DATA_W / BIT_FOR_PIXEL );


// Delay in ms, 40 ms is 25 FPS
localparam DEFAULT_FPS_DELAY_MS = 40;
localparam TICKS_FOR_1MS = CLK_FREQ / 1000;


// Fifo for burst compensation
localparam FIFO_AWIDTH = 10;


logic                    fifo_wr_req;

logic                    fifo_rd_req;

logic                    fifo_empty;
logic [FIFO_AWIDTH-1:0]  fifo_usedw;

logic [AMM_DATA_W-1:0]   fifo_wr_data;
logic [AMM_DATA_W-1:0]   fifo_rd_data;


// Count of read transactions in progress
logic [FIFO_AWIDTH-1:0]  pending_read_cnt;


buf_fifo #( 
  .AWIDTH                                 ( FIFO_AWIDTH       ),
  .DWIDTH                                 ( AMM_DATA_W        )
) buf_fifo (
  .clock                                  ( clk_i             ),
  .aclr                                   (                   ),

  .wrreq                                  ( fifo_wr_req       ),
  .data                                   ( fifo_wr_data      ),

  .rdreq                                  ( fifo_rd_req       ),
  .q                                      ( fifo_rd_data      ),

  .almost_full                            (                   ),
  .full                                   (                   ),
  .empty                                  ( fifo_empty        ),
  .usedw                                  ( fifo_usedw        )
);


assign fifo_wr_req  = amm_if.read_data_val;
assign fifo_wr_data = amm_if.read_data;


logic read_req_w;
assign read_req_w = amm_if.read && !amm_if.wait_request;


always_ff @( posedge clk_i )
  case( { read_req_w, amm_if.read_data_val } )
    2'b01:
      pending_read_cnt <= pending_read_cnt - 1'd1;
    
    2'b10:
      pending_read_cnt <= pending_read_cnt + 1'd1;
  endcase


logic [31:0] word_cnt;

always_ff @( posedge clk_i )
  if( state == IDLE_S )
    word_cnt <= '0;
  else
    if( read_req_w ) 
      word_cnt <= word_cnt + 1'd1;


logic reading_is_finished;
assign reading_is_finished = ( word_cnt == WORD_IN_FRAME - 1 ) && read_req_w;


logic stop_reading;
assign stop_reading = ( pending_read_cnt + fifo_usedw ) > ( 2**FIFO_AWIDTH - 'd50 );


logic all_is_finished;
assign all_is_finished = ( pending_read_cnt == 0          ) && 
                         ( fifo_usedw       == 0          ) && 
                         ( lcd_state        == LCD_IDLE_S ); 


logic clear_delay_cnt_w;
logic fps_delay_done_w;
logic [15:0] fps_delay;

logic [16:0] takt_cnt;
logic [15:0] ms_cnt;

assign clear_delay_cnt_w = ( state == FPS_DELAY_S ) && ( next_state != FPS_DELAY_S );


always_ff @( posedge clk_i )
  if( clear_delay_cnt_w )
    takt_cnt <= '0;
  else
    if( takt_cnt == TICKS_FOR_1MS - 1 )
      takt_cnt <= '0;
    else 
      takt_cnt <= takt_cnt + 1'd1;


always_ff @( posedge clk_i )
  if( clear_delay_cnt_w ) 
    ms_cnt <= '0;
  else
    if( takt_cnt == TICKS_FOR_1MS - 1 )
      ms_cnt <= ms_cnt + 1'd1;
      

// Use default, if CPU does not set delay
assign fps_delay = ( lcd_ctrl_if.fps_delay == 'd0 ) ? DEFAULT_FPS_DELAY_MS : lcd_ctrl_if.fps_delay;

assign fps_delay_done_w = ( ms_cnt >= fps_delay );


enum int unsigned {
  IDLE_S,
  FPS_DELAY_S,
  READ_S,
  WAIT_READIND_S,
  WAIT_WRITING_S
} state, next_state;

always_ff @( posedge clk_i )
  state <= next_state;

// FIXME:
//   If lcd_ctrl_if.redraw_en == 1
//   CPU have one takt for read 0 in lcd_ctrl_if.dma_busy
//   Fix: add WAIT_WRITING_S -> FPS_DELAY_S path
always_comb
  begin
    next_state = state;

    case( state )
      IDLE_S:
        begin
          if( lcd_ctrl_if.redraw_stb || lcd_ctrl_if.redraw_en ) 
            next_state = FPS_DELAY_S;
        end   

      FPS_DELAY_S:
        begin
          if( fps_delay_done_w )
            next_state = READ_S;
        end
    
      READ_S:
        begin
          if( reading_is_finished ) 
            next_state = WAIT_WRITING_S;
          else 
            if( stop_reading ) 
              next_state = WAIT_READIND_S;
        end

      WAIT_READIND_S:
        begin
          if( !stop_reading ) 
            next_state = READ_S;
        end
      
      WAIT_WRITING_S:
        begin
          if( all_is_finished ) 
            next_state = IDLE_S;
        end
    endcase
  end

assign lcd_ctrl_if.dma_busy = ( state != IDLE_S );


// fpga2sdram used word address, so we must added 1 every time, 
// fpga2hps used byte address, so we must added 8 (for 64-bit iface).
logic [31:0] addr_incr;
assign addr_incr = ( USE_WORD_ADDRESS == 1 ) ? 1 : ( AMM_DATA_W >> 3 );


always_ff @( posedge clk_i )
  if( state == IDLE_S )
    amm_if.address <= lcd_ctrl_if.dma_addr;
  else
    if( read_req_w ) 
      amm_if.address <= amm_if.address + addr_incr;

// Always read all bytes in word
assign amm_if.byte_enable = '1;

// We don't use burst now
assign amm_if.burst_count = 1;

assign amm_if.read = ( state == READ_S );


// Remove Quartus warnings
assign amm_if.write_data = '0;
assign amm_if.write      = 0;


//****************************************************************
// FSM for reading from FIFO
//****************************************************************

enum int unsigned {
  LCD_IDLE_S,
  LCD_WRITE_S
} lcd_state, lcd_next_state;

always_ff @( posedge clk_i )
  lcd_state <= lcd_next_state;

always_comb
  begin
    lcd_next_state = lcd_state;

    case( lcd_state )
      LCD_IDLE_S:
        begin
          if( !fifo_empty ) 
            lcd_next_state = LCD_WRITE_S;
        end

      LCD_WRITE_S:
        begin
          if( lcd_word_cnt == 5'd31 ) 
            lcd_next_state = LCD_IDLE_S;
        end
    endcase
  end

assign fifo_rd_req = ( lcd_state == LCD_IDLE_S ) && ( lcd_next_state == LCD_WRITE_S );




//****************************************************************
// Data Transaction
//****************************************************************

// ILI9341 Data transaction from FPGA:
//             __    __    __    __    __    __    __    __    __   
// clk/4 |  __|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |
//
// data  | ///<  split[0] |  split[1] |  split[2] |  split[3] >////
//
//             _______________________________________________
// rd    | xxxx                                               xxxx 
//
//                   _____       _____       _____       _____
// wr    | xxxx_____|     |_____|     |_____|     |_____|     xxxx 
//
//             _______________________________________________
// rs    | xxxx                                               xxxx 


logic [3:0][15:0] fifo_rd_data_split;
assign fifo_rd_data_split = fifo_rd_data;

logic [15:0] lcd_data_from_fpga;
logic        lcd_wr_from_fpga;

logic [4:0] lcd_word_cnt;

always_ff @( posedge clk_i )
  if( lcd_state == LCD_IDLE_S )
    lcd_word_cnt <= '0;
  else   
    lcd_word_cnt <= lcd_word_cnt + 1'd1;

assign lcd_data_from_fpga = fifo_rd_data_split[ lcd_word_cnt[4:3] ];
assign lcd_wr_from_fpga = ( lcd_state == LCD_IDLE_S ) ? 1'b1 : lcd_word_cnt[2];



//****************************************************************
// Form transactions on ILI9341 bus 
//****************************************************************

always_ff @( posedge clk_i )
  if( state == IDLE_S )
    begin
      lcd_bus_if.data <= lcd_ctrl_if.data;
      lcd_bus_if.rd   <= lcd_ctrl_if.rd;
      lcd_bus_if.wr   <= lcd_ctrl_if.wr;
      lcd_bus_if.rs   <= lcd_ctrl_if.rs;
    end
  else      
    // Send data transactions from FPGA.
    begin
      lcd_bus_if.data <= lcd_data_from_fpga;
      lcd_bus_if.rd   <= 1'b1;
      lcd_bus_if.wr   <= lcd_wr_from_fpga;
      lcd_bus_if.rs   <= 1'b1;
    end



endmodule
