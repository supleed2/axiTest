// AXI4-Lite compatible memory module, for testing driver module
// SPDX-FileCopyrightText: © 2022 Aadi Desai <21363892+supleed2@users.noreply.github.com>
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

typedef enum bit [1:0]
{ OKAY   = 2'b00
, EXOKAY = 2'b01
, SLVERR = 2'b10
, DECERR = 2'b11
} Response;

typedef enum bit [2:0]
{ UNPRIV_SEC_DATA     = 3'b000 // Unprivileged, secure, data access
, PRIV_SEC_DATA       = 3'b001 // Privileged, secure, data access
, UNPRIV_NONSEC_DATA  = 3'b010 // Unprivileged, non-secure, data access
, PRIV_NONSEC_DATA    = 3'b011 // Privileged, non-secure, data access
, UNPRIV_SEC_INSTR    = 3'b100 // Unprivileged, secure, instruction access
, PRIV_SEC_INSTR      = 3'b101 // Privileged, secure, instruction access
, UNPRIV_NONSEC_INSTR = 3'b110 // Unprivileged, non-secure, instruction access
, PRIV_NONSEC_INSTR   = 3'b111 // Privileged, non-secure, instruction access
} Protection;

module Axi4LiteSlave
#(parameter int AWIDTH = 12
, parameter int DWIDTH = 32
, parameter int SWIDTH = DWIDTH / 8
)(input  var logic              i_aClk
, input  var logic              i_aResetn
// Read Address Channel (Master -> Slave)
, input  var logic              i_arValid
, output var logic              o_arReady
, input  var logic [AWIDTH-1:0] i_arAddr
, input  var Protection         i_arProt
// Read Data Channel (Slave -> Master)
, output var logic              o_rValid
, input  var logic              i_rReady
, output var logic [DWIDTH-1:0] o_rData
, output var Response           o_rResp
// Write Address Channel (Master -> Slave)
, input  var logic              i_awValid
, output var logic              o_awReady
, input  var logic [AWIDTH-1:0] i_awAddr
, input  var Protection         i_awProt
// Write Data Channel (Master -> Slave)
, input  var logic              i_wValid
, output var logic              o_wReady
, input  var logic [DWIDTH-1:0] i_wData
, input  var logic [SWIDTH-1:0] i_wStrb
// Write Response Channel (Slave -> Master)
, output var logic              o_bValid
, input  var logic              i_bReady
, output var Response           o_bResp
);

  logic [DWIDTH-1:0] mem [4096];
  logic [DWIDTH-1:0] wDataStrb;
  for (genvar i = 0; i < SWIDTH; i++) begin : la_StrobedWriteData
    assign wDataStrb[8*i+7:8*i] = i_wStrb[i] ? i_wData[8*i+7:8*i] : mem[i_awAddr][8*i+7:8*i];
  end

  enum bit [0:0]
  { IDLE
  , READ
  } rState;

  enum bit [2:0]
  { IDLE
  , WRITE
  } wState;

  always_ff @(posedge i_aClk)
    if (!i_aResetn) begin
      o_arReady <= '0;
      o_rValid  <= '0;
      o_rData   <= '0;
      o_rResp   <= '0;
    end else
      case (rState)
        IDLE: begin
          if (i_arValid) begin
            o_arReady <= '1;
            o_rValid  <= '1;
            o_rData   <= mem[i_arAddr];
            o_rResp   <= Response'(OKAY);
            rState    <= READ;
          end else
            rState    <= IDLE;
        end
        READ: begin
          o_arReady  <= '0;
          if (i_rReady) begin
            o_rValid <= '0;
            o_rData  <= '0;
            o_rResp  <= '0;
            rState   <= IDLE;
          end else
            rState   <= READ;
        end
        default: begin
          o_arReady <= '0;
          o_rValid  <= '0;
          o_rData   <= '0;
          o_rResp   <= '0;
        end
      endcase

  always_ff @(posedge i_aClk)
    if (!i_aResetn) begin
      o_awReady <= '0;
      o_wReady  <= '0;
      o_bValid  <= '0;
      o_bResp   <= '0;
    end else
      case (wState)
        IDLE: begin
          if (i_awValid && i_wValid) begin
            o_awReady     <= '1;
            mem[i_awAddr] <= wDataStrb;
            o_wReady      <= '1;
            o_bValid      <= '1;
            o_bResp       <= Response'(OKAY);
            wState        <= WRITE;
          end else
            wState        <= IDLE;
        end
        WRITE: begin
          o_awReady  <= '0;
          o_wReady   <= '0;
          if (i_bReady) begin
            o_bValid <= '0;
            o_bResp  <= '0;
            wState   <= IDLE;
          end else
            wState   <= WRITE;
        end
        default: begin
          o_awReady <= '0;
          o_wReady  <= '0;
          o_bValid  <= '0;
          o_bResp   <= '0;
        end
      endcase

endmodule

`resetall
