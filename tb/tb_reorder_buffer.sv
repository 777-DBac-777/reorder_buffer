`timescale 1ns / 1ps

module tb_reorder_buffer;

  localparam DATA_WIDTH = 8;

  logic                    clk;
  logic                    rst_n;

  //AR slave interface
  logic                    s_arvalid_i;
  logic                    s_arready_o;
  logic            [3:0]   s_arid_i;
  //R slave interface
  logic                    s_rvalid_o;
  logic                    s_rready_i;
  logic [DATA_WIDTH-1:0]   s_rdata_o;
  logic            [3:0]   s_rid_o;
  //AR master interface
  logic                    m_arvalid_o;
  logic                    m_arready_i;
  logic            [3:0]   m_arid_o;
  //R master interface
  logic                    m_rvalid_i;
  logic                    m_rready_o;
  logic [DATA_WIDTH-1:0]   m_rdata_i;
  logic            [3:0]   m_rid_i;

  reorder_buffer #(
    .DATA_WIDTH ( DATA_WIDTH )
  ) DUT (
    .clk         ( clk ),
    .rst_n       ( rst_n ),

    .s_arid_i    ( s_arid_i ),
    .s_arvalid_i ( s_arvalid_i ),
    .s_arready_o ( s_arready_o ),

    .s_rdata_o   ( s_rdata_o ),
    .s_rid_o     ( s_rid_o ),
    .s_rvalid_o  ( s_rvalid_o ),
    .s_rready_i  ( s_rready_i ),

    .m_arid_o    ( m_arid_o ),
    .m_arvalid_o ( m_arvalid_o ),
    .m_arready_i ( m_arready_i ),

    .m_rdata_i   ( m_rdata_i ),
    .m_rid_i     ( m_rid_i ),
    .m_rvalid_i  ( m_rvalid_i ),
    .m_rready_o  ( m_rready_o )
  );

  logic [31:0] i;
  logic [31:0] errors;
  logic [39:0] testvector [1024];

  initial
    begin
      clk = 1;
      rst_n = 0;
      rst_n <= #11 1;
      forever #5 clk = ~clk;
    end

  initial
    begin
      $display("##########################################: START");
      $display("##########################################: EXAMLE");
      $readmemb("tv_example.txt", testvector);
      errors                           = '0;
      i                                = '0;
      {s_arvalid_i, s_arid_i}          = {testvector[0][39], testvector[0][37:34]};
      s_rready_i                       = testvector[0][32];
      m_arready_i                      = testvector[0][18];
      {m_rvalid_i, m_rdata_i, m_rid_i} = {testvector[0][13], testvector[0][11:0]};
      while( i != 16 ) @( posedge clk );
      $display("Errors: %d", errors);
      $display("##########################################: FULL ID STRAIGHT");
      $readmemb("tv_full_id_straight.txt", testvector);
      errors                           = '0;
      i                                = '0;
      {s_arvalid_i, s_arid_i}          = {testvector[0][39], testvector[0][37:34]};
      s_rready_i                       = testvector[0][32];
      m_arready_i                      = testvector[0][18];
      {m_rvalid_i, m_rdata_i, m_rid_i} = {testvector[0][13], testvector[0][11:0]};
      while( i != 22 ) @( posedge clk );
      $display("Errors: %d", errors);
      $display("##########################################: FULL ID BACK");
      $readmemb("tv_full_id_back.txt", testvector);
      errors                           = '0;
      i                                = '0;
      {s_arvalid_i, s_arid_i}          = {testvector[0][39], testvector[0][37:34]};
      s_rready_i                       = testvector[0][32];
      m_arready_i                      = testvector[0][18];
      {m_rvalid_i, m_rdata_i, m_rid_i} = {testvector[0][13], testvector[0][11:0]};
      while( i != 49 ) @( posedge clk );
      $display("Errors: %d", errors);
      $stop;
    end


  always @( posedge clk )
    if( rst_n )
      begin
          begin
            i <= i + 1;
            {s_arvalid_i, s_arid_i}          <= #1 {testvector[i][39], testvector[i][37:34]};
            s_rready_i                       <= #1 testvector[i][32];
            m_arready_i                      <= #1 testvector[i][18];
            {m_rvalid_i, m_rdata_i, m_rid_i} <= #1 {testvector[i][13], testvector[i][11:0]};
          end
      end

  // Finds mistake between the module and a test vector in slave read
  always @( posedge clk )
    if( rst_n )
      begin
        if( testvector[i-1][33] && testvector[i-1][32] )
          if( !(s_rdata_o == testvector[i-1][31:24] && s_rid_o == testvector[i-1][23:20] && s_rvalid_o == testvector[i-1][33] ) )
            begin
              errors = errors + 1;
              $display("Find mismatch: %d", $time);
              $display("%h, %h, %h, %h", s_rdata_o, testvector[i-1][31:24], s_rid_o, testvector[i-1][23:20]);
            end
      end

endmodule
