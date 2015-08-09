module top(
                output   [15:0]    lcd_data_o,
                output             lcd_rd_o,
                output             lcd_wr_o,
                output             lcd_rs_o,

                input              clk_25m_i,
                output             pwm_lcd_o,

		output wire [14:0] memory_mem_a,                   
		output wire [2:0]  memory_mem_ba,                  
		output wire        memory_mem_ck,                  
		output wire        memory_mem_ck_n,                
		output wire        memory_mem_cke,                 
		output wire        memory_mem_cs_n,                
		output wire        memory_mem_ras_n,               
		output wire        memory_mem_cas_n,               
		output wire        memory_mem_we_n,                
		output wire        memory_mem_reset_n,             
		inout  wire [31:0] memory_mem_dq,                  
		inout  wire [3:0]  memory_mem_dqs,                 
		inout  wire [3:0]  memory_mem_dqs_n,               
		output wire        memory_mem_odt,                 
		output wire [3:0]  memory_mem_dm,                  
		input  wire        memory_oct_rzqin,    

		output wire        hps_io_hps_io_emac1_inst_TX_CLK,     
		output wire        hps_io_hps_io_emac1_inst_TXD0,       
		output wire        hps_io_hps_io_emac1_inst_TXD1,       
		output wire        hps_io_hps_io_emac1_inst_TXD2,       
		output wire        hps_io_hps_io_emac1_inst_TXD3,       
		input  wire        hps_io_hps_io_emac1_inst_RXD0,       
		inout  wire        hps_io_hps_io_emac1_inst_MDIO,       
		output wire        hps_io_hps_io_emac1_inst_MDC,        
		input  wire        hps_io_hps_io_emac1_inst_RX_CTL,     
		output wire        hps_io_hps_io_emac1_inst_TX_CTL,     
		input  wire        hps_io_hps_io_emac1_inst_RX_CLK,     
		input  wire        hps_io_hps_io_emac1_inst_RXD1,       
		input  wire        hps_io_hps_io_emac1_inst_RXD2,       
		input  wire        hps_io_hps_io_emac1_inst_RXD3,       
		inout  wire        hps_io_hps_io_qspi_inst_IO0,         
		inout  wire        hps_io_hps_io_qspi_inst_IO1,         
		inout  wire        hps_io_hps_io_qspi_inst_IO2,         
		inout  wire        hps_io_hps_io_qspi_inst_IO3,         
		output wire        hps_io_hps_io_qspi_inst_SS0,         
		output wire        hps_io_hps_io_qspi_inst_CLK,         
		inout  wire        hps_io_hps_io_sdio_inst_CMD,         
		inout  wire        hps_io_hps_io_sdio_inst_D0,          
		inout  wire        hps_io_hps_io_sdio_inst_D1,          
		output wire        hps_io_hps_io_sdio_inst_CLK,         
		inout  wire        hps_io_hps_io_sdio_inst_D2,          
		inout  wire        hps_io_hps_io_sdio_inst_D3,          
		inout  wire        hps_io_hps_io_usb1_inst_D0,          
		inout  wire        hps_io_hps_io_usb1_inst_D1,          
		inout  wire        hps_io_hps_io_usb1_inst_D2,          
		inout  wire        hps_io_hps_io_usb1_inst_D3,          
		inout  wire        hps_io_hps_io_usb1_inst_D4,          
		inout  wire        hps_io_hps_io_usb1_inst_D5,          
		inout  wire        hps_io_hps_io_usb1_inst_D6,          
		inout  wire        hps_io_hps_io_usb1_inst_D7,          
		input  wire        hps_io_hps_io_usb1_inst_CLK,         
		output wire        hps_io_hps_io_usb1_inst_STP,         
		input  wire        hps_io_hps_io_usb1_inst_DIR,         
		input  wire        hps_io_hps_io_usb1_inst_NXT,         
		output wire        hps_io_hps_io_spim0_inst_CLK,        
		output wire        hps_io_hps_io_spim0_inst_MOSI,       
		input  wire        hps_io_hps_io_spim0_inst_MISO,       
		output wire        hps_io_hps_io_spim0_inst_SS0,        
		input  wire        hps_io_hps_io_uart0_inst_RX,         
		output wire        hps_io_hps_io_uart0_inst_TX,         
		inout  wire        hps_io_hps_io_i2c0_inst_SDA,         
		inout  wire        hps_io_hps_io_i2c0_inst_SCL,         
		inout  wire        hps_io_hps_io_i2c1_inst_SDA,         
		inout  wire        hps_io_hps_io_i2c1_inst_SCL,         
		inout  wire        hps_io_hps_io_gpio_inst_GPIO09,      
		inout  wire        hps_io_hps_io_gpio_inst_GPIO28,      
		inout  wire        hps_io_hps_io_gpio_inst_GPIO44,      
		inout  wire        hps_io_hps_io_gpio_inst_GPIO48,      
		inout  wire        hps_io_hps_io_gpio_inst_GPIO49,      
		inout  wire        hps_io_hps_io_gpio_inst_GPIO50,      
		inout  wire        hps_io_hps_io_gpio_inst_GPIO53,      
		inout  wire        hps_io_hps_io_gpio_inst_GPIO54,      
		inout  wire        hps_io_hps_io_gpio_inst_GPIO65
);




