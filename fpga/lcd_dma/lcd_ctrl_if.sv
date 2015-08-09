interface lcd_ctrl_if #( 
  parameter DATA_W = 16
) (

);

logic [DATA_W-1:0] data;
logic              rd;
logic              wr;
logic              rs;

logic [15:0]       fps_delay;

logic              redraw_stb;
logic              redraw_en;

logic [31:0]       dma_addr;
logic              dma_busy;


modport slave(
  input  data,
  input  rd,
  input  wr,
  input  rs,

  input  fps_delay,

  input  redraw_stb,
  input  redraw_en,

  input  dma_addr,

  output dma_busy
);


modport master(
  output data,
  output rd,
  output wr,
  output rs,

  output fps_delay,

  output redraw_stb,
  output redraw_en,

  output dma_addr,

  input  dma_busy
);


endinterface

