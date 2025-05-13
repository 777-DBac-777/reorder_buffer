`timescale 1ns / 1ps

module reorder_buffer #(
  parameter DATA_WIDTH = 8
)(
  input  logic                    clk,
  input  logic                    rst_n,
  //AR slave interface
  input  logic            [3:0]   s_arid_i,
  input  logic                    s_arvalid_i,
  output logic                    s_arready_o,
  //R slave interface
  output logic [DATA_WIDTH-1:0]   s_rdata_o,
  output logic            [3:0]   s_rid_o,
  output logic                    s_rvalid_o,
  input  logic                    s_rready_i,
  //AR master interface
  output logic            [3:0]   m_arid_o,
  output logic                    m_arvalid_o,
  input  logic                    m_arready_i,
  //R master interface
  input  logic [DATA_WIDTH-1:0]   m_rdata_i,
  input  logic            [3:0]   m_rid_i,
  input  logic                    m_rvalid_i,
  output logic                    m_rready_o
);

  logic                  empty;
  logic [3:0]            current_id;
  logic [DATA_WIDTH-1:0] current_data;
  logic                  valid_data, valid_id_and_data;
  logic                  r_hand_shake, ar_hand_shake;

  fifo FIFO(
    .clk_i    ( clk ),
    .resetn_i ( rst_n ),

    .push_i   ( ar_hand_shake ),
    .data_i   ( s_arid_i ),
    .full_o   (  ),

    .pop_i    ( r_hand_shake ),
    .data_o   ( current_id ),
    .empty_o  ( empty )
  );

  memory #(
    .DATA_WIDTH ( DATA_WIDTH )
  ) MEM (
    .clk_i    ( clk ),
    .resetn_i ( rst_n ),

    .waddr_i  ( m_rid_i ),
    .wr_i     ( m_rvalid_i ),
    .data_i   ( m_rdata_i ),

    .raddr_i  ( current_id ),
    .rd_i     ( r_hand_shake ),
    .data_o   ( current_data ),
    .valid_o  ( valid_data )
  );

  assign m_arid_o          = s_arid_i;
  assign m_arvalid_o       = s_arvalid_i;
  assign s_arready_o       = m_arready_i;
  assign ar_hand_shake     = s_arvalid_i && m_arready_i;

  assign m_rready_o        = 1'b1;

  assign s_rid_o           = current_id;
  assign s_rdata_o         = current_data;
  assign valid_id_and_data = !empty && valid_data;
  assign s_rvalid_o        = valid_id_and_data;
  assign r_hand_shake      = valid_id_and_data && s_rready_i;

endmodule