localparam SDRAM_DATA_W = 64;
localparam SDRAM_ADDR_W = 32;


avalon_mm_sdram_if #(
  .ADDR_WIDTH      ( SDRAM_ADDR_W ),
  .DATA_WIDTH      ( SDRAM_DATA_W )
) sdram_if( );


// Control/Status register
avalon_mm_sdram_if #(
  .ADDR_WIDTH      ( 10 ),
  .DATA_WIDTH      ( 64 )
) csr_amm_if( );


soc soc (
  .memory_mem_a                           ( memory_mem_a                          ),
  .memory_mem_ba                          ( memory_mem_ba                         ),
  .memory_mem_ck                          ( memory_mem_ck                         ),
  .memory_mem_ck_n                        ( memory_mem_ck_n                       ),
  .memory_mem_cke                         ( memory_mem_cke                        ),
  .memory_mem_cs_n                        ( memory_mem_cs_n                       ),
  .memory_mem_ras_n                       ( memory_mem_ras_n                      ),
  .memory_mem_cas_n                       ( memory_mem_cas_n                      ),
  .memory_mem_we_n                        ( memory_mem_we_n                       ),
  .memory_mem_reset_n                     ( memory_mem_reset_n                    ),
  .memory_mem_dq                          ( memory_mem_dq                         ),
  .memory_mem_dqs                         ( memory_mem_dqs                        ),
  .memory_mem_dqs_n                       ( memory_mem_dqs_n                      ),
  .memory_mem_odt                         ( memory_mem_odt                        ),
  .memory_mem_dm                          ( memory_mem_dm                         ),
  .memory_oct_rzqin                       ( memory_oct_rzqin                      ),

  .hps_io_hps_io_emac1_inst_TX_CLK        ( hps_io_hps_io_emac1_inst_TX_CLK       ),
  .hps_io_hps_io_emac1_inst_TXD0          ( hps_io_hps_io_emac1_inst_TXD0         ),
  .hps_io_hps_io_emac1_inst_TXD1          ( hps_io_hps_io_emac1_inst_TXD1         ),
  .hps_io_hps_io_emac1_inst_TXD2          ( hps_io_hps_io_emac1_inst_TXD2         ),
  .hps_io_hps_io_emac1_inst_TXD3          ( hps_io_hps_io_emac1_inst_TXD3         ),
  .hps_io_hps_io_emac1_inst_RXD0          ( hps_io_hps_io_emac1_inst_RXD0         ),
  .hps_io_hps_io_emac1_inst_MDIO          ( hps_io_hps_io_emac1_inst_MDIO         ),
  .hps_io_hps_io_emac1_inst_MDC           ( hps_io_hps_io_emac1_inst_MDC          ),
  .hps_io_hps_io_emac1_inst_RX_CTL        ( hps_io_hps_io_emac1_inst_RX_CTL       ),
  .hps_io_hps_io_emac1_inst_TX_CTL        ( hps_io_hps_io_emac1_inst_TX_CTL       ),
  .hps_io_hps_io_emac1_inst_RX_CLK        ( hps_io_hps_io_emac1_inst_RX_CLK       ),
  .hps_io_hps_io_emac1_inst_RXD1          ( hps_io_hps_io_emac1_inst_RXD1         ),
  .hps_io_hps_io_emac1_inst_RXD2          ( hps_io_hps_io_emac1_inst_RXD2         ),
  .hps_io_hps_io_emac1_inst_RXD3          ( hps_io_hps_io_emac1_inst_RXD3         ),
  .hps_io_hps_io_qspi_inst_IO0            ( hps_io_hps_io_qspi_inst_IO0           ),
  .hps_io_hps_io_qspi_inst_IO1            ( hps_io_hps_io_qspi_inst_IO1           ),
  .hps_io_hps_io_qspi_inst_IO2            ( hps_io_hps_io_qspi_inst_IO2           ),
  .hps_io_hps_io_qspi_inst_IO3            ( hps_io_hps_io_qspi_inst_IO3           ),
  .hps_io_hps_io_qspi_inst_SS0            ( hps_io_hps_io_qspi_inst_SS0           ),
  .hps_io_hps_io_qspi_inst_CLK            ( hps_io_hps_io_qspi_inst_CLK           ),
  .hps_io_hps_io_sdio_inst_CMD            ( hps_io_hps_io_sdio_inst_CMD           ),
  .hps_io_hps_io_sdio_inst_D0             ( hps_io_hps_io_sdio_inst_D0            ),
  .hps_io_hps_io_sdio_inst_D1             ( hps_io_hps_io_sdio_inst_D1            ),
  .hps_io_hps_io_sdio_inst_CLK            ( hps_io_hps_io_sdio_inst_CLK           ),
  .hps_io_hps_io_sdio_inst_D2             ( hps_io_hps_io_sdio_inst_D2            ),
  .hps_io_hps_io_sdio_inst_D3             ( hps_io_hps_io_sdio_inst_D3            ),
  .hps_io_hps_io_usb1_inst_D0             ( hps_io_hps_io_usb1_inst_D0            ),
  .hps_io_hps_io_usb1_inst_D1             ( hps_io_hps_io_usb1_inst_D1            ),
  .hps_io_hps_io_usb1_inst_D2             ( hps_io_hps_io_usb1_inst_D2            ),
  .hps_io_hps_io_usb1_inst_D3             ( hps_io_hps_io_usb1_inst_D3            ),
  .hps_io_hps_io_usb1_inst_D4             ( hps_io_hps_io_usb1_inst_D4            ),
  .hps_io_hps_io_usb1_inst_D5             ( hps_io_hps_io_usb1_inst_D5            ),
  .hps_io_hps_io_usb1_inst_D6             ( hps_io_hps_io_usb1_inst_D6            ),
  .hps_io_hps_io_usb1_inst_D7             ( hps_io_hps_io_usb1_inst_D7            ),
  .hps_io_hps_io_usb1_inst_CLK            ( hps_io_hps_io_usb1_inst_CLK           ),
  .hps_io_hps_io_usb1_inst_STP            ( hps_io_hps_io_usb1_inst_STP           ),
  .hps_io_hps_io_usb1_inst_DIR            ( hps_io_hps_io_usb1_inst_DIR           ),
  .hps_io_hps_io_usb1_inst_NXT            ( hps_io_hps_io_usb1_inst_NXT           ),
  .hps_io_hps_io_spim0_inst_CLK           ( hps_io_hps_io_spim0_inst_CLK          ),
  .hps_io_hps_io_spim0_inst_MOSI          ( hps_io_hps_io_spim0_inst_MOSI         ),
  .hps_io_hps_io_spim0_inst_MISO          ( hps_io_hps_io_spim0_inst_MISO         ),
  .hps_io_hps_io_spim0_inst_SS0           ( hps_io_hps_io_spim0_inst_SS0          ),
  .hps_io_hps_io_uart0_inst_RX            ( hps_io_hps_io_uart0_inst_RX           ),
  .hps_io_hps_io_uart0_inst_TX            ( hps_io_hps_io_uart0_inst_TX           ),
  .hps_io_hps_io_i2c0_inst_SDA            ( hps_io_hps_io_i2c0_inst_SDA           ),
  .hps_io_hps_io_i2c0_inst_SCL            ( hps_io_hps_io_i2c0_inst_SCL           ),
  .hps_io_hps_io_i2c1_inst_SDA            ( hps_io_hps_io_i2c1_inst_SDA           ),
  .hps_io_hps_io_i2c1_inst_SCL            ( hps_io_hps_io_i2c1_inst_SCL           ),
  .hps_io_hps_io_gpio_inst_GPIO09         ( hps_io_hps_io_gpio_inst_GPIO09        ),
  .hps_io_hps_io_gpio_inst_GPIO28         ( hps_io_hps_io_gpio_inst_GPIO28        ),
  .hps_io_hps_io_gpio_inst_GPIO44         ( hps_io_hps_io_gpio_inst_GPIO44        ),
  .hps_io_hps_io_gpio_inst_GPIO48         ( hps_io_hps_io_gpio_inst_GPIO48        ),
  .hps_io_hps_io_gpio_inst_GPIO49         ( hps_io_hps_io_gpio_inst_GPIO49        ),
  .hps_io_hps_io_gpio_inst_GPIO50         ( hps_io_hps_io_gpio_inst_GPIO50        ),
  .hps_io_hps_io_gpio_inst_GPIO53         ( hps_io_hps_io_gpio_inst_GPIO53        ),
  .hps_io_hps_io_gpio_inst_GPIO54         ( hps_io_hps_io_gpio_inst_GPIO54        ),
  .hps_io_hps_io_gpio_inst_GPIO65         ( hps_io_hps_io_gpio_inst_GPIO65        ),

  .reg_waitrequest                        ( csr_amm_if.master.wait_request        ),
  .reg_readdata                           ( csr_amm_if.master.read_data           ),
  .reg_readdatavalid                      ( csr_amm_if.master.read_data_val       ),
  .reg_burstcount                         ( csr_amm_if.master.burst_count         ),
  .reg_writedata                          ( csr_amm_if.master.write_data          ),
  .reg_address                            ( csr_amm_if.master.address             ),
  .reg_write                              ( csr_amm_if.master.write               ),
  .reg_read                               ( csr_amm_if.master.read                ),
  .reg_byteenable                         ( csr_amm_if.master.byte_enable         ),
  .reg_debugaccess                        (                                       ),

  .sdram0_data_address                    ( sdram_if.slave.address                ),
  .sdram0_data_burstcount                 ( sdram_if.slave.burst_count            ),
  .sdram0_data_waitrequest                ( sdram_if.slave.wait_request           ),
  .sdram0_data_writedata                  ( sdram_if.slave.write_data             ),
  .sdram0_data_byteenable                 ( sdram_if.slave.byte_enable            ),
  .sdram0_data_write                      ( sdram_if.slave.write                  ),
  .sdram0_data_readdata                   ( sdram_if.slave.read_data              ),
  .sdram0_data_readdatavalid              ( sdram_if.slave.read_data_val          ),
  .sdram0_data_read                       ( sdram_if.slave.read                   ),

  .clk_i_clk                              ( clk_sys                               )
);


