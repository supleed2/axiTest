// Driver module for use with AXI4-Lite bus, with exported DPI-C functions
// SPDX-FileCopyrightText: © 2022 Aadi Desai <21363892+supleed2@users.noreply.github.com>
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

module Axi4LiteDriver
#(parameter int AWIDTH = 12         // Default: 4KB, [1:0] ignored = word aligned accesses
, parameter int DWIDTH = 32         // AXI4-Lite Data bus is 32/64 bit only
, parameter int SWIDTH = DWIDTH / 8 // Strobe width = data width / 8
)(input  var logic              i_aClk
, input  var logic              i_aResetn
// Read Address Channel (Master -> Slave)
, output var logic              o_arValid
, input  var logic              i_arReady
, output var logic [AWIDTH-1:0] o_arAddr
, output var Protection         o_arProt
// Read Data Channel (Slave -> Master)
, input  var logic              i_rValid
, output var logic              o_rReady
, input  var logic [DWIDTH-1:0] i_rData
, input  var Response           i_rResp
// Write Address Channel (Master -> Slave)
, output var logic              o_awValid
, input  var logic              i_awReady
, output var logic [AWIDTH-1:0] o_awAddr
, output var Protection         o_awProt
// Write Data Channel (Master -> Slave)
, output var logic              o_wValid
, input  var logic              i_wReady
, output var logic [DWIDTH-1:0] o_wData
, output var logic [SWIDTH-1:0] o_wStrb
// Write Response Channel (Slave -> Master)
, input  var logic              i_bValid
, output var logic              o_bReady
, input  var Response           i_bResp
);
endmodule

`resetall
