`timescale 1ns / 1ps

module fifo(
  input  logic       clk_i,
  input  logic       resetn_i,

  input  logic       push_i,
  input  logic [3:0] data_i,
  output logic       full_o,

  input  logic       pop_i,
  output logic [3:0] data_o,
  output logic       empty_o
);

  logic [4:0] write;
  logic [4:0] read;
  logic [4:0] next_write;
  logic [4:0] next_read;
  logic empty, full;

  assign empty_o = empty;
  assign full_o  = full;

  logic [3:0] mem [15:0];
  logic [3:0] next_mem [15:0];

  always @( posedge clk_i )
    mem <= next_mem;

  always @( posedge clk_i )
    if( !resetn_i )
      begin
        write <= '0;
        read  <= '0;
      end
    else
      begin
        write <= next_write;
        read  <= next_read;
      end

  always_comb
    begin
      full  = ( write == {!read[4], read[3:0]} );
      empty = ( write == read );
    end

  always_comb
    begin
      next_write = write;
      next_read  = read;
      next_mem   = mem;

      if( push_i && !full )
        begin
          next_mem[write[3:0]] = data_i;
          next_write = write + 1;
        end

      if( pop_i && !empty )
        begin
          next_read = read + 1;
        end
    end

  assign data_o = mem[read[3:0]];

endmodule
