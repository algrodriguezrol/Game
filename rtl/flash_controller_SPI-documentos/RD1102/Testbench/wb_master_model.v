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
`timescale 1ns/1ns
module wb_master_model
			 (
			 clk, 
			 rst, 
			 adr, 
			 din, 
			 dout, 
			 cyc, 
			 stb, 
			 we, 
			 sel, 
			 ack, 
			 err, 
			 rty
			 );

parameter dwidth = 8;
parameter awidth = 8;

input                  clk, rst;
output [awidth   -1:0] adr;
input  [dwidth   -1:0] din;
output [dwidth   -1:0] dout;
output                 cyc, stb;
output                 we;
output [dwidth/8 -1:0] sel;
input                  ack, err, rty;

//Internal signals
reg    [awidth   -1:0] adr;
reg    [dwidth   -1:0] dout;
reg                    cyc, stb;
reg                    we;
reg    [dwidth/8 -1:0] sel;
       
reg    [dwidth   -1:0] q;

//Memory Logic
initial
begin
    adr  = {awidth{1'b0}};//From x to 0
    dout = {dwidth{1'b0}};//From x to 0
    cyc  = 1'b1;//From x to 0
    stb  = 1'b0;//From x to 0
    we   = 1'h0;//From x to 0
    sel  = {dwidth/8{1'b0}};//From x to 0
    #2;
end

// Wishbone write cycle
task wb_write;
  input   delay;
  integer delay;

  input [awidth -1:0] a;
  input [dwidth -1:0] d;

  begin
    	// wait initial delay
    	repeat(delay) @(posedge clk);
    	
    	// assert wishbone signal
    	//#2;
    	adr  = a;
    	dout = d;
    	cyc  = 1'b1;
    	stb  = 1'b1;
    	we   = 1'b1;
    	sel  = {dwidth/8{1'b1}}; 
    	#2;
    	@(posedge clk);
    	//stb  = 1'b0;
    	//wait for acknowledge from slave
    	while(~ack) @(posedge clk);
    	//we   = 1'b1; 
    	//@(posedge clk);
    	// negate wishbone signals
     	cyc  = 1'b0;
    	stb  = 1'b0;//From x to 0
    	adr  = {awidth{1'b0}};//From x to 0
    	//dout = {dwidth{1'b0}};//From x to 0
    	we   = 1'h0;//From x to 0
    	sel  = {dwidth/8{1'b0}};//From x to 0  
    	//@(posedge clk);
    	//@(posedge clk);
  end
endtask

// Wishbone read cycle
task wb_read;
  input   delay;
  integer delay;

  input  [awidth -1:0]  a;
  output  [dwidth -1:0] d;

  begin

    // wait initial delay
    repeat(delay) @(posedge clk);//change

    // assert wishbone signals
    #2;
    adr  = a;
    dout = {dwidth{1'b0}};//From x to 0
    cyc  = 1'b1;
    stb  = 1'b1;
    we   = 1'b0;
    sel  = {dwidth/8{1'b1}};
    @(posedge clk);//change
     //stb  = 1'b0;
    // wait for acknowledge from slave
    while(~ack) @(posedge clk);//change
		//@(posedge clk);
    // negate wishbone signals
    //#2;
    cyc  = 1'b0;
    stb  = 1'b0;//From x to 0
    adr  = {awidth{1'b0}};//From x to 0
    dout = {dwidth{1'b0}};//From x to 0
    we   = 1'h0;//From x to 0
    sel  = {dwidth/8{1'b0}};//From x to 0
    d    = din;

  end
endtask

// Wishbone compare cycle (read data from location and compare with expected data)
task wb_cmp;
  input   delay;
  integer delay;

  input [awidth -1:0] a;
  input [dwidth -1:0] d_exp;

  begin
    	wb_read (delay, a, q);

  if (d_exp !== q)
   begin
   		 $display("Data compare error. Received %h, expected %h at time %t", q, d_exp, $time);
   		 $stop;
   	end
  end
endtask  
endmodule
 
