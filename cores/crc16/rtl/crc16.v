////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 1999-2008 Easics NV.
// This source file may be used and distributed without restriction
// provided that this copyright statement is not removed from the file
// and that any derivative work contains the original copyright notice
// and the associated disclaimer.
//
// THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS
// OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
// WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
//
// Purpose : synthesizable CRC function
//   * polynomial: (0 5 12 16)
//   * data width: 8
//
// Info : tools@easics.be
//        http://www.easics.com
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module crc16_gen (
    input  wire Reset
  , input  wire Clk
  , input  wire Init
  , input  wire [7:0] Frame_data
  , input  wire Data_en
  , input  wire CRC_rd
  , output wire [15:0] CRC_out
  , output reg  CRC_end
);

reg [15:0] CRC_reg;

function [15:0] NextCRC16;
  input [ 7:0] d;
  input [15:0] c;
  reg   [15:0] newcrc;
begin
  newcrc[ 0] = d[4] ^ d[0] ^ c[8] ^ c[12];
  newcrc[ 1] = d[5] ^ d[1] ^ c[9] ^ c[13];
  newcrc[ 2] = d[6] ^ d[2] ^ c[10] ^ c[14];
  newcrc[ 3] = d[7] ^ d[3] ^ c[11] ^ c[15];
  newcrc[ 4] = d[4] ^ c[12];
  newcrc[ 5] = d[5] ^ d[4] ^ d[0] ^ c[8] ^ c[12] ^ c[13];
  newcrc[ 6] = d[6] ^ d[5] ^ d[1] ^ c[9] ^ c[13] ^ c[14];
  newcrc[ 7] = d[7] ^ d[6] ^ d[2] ^ c[10] ^ c[14] ^ c[15];
  newcrc[ 8] = d[7] ^ d[3] ^ c[0] ^ c[11] ^ c[15];
  newcrc[ 9] = d[4] ^ c[1] ^ c[12];
  newcrc[10] = d[5] ^ c[2] ^ c[13];
  newcrc[11] = d[6] ^ c[3] ^ c[14];
  newcrc[12] = d[7] ^ d[4] ^ d[0] ^ c[4] ^ c[8] ^ c[12] ^ c[15];
  newcrc[13] = d[5] ^ d[1] ^ c[5] ^ c[9] ^ c[13];
  newcrc[14] = d[6] ^ d[2] ^ c[6] ^ c[10] ^ c[14];
  newcrc[15] = d[7] ^ d[3] ^ c[7] ^ c[11] ^ c[15];
  NextCRC16 = newcrc;
end
endfunction

always @ (negedge Clk)
  if (Reset)
    CRC_reg <= 16'hffff;
  else
    CRC_reg <= Init ? 16'hffff : Data_en ? NextCRC16(Frame_data, CRC_reg) : CRC_reg;

assign CRC_out = ~{ CRC_reg[ 8],CRC_reg[ 9],CRC_reg[10],CRC_reg[11],CRC_reg[12],CRC_reg[13],CRC_reg[14],CRC_reg[15],
                    CRC_reg[ 0],CRC_reg[ 1],CRC_reg[ 2],CRC_reg[ 3],CRC_reg[ 4],CRC_reg[ 5],CRC_reg[ 6],CRC_reg[ 7] };

endmodule

`default_nettype wire

