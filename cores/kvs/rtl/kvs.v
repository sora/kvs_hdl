`default_nettype none

/* Magic Byte */
`define  REQUEST        8'h80
`define  RESPONSE       8'h81

/* Command Opcodes */
`define  CMD_GET        8'h00
`define  CMD_SET        8'h01

module kvs #(
    parameter port = 16'd11211      // listen port number
)(
  // system
    input wire sys_rst

  // Ethernet PHY
  , input  wire       gtx_clk
  , output reg        tx_en
  , output reg  [7:0] txd
  , input  wire       rx_clk
  , input  wire       rx_dv
  , input  wire [7:0] rxd

  // LED
  , output wire [7:0] led

  // memory
  , output reg  [ 7:0] mem_dataA
  , output reg  [ 7:0] mem_dataB
  , output reg  [16:0] mem_addressA
  , output reg  [16:0] mem_addressB
  , output reg         mem_wr_enA
  , output reg         mem_wr_enB
  , input  wire [ 7:0] mem_qA
  , input  wire [ 7:0] mem_qB
);


//------------------------------------------------------------------
// RX counter (Clock: rx_clk)
//------------------------------------------------------------------
reg [10:0] rxcounter;
always @(posedge rx_clk) begin
  if (sys_rst)
    rxcounter <= 11'd0;
  else
    if (rx_dv)
      rxcounter <= rxcounter + 11'd1;
    else
      rxcounter <= 11'd0;
end


//------------------------------------------------------------------
// Receiver logic
//------------------------------------------------------------------
reg        memcache_dv;
reg [15:0] eth_type;
reg [15:0] ip_version;
reg [ 7:0] ipv4_proto;
reg [31:0] ipv4_src_ip;
reg [31:0] ipv4_dst_ip;
reg [15:0] tp_src_port;
reg [15:0] tp_dst_port;
always @(posedge rx_clk) begin
  if (sys_rst) begin
    eth_type    <= 16'h0;
    ip_version  <= 16'h0;
    ipv4_proto  <=  8'h0;
    ipv4_src_ip <= 32'h0;
    ipv4_dst_ip <= 32'h0;
    tp_src_port <= 16'h0;
    tp_dst_port <= 16'h0;
    memcache_dv <=  1'b0;
  end else begin
    if (rx_dv) begin
      case (rxcounter)
        11'h15: eth_type[15:8]      <= rxd;
        11'h16: eth_type[ 7:0]      <= rxd;
        11'h17: ip_version[15:8]    <= rxd;
        11'h18: ip_version[ 7:0]    <= rxd;
        11'h20: ipv4_proto[ 7:0]    <= rxd;
        11'h23: ipv4_src_ip[31:24]  <= rxd;
        11'h24: ipv4_src_ip[23:16]  <= rxd;
        11'h25: ipv4_src_ip[15: 8]  <= rxd;
        11'h26: ipv4_src_ip[ 7: 0]  <= rxd;
        11'h27: ipv4_dst_ip[31:24]  <= rxd;
        11'h28: ipv4_dst_ip[23:16]  <= rxd;
        11'h29: ipv4_dst_ip[15: 8]  <= rxd;
        11'h2a: ipv4_dst_ip[ 7: 0]  <= rxd;
        11'h2b: tp_src_port[15:8]   <= rxd;
        11'h2c: tp_src_port[ 7:0]   <= rxd;
        11'h2d: tp_dst_port[15:8]   <= rxd;
        11'h2e: tp_dst_port[ 7:0]   <= rxd;
        11'h32: begin
          if (eth_type[15:0]    == 16'h0800  && ip_version[15:0] == 16'h4500 &&
              tp_dst_port[15:0] == 16'd11211 && ipv4_proto[7:0]  == 8'h11) begin
            memcache_dv <= 1'b1;
          end
        end
      endcase
    end else begin
      eth_type       <= 16'h0;
      ip_version     <= 16'h0;
      ipv4_proto     <=  8'h0;
      ipv4_src_ip    <= 32'h0;
      ipv4_dst_ip    <= 32'h0;
      tp_src_port    <= 16'h0;
      tp_dst_port    <= 16'h0;
      memcache_dv    <=  1'b0;
    end
  end
end
assign led = rx_dv == 1'b1 ? 8'h0 : 8'hff; // light when received a packet

reg [10:0] memcache_counter;
always @(posedge rx_clk) begin
  if (sys_rst)
    memcache_counter <= 11'd0;
  else
    if (rx_dv && memcache_dv)
      memcache_counter <= memcache_counter + 11'd1;
    else
      memcache_counter <= 11'd0;
end

reg [7:0] memcache_magic;
reg [7:0] memcache_opcode;
always @(posedge rx_clk) begin
  if (sys_rst) begin
    memcache_magic  <= 8'h0;
    memcache_opcode <= 8'h0;
  end else begin
    if (memcache_dv) begin
      case (memcache_counter)
        11'h00: memcache_magic[7:0]  <= rxd;
        11'h01: memcache_opcode[7:0] <= rxd;
      endcase
    end else begin
      memcache_magic  <= 8'h0;
      memcache_opcode <= 8'h0;
    end
  end
end

//------------------------------------------------------------------
// TX counter (Clock: gtx_clk)
//------------------------------------------------------------------
reg [11:0] txcounter;
always @(posedge gtx_clk) begin
  if (sys_rst)
    txcounter <= 12'd0;
  else
    txcounter <= txcounter + 12'd1;
end


//------------------------------------------------------------------
// Sender logic
//------------------------------------------------------------------
reg crc_rd;
wire        crc_init = (txcounter == 12'h08);
wire [31:0] crc_out;
wire        crc_data_en = ~crc_rd;
always @(posedge gtx_clk) begin
  if (sys_rst) begin
    tx_en  <= 1'b0;
    crc_rd <= 1'b0;
    txd    <= 8'h0;
  end else begin
    case (txcounter)
      12'h00: begin
        tx_en <= 1'b1;
        txd   <= 8'h55;
      end
      12'h01: txd <= 8'h55;  // Preamble
      12'h02: txd <= 8'h55;
      12'h03: txd <= 8'h55;
      12'h04: txd <= 8'h55;
      12'h05: txd <= 8'h55;
      12'h06: txd <= 8'h55;
      12'h07: txd <= 8'hd5;  // Preable + Start Frame Delimiter
      12'h08: txd <= 8'hff;  // Destination MAC address = FF-FF-FF-FF-FF-FF-FF
      12'h09: txd <= 8'hff;
      12'h0a: txd <= 8'hff;
      12'h0b: txd <= 8'hff;
      12'h0c: txd <= 8'hff;
      12'h0d: txd <= 8'hff;
      12'h0e: txd <= 8'h00;  // Source MAC address = 00-30-1b-a0-a4-8e
      12'h0f: txd <= 8'h30;
      12'h10: txd <= 8'h1b;
      12'h11: txd <= 8'ha0;
      12'h12: txd <= 8'ha4;
      12'h13: txd <= 8'h8e;
      12'h14: txd <= 8'h08;  // Protocol Type = ARP (0x0806)
      12'h15: txd <= 8'h06;
      12'h16: txd <= 8'h00;  // Harware Type = Ethernet (1)
      12'h17: txd <= 8'h01;
      12'h18: txd <= 8'h08;  // Protocol Type = IP (0x0800)
      12'h19: txd <= 8'h00;
      12'h1a: txd <= 8'h06;  // Hardware size = 6
      12'h1b: txd <= 8'h04;  // Protocol size = 4
      12'h1c: txd <= 8'h00;  // Opcode = request (1)
      12'h1d: txd <= 8'h01;
      12'h1e: txd <= 8'h00;  // Sender MAC address = 00-30-1b-a0-a4-8e
      12'h1f: txd <= 8'h30;
      12'h20: txd <= 8'h1b;
      12'h21: txd <= 8'ha0;
      12'h22: txd <= 8'ha4;
      12'h23: txd <= 8'h8e;
      12'h24: txd <= 8'd10;  // Sender IP address = 10.0.21.10
      12'h25: txd <= 8'd00;
      12'h26: txd <= 8'd21;
      12'h27: txd <= 8'd10;
      12'h28: txd <= 8'h00;  // Target MAC address = 00-00-00-00-00-00
      12'h29: txd <= 8'h00;
      12'h2a: txd <= 8'h00;
      12'h2b: txd <= 8'h00;
      12'h2c: txd <= 8'h00;
      12'h2d: txd <= 8'h00;
      12'h2e: txd <= 8'd10;  // Target IP address = 10.0.21.99
      12'h2f: txd <= 8'd00;
      12'h30: txd <= 8'd21;
      12'h31: txd <= 8'd99;
      12'h32: txd <= 8'hde;  // Padding Area
      12'h33: txd <= 8'had;
      12'h34: txd <= 8'hbe;
      12'h35: txd <= 8'hef;
      12'h36: txd <= 8'h00;
      12'h37: txd <= 8'h00;
      12'h38: txd <= 8'h00;
      12'h39: txd <= 8'h00;
      12'h3a: txd <= 8'h00;
      12'h3b: txd <= 8'h00;
      12'h3c: txd <= 8'h00;
      12'h3d: txd <= 8'h00;
      12'h3e: txd <= 8'h00;
      12'h3f: txd <= 8'h00;
      12'h40: txd <= 8'h00;
      12'h41: txd <= 8'h00;
      12'h42: txd <= 8'h00;
      12'h43: txd <= 8'h00;
      12'h44: begin        // Frame Check Sequence
        crc_rd  <= 1'b1;
        txd <= crc_out[31:24];
      end
      12'h45: txd <= crc_out[23:16];
      12'h46: txd <= crc_out[15: 8];
      12'h47: txd <= crc_out[ 7: 0];
      12'h48: begin
        tx_en  <= 1'b0;
        txd    <= 8'h0;
        crc_rd <= 1'b0;
      end
      default: txd <= 8'h0;
    endcase
  end
end


//------------------------------------------------------------------
// Ethernet FCS generator
//------------------------------------------------------------------
crc_gen crc_inst (
    .Reset(sys_rst)
  , .Clk(gtx_clk)
  , .Init(crc_init)
  , .Frame_data(txd)
  , .Data_en(crc_data_en)
  , .CRC_rd(crc_rd)
  , .CRC_end()
  , .CRC_out(crc_out)
);

endmodule

`default_nettype wire

