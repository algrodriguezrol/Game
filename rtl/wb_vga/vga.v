`timescale 1ns / 1ps

module vga(
	input clk,
	//input ren_in,
	//input green_in,
	//input blue_in,
	
	output hsync,vsync
	//output reg red_out,
	//output reg green_out,
	//output reg blue_out
	//output [9:0]hor_count,
	//output [9:0]ver_count
    );

wire clkout; 

divisor_frecuencia1 divisor (clk, clkout);
	 
	reg[9:0]hsync_cont;
	reg[9:0]vsync_cont;
	reg [2:0]color;
	reg [6:0]contColumn;
	//assign hor_count = hcount;
	//assign ver_count = vcount; 	
 
	initial begin
	hsync_cont <= 0;
	vsync_cont <= 0;
	end

	always@(posedge clkout)
	begin
		if(hsync_cont != 10'd799)hsync_cont <= hsync_cont + 10'd1;
		if(hsync_cont == 10'd799)
		begin
			hsync_cont <= 10'd0;
			if(vsync_cont != 10'd520)vsync_cont <= vsync_cont + 10'd1;
			if(vsync_cont == 10'd520)vsync_cont <= 10'd0;			
		end
	end
	
	assign hsync = (hsync_cont>655 && hsync_cont<752)?1'b0:1'b1;
	
	assign vsync = (vsync_cont>489 && vsync_cont<492)?1'b0:1'b1;
endmodule