//***********************************************************
// Clocks
//***********************************************************

logic  clk_sys;
logic  clk_125m;
logic  clk_62m5;

assign clk_sys   = clk_62m5;
assign pwm_lcd_o = clk_125m;  


pll_gbe pll_gbe(
  .refclk                                 ( clk_25m_i                         ),
  .rst                                    ( 1'b0                              ),
  .outclk_0                               ( clk_125m                          ),
  .outclk_1                               ( clk_62m5                          ),
  .locked                                 (                                   ),
  .reconfig_to_pll                        (                                   ),
  .reconfig_from_pll                      (                                   )
);


//***********************************************************
// CSR
//***********************************************************


localparam LCD_DATA_W = 16;

lcd_ctrl_if #( .DATA_W( LCD_DATA_W ) )  lcd_ctrl_if ( );

csr_wrap csr_wrap(
  .clk_i                                  ( clk_sys                           ),
  .rst_i                                  (                                   ),
   
  .csr_amm_if                             ( csr_amm_if.slave                  ),

  .lcd_ctrl_if                            ( lcd_ctrl_if.master                )
);    


// *********************************************************
// LCD DMA support (used in out framebuffer implementation)
// *********************************************************

lcd_bus_if #( .DATA_W( LCD_DATA_W ) )  lcd_bus_if ( );

lcd_dma #(
  .AMM_DATA_W                             ( SDRAM_DATA_W                      ),
  .CLK_FREQ                               ( 62_500_000                        ),
  .USE_WORD_ADDRESS                       ( 1                                 )
  
) lcd_dma (
  .clk_i                                  ( clk_sys                           ),

  .amm_if                                 ( sdram_if.master                   ),

  .lcd_ctrl_if                            ( lcd_ctrl_if.slave                 ),

  .lcd_bus_if                             ( lcd_bus_if.master                 )
);

assign lcd_data_o = lcd_bus_if.slave.data;
assign lcd_rd_o   = lcd_bus_if.slave.rd;
assign lcd_wr_o   = lcd_bus_if.slave.wr;
assign lcd_rs_o   = lcd_bus_if.slave.rs;



endmodule
