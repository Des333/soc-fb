interface lcd_bus_if #( 
  parameter DATA_W = 16
) (

);

logic [DATA_W-1:0] data;
logic              rd;
logic              wr;
logic              rs;


modport slave(
  input  data,
  input  rd,
  input  wr,
  input  rs
);


modport master(
  output data,
  output rd,
  output wr,
  output rs
);


endinterface

