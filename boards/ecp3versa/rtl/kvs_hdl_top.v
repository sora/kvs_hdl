`default_nettype none

module top (
  // system interface
    input  wire clock
  , input  wire reset_n

  // Ethernet PHY#1 interface
  , output wire phy1_rst_n
  , input  wire phy1_125M_clk
  , input  wire phy1_tx_clk
  , output wire phy1_gtx_clk
  , output wire phy1_tx_en
  , output wire [7:0] phy1_tx_data
  , input  wire phy1_rx_clk
  , input  wire phy1_rx_dv
  , input  wire [7:0] phy1_rx_data

  // LED
  , output wire [7:0] led
);

wire sys_rst = ~reset_n;
assign phy1_gtx_clk = phy1_125M_clk;

//------------------------------------------------------------------
// PHY cold reset (10 ms)
//------------------------------------------------------------------
reg [19:0] coldsys_rst = 0;
wire coldsys_rst10ms = (coldsys_rst == 20'h100000);
always @(posedge clock)
  coldsys_rst <= !coldsys_rst10ms ? coldsys_rst + 20'h1 : 20'h100000;
assign phy1_rst_n = coldsys_rst10ms;


//------------------------------------------------------------------
// memory (A: write, B: read)
//------------------------------------------------------------------
wire [ 7:0] mem_dataA;
wire [ 7:0] mem_dataB;
wire [16:0] mem_addressA;
wire [16:0] mem_addressB;
wire        mem_wr_enA;
wire        mem_wr_enB;
wire [ 7:0] mem_qA;
wire [ 7:0] mem_qB;
ram_dp_true memory_ins (
    .DataInA(mem_dataA)
  , .DataInB(mem_dataB)
  , .AddressA(mem_addressA)
  , .AddressB(mem_addressB)
  , .ClockA(phy1_rx_clk)
  , .ClockB(phy1_gtx_clk)
  , .ClockEnA(sys_rst)
  , .ClockEnB(sys_rst)
  , .WrA(mem_wr_enA)
  , .WrB(mem_wr_enB)
  , .ResetA(sys_rst)
  , .ResetB(sys_rst)
  , .QA(mem_qA)
  , .QB(mem_qB)
);


//------------------------------------------------------------------
// system logic
//------------------------------------------------------------------
kvs kvs_ins (
  // system
    .sys_rst(sys_rst)

  // Ethernet PHY
  , .gtx_clk(phy1_125M_clk)
  , .tx_en(phy1_tx_en)
  , .txd(phy1_tx_data)
  , .rx_clk(phy1_rx_clk)
  , .rx_dv(phy1_rx_dv)
  , .rxd(phy1_rx_data)

  // LED
  , .led(led)

  // memory
  , .mem_dataA(mem_dataA)
  , .mem_dataB(mem_dataB)
  , .mem_addressA(mem_addressA)
  , .mem_addressB(mem_addressB)
  , .mem_wr_enA(mem_wr_enA)
  , .mem_wr_enB(mem_wr_enB)
  , .mem_qA(mem_qA)
  , .mem_qB(mem_qB)
);


endmodule

`default_nettype wire

