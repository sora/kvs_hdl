`default_nettype none

`timescale 1ps / 1ps
`define SIMULATION

module tb_top;

//------------------------------------------------------------------
// Clocks
//------------------------------------------------------------------

// verilator lint_save
// verilator lint_off STMTDLY
reg sys_clk;
initial sys_clk = 1'b0;
always #8 sys_clk = ~sys_clk;

// 125MHz RX clock
reg phy_rx_clk;
initial phy_rx_clk = 1'b0;
always #8 phy_rx_clk = ~phy_rx_clk;

// 125MHz TX clock
reg phy_tx_clk;
initial phy_tx_clk = 1'b0;
always #8 phy_tx_clk = ~phy_tx_clk;
// verilator lint_restore


//------------------------------------------------------------------
// testbench
//------------------------------------------------------------------
reg sys_rst;
reg rx_dv;
reg [7:0] rxd;

kvs kvs_ins (
  // system
    .sys_rst(sys_rst)

  // Ethernet PHY
  , .gtx_clk(phy_tx_clk)
  , .tx_en()
  , .txd()
  , .rx_clk(phy_rx_clk)
  , .rx_dv(rx_dv)
  , .rxd(rxd)

  // LED
  , .led()

  // memory
  , .mem_dataA()
  , .mem_dataB()
  , .mem_addressA()
  , .mem_addressB()
  , .mem_wr_enA()
  , .mem_wr_enB()
  , .mem_qA()
  , .mem_qB()

  , .led()
);


//------------------------------------------------------------------
// a clock
//------------------------------------------------------------------
task waitclock;
begin
  @(posedge sys_clk);
  #1;
end
endtask


//------------------------------------------------------------------
// scinario
//------------------------------------------------------------------
reg [8:0] rom [0:1024];
reg [11:0] counter = 12'b0;

always @(posedge phy_rx_clk) begin
  { rx_dv, rxd } <= rom[counter];
  counter        <= counter + 1;
//  $display("rx_dv: %x, rxd: %x", rx_dv, rxd);
end

initial begin
  $dumpfile("./test.vcd");
  $dumpvars(0, tb_top);
  $readmemh("request.hex", rom);
  sys_rst = 1'b1;
  counter = 0;

  waitclock;
  waitclock;

  sys_rst = 1'b0;

  waitclock;

  // verilator lint_off STMTDLY
  #10000;
  $finish;
end

endmodule

`default_nettype wire

