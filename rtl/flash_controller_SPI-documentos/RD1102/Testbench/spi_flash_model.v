// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Copyright (C) <2008> <Simon Srot (simons@opencores.org) >
//---------------------------------------------------------------------
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License,or(at
// your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
//
//---------------------------------------------------------------------
// Copyright (c) 2009 by Lattice Semiconductor Corporation
//---------------------------------------------------------------------
// Disclaimer:
//
// This VHDL or Verilog source code is intended as a design reference
// which illustrates how these types of functions can be implemented.
// It is the user's responsibility to verify their design for
// consistency and functionality through the use of formal
// verification methods. Lattice Semiconductor provides no warranty
// regarding the use or functionality of this code.
//
// --------------------------------------------------------------------
//
// Lattice Semiconductor Corporation
// 5555 NE Moore Court
// Hillsboro, OR 97214
// U.S.A
//
// TEL: 1-800-Lattice (USA and Canada)
// 503-268-8001 (other locations)
//
// web: http://www.latticesemi.com/
// email: techsupport@latticesemi.com
//
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Ver: | Author     |Mod. Date |Changes Made:
// V1.0 | Peter.Zhou |01/14/09  |
//
// --------------------------------------------------------------------
`timescale 1ns/1ps
module 	spi_flash_model
				(
  			spiClk,
  			spiDataIn,
  			spiDataOut,
  			spiCS_n
				);
input 	spiClk;
input 	spiDataIn;
output 	spiDataOut;
reg 		spiDataOut;
input 	spiCS_n;
//local wires and regs
reg [7:0] rxByte;
reg [7:0] respByte;
reg [1:0] smSt;
reg [7:0] cnt;

`define 	START 			2'b00
`define 	WAIT_FF 		2'b01
`define 	WAIT_FF_FIN 2'b10

initial
begin
  	smSt = `START;
end
//------------------------------ txRxByte --------------------------
task 					txRxByte;
input 	[7:0] txData;
output 	[7:0] rxData;
//
integer i;
begin
  	spiDataOut 			<= txData[7];
  	//@(negedge spiCS_n);
  	for( i=0;i<=7;i=i+1 )
  	begin
    		@( posedge spiClk );		//Change
    		rxData[0] 	<=#1 spiDataIn;
    		rxData 			=#1 rxData << 1;
    		@( negedge spiClk );
    		spiDataOut 	<=#1 txData[6];
    		txData 			=#1 txData << 1;
  	end
end
endtask
//response state machine
always #0
begin
    case (smSt)
    `START:
    begin
    		txRxByte(8'hff, rxByte);
    		if( rxByte == 8'hff )
    		begin
    		  	smSt <= `WAIT_FF;
    		  	cnt <= 8'h00;
    		end
    end
    `WAIT_FF:
    begin
    		txRxByte(8'hff, rxByte);
    		if (rxByte == 8'hff)
    		begin
      			cnt <= cnt + 1'b1;
      			if (cnt == 8'h04)
      			begin
        				txRxByte(respByte, rxByte);
        				smSt <= `WAIT_FF_FIN;
      			end
    		end
    		else
    		begin
      			smSt <= `START;
      			cnt <= 8'h00;
    		end
    end
    `WAIT_FF_FIN:
    begin
    		txRxByte(8'hff, rxByte);
    		if ( rxByte == 8'h04 )
    		begin
      			cnt <= cnt + 1'b1;
      			if( cnt == 8'hff )
      			begin
        				txRxByte(respByte, rxByte);
        				smSt <=`START;
      			end
    		end
    		else
    		begin
      			smSt <= `START;
      	end
    end
    endcase
end
//setRespByte
task setRespByte;
input [7:0] dataByte;
begin
  	respByte = dataByte;
end
endtask
endmodule
