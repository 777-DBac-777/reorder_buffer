`timescale 1ns / 1ps

module memory #(
  parameter DATA_WIDTH = 8
)(
  input  logic                  clk_i,
  input  logic                  resetn_i,

  input  logic [3:0]            waddr_i,
  input  logic                  wr_i,
  input  logic [DATA_WIDTH-1:0] data_i,

  input  logic [3:0]            raddr_i,
  input  logic                  rd_i,
  output logic [DATA_WIDTH-1:0] data_o,
  output logic                  valid_o
);

  logic [15:0] valid;
  logic [15:0] next_valid;
  logic [DATA_WIDTH-1:0] mem [15:0];

  always @( posedge clk_i )
    if( !resetn_i )
      valid <= '0;
    else
      valid <= next_valid;

  always_comb
    begin
      next_valid = valid;
      if( rd_i )
        next_valid = next_valid ^ ( 16'b1 << raddr_i );
      if( wr_i )
        next_valid = next_valid | ( 16'b1 << waddr_i );
    end

  always @( posedge clk_i )
    if( wr_i )
      mem[waddr_i] <= data_i;

  assign data_o  = mem[raddr_i];
  assign valid_o = valid[raddr_i];

endmodule
