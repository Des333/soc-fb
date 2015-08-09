`include "lcd_regs.vh"

module csr_wrap(
  
  input                          clk_i, 
  input                          rst_i, 

  avalon_mm_sdram_if.slave       csr_amm_if,
  
  lcd_ctrl_if.master             lcd_ctrl_if

);


localparam CR_CNT  = `LCD_CR_CNT;
localparam SR_CNT  = `LCD_SR_CNT;


// Registers Data and Address width 
localparam DATA_W = 16;
localparam ADDR_W = 12;


avalon_mm_sdram_if #(
  .ADDR_WIDTH      ( ADDR_W ),
  .DATA_WIDTH      ( DATA_W )
) csr_amm_narrow_if( );

//***********************************************************
// Width adapter
//***********************************************************

avalon_width_adapter avalon_width_adapter_regs(
  .clk_i                                  ( clk_i                                   ),
  .rst_i                                  ( rst_i                                   ),

  // Wide IF
  .wide_writedata_i                       ( csr_amm_if.write_data                   ),
  .wide_byteenable_i                      ( csr_amm_if.byte_enable                  ),
  .wide_write_i                           ( csr_amm_if.write                        ),
  .wide_read_i                            ( csr_amm_if.read                         ),
  .wide_address_i                         ( csr_amm_if.address                      ),

  .wide_readdata_o                        ( csr_amm_if.read_data                    ),
  .wide_waitrequest_o                     ( csr_amm_if.wait_request                 ),
  .wide_datavalid_o                       ( csr_amm_if.read_data_val                ),


  // Narrow IF
  .narrow_writedata_o                     ( csr_amm_narrow_if.master.write_data     ),
  .narrow_byteenable_o                    ( csr_amm_narrow_if.master.byte_enable    ),
  .narrow_write_o                         ( csr_amm_narrow_if.master.write          ),
  .narrow_read_o                          ( csr_amm_narrow_if.master.read           ),
  .narrow_address_o                       ( csr_amm_narrow_if.master.address        ),

  .narrow_readdata_i                      ( csr_amm_narrow_if.master.read_data      ),
  .narrow_datavalid_i                     ( csr_amm_narrow_if.master.read_data_val  ),
  .narrow_waitrequest_i                   ( csr_amm_narrow_if.master.wait_request   )
);

// We count registers in items.
defparam avalon_width_adapter_regs.SLAVE_ADDR_IS_BYTE = 0;

// 64 / 16 = 4
defparam avalon_width_adapter_regs.WIDTH_RATIO    = 4;
defparam avalon_width_adapter_regs.NARROW_IF_BE_W = 2;
defparam avalon_width_adapter_regs.WIDE_IF_ADDR_W = 10;

//***********************************************************
// Control & Status Registers
//***********************************************************

logic [DATA_W-1:0] cregs_w [CR_CNT-1:0];
logic [DATA_W-1:0] sregs_w [SR_CNT-1:0];

regfile_with_be #(
  .CTRL_CNT                               ( CR_CNT                              ),
  .STAT_CNT                               ( SR_CNT                              ),
  .ADDR_W                                 ( ADDR_W                              ),
  .DATA_W                                 ( DATA_W                              ),
  .SEL_SR_BY_MSB                          ( 1                                   )
) regfile_with_be (
  .clk_i                                  ( clk_i                               ),
  .rst_i                                  ( 1'b0                                ),

  .data_i                                 ( csr_amm_narrow_if.slave.write_data  ),
  .wren_i                                 ( csr_amm_narrow_if.slave.write       ),
  .addr_i                                 ( csr_amm_narrow_if.slave.address     ),
  .be_i                                   ( csr_amm_narrow_if.slave.byte_enable ),
  .sreg_i                                 ( sregs_w                             ),
  .data_o                                 ( csr_amm_narrow_if.slave.read_data   ),
  .creg_o                                 ( cregs_w                             )
);

// Reading from registers have 0 cycles delay
assign csr_amm_narrow_if.slave.read_data_val = csr_amm_narrow_if.slave.read;

// This iface never blocks
assign csr_amm_narrow_if.slave.wait_request = 1'b0;


assign lcd_ctrl_if.data = cregs_w[`LCD_DATA_CR];
assign lcd_ctrl_if.rd   = cregs_w[`LCD_CTRL_CR][`LCD_CTRL_CR_RD];
assign lcd_ctrl_if.wr   = cregs_w[`LCD_CTRL_CR][`LCD_CTRL_CR_WR];
assign lcd_ctrl_if.rs   = cregs_w[`LCD_CTRL_CR][`LCD_CTRL_CR_RS];

assign lcd_ctrl_if.dma_addr = { cregs_w[`LCD_DMA_ADDR_CR1], cregs_w[`LCD_DMA_ADDR_CR0] };


sedge_sel_sv redraw_stb(
  .Clk                                    ( clk_i                                        ),
  .ain                                    ( cregs_w[`LCD_DMA_CR][`LCD_DMA_CR_REDRAW_STB] ),
  .edg                                    ( lcd_ctrl_if.redraw_stb                       )
);

assign lcd_ctrl_if.fps_delay = cregs_w[`LCD_FPS_DELAY_CR];

assign lcd_ctrl_if.redraw_en = cregs_w[`LCD_DMA_CR][`LCD_DMA_CR_REDRAW_EN];

assign sregs_w[`LCD_VER_SR] = `LCD_VER;

assign sregs_w[`LCD_DMA_SR][`LCD_DMA_SR_BUSY] = lcd_ctrl_if.dma_busy;


endmodule
