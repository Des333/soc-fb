interface avalon_mm_sdram_if #(
  parameter ADDR_WIDTH        = 32,
  parameter DATA_WIDTH        = 64,
  parameter BURST_COUNT_WIDTH = 8,
  parameter BYTE_ENABLE_WIDTH = DATA_WIDTH/8
) ( 
);

logic [ADDR_WIDTH-1:0]         address;
logic [BYTE_ENABLE_WIDTH-1:0]  byte_enable;
logic [BURST_COUNT_WIDTH-1:0]  burst_count;

logic                          wait_request;

logic [DATA_WIDTH-1:0]         write_data;
logic                          write;


logic [DATA_WIDTH-1:0]         read_data;
logic                          read;
logic                          read_data_val;

modport master(
  output  address,
          burst_count,
          write_data,
          byte_enable,
          write,
          read,

  input   wait_request,
          read_data,
          read_data_val

);


modport slave(
  input   address,
          burst_count,
          write_data,
          byte_enable,
          write,
          read,

  output  wait_request,
          read_data,
          read_data_val

);

endinterface
