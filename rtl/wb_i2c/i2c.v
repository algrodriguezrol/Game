`timescale 1ns / 1ps

module i2c(
    	input clk,
	input reset,
	input divisor,
	input [1:0] rw,
	//input start,
	input startread,
	input startwrite,
	input startwrite_lcd,
	input [31:0] i2c_data,

	output i2c_sclk,
	output doneW,
	output busyW,
	output doneR,
	output busyR,
    	output ack,
	output [7:0] i2c_data_out,

   	inout  i2c_sdat 
    );
	 

wire mclk;

wire [7:0]i2c_data_out_wire;

wire i2c_sclk_write;
wire i2c_sclk_read;
wire i2c_sclk_write_lcd;
reg i2c_sclk_wire;

wire done_write;
wire busy_write;
wire ack_write;

wire done_write_lcd;
wire busy_write_lcd;
wire ack_write_lcd;

wire done_read;
wire busy_read;
wire ack_read;

reg done_write_wire;
reg busy_write_wire;

assign busyR = busy_read;
assign doneR = done_read;
assign busyW = busy_write_wire;
assign doneW = done_write_wire;

//assign done = (done_read||done_write);
assign ack = (ack_read||ack_write);

assign i2c_data_out = i2c_data_out_wire;

//assign i2c_sdat = (rw) ? i2c_sdat_read : i2c_sdat_write;
//assign i2c_sclk = (rw_wire[0]) ? i2c_sclk_read : i2c_sclk_write;
assign i2c_sclk = i2c_sclk_wire;

always @(posedge clk)begin
	case (rw)
		2'd0: begin
			i2c_sclk_wire <= i2c_sclk_write;
			busy_write_wire <= busy_write;
			done_write_wire <= done_write;
			end
		2'd1: begin
			i2c_sclk_wire <= i2c_sclk_read;
			end
		2'd2: begin
			i2c_sclk_wire <= i2c_sclk_write_lcd;
			busy_write_wire <= busy_write_lcd;
			done_write_wire <= done_write_lcd;
			end  
		default: begin 
			i2c_sclk_wire <= 1'b1;
//			busy_write_wire <= 1'b0;
//			done_write_wire <= 1'b0;
			end
	endcase
end


i2c_controller_read_new i2c_read (
 	.clk_n(clk),    
	.clk(mclk),
	.reset(reset),
	.i2c_sclk(i2c_sclk_read),
     	.i2c_sdat(i2c_sdat),
	.start(startread),
     	.done(done_read),
	.busy(busy_read),
     	.ack(ack_read),

     	.i2c_data(i2c_data),
	.i2c_data_out(i2c_data_out_wire)
);


i2c_controller_write_new i2c_write (
 	.clk_n(clk),    
	.clk(mclk),
        .reset(reset),

     	.i2c_sclk(i2c_sclk_write),
     	.i2c_sdat(i2c_sdat),
	.start(startwrite),
     	.done(done_write),
	.busy(busy_write),
     	.ack(ack_write),

     	.i2c_data(i2c_data)
);

i2c_controller_write_lcd i2c_write_lcd (
 	.clk_n(clk),    
	.clk(mclk),
        .reset(reset),
	.start(startwrite_lcd),
     	.i2c_data(i2c_data),
     	.i2c_sclk(i2c_sclk_write_lcd),
     	.done(done_write_lcd),
     	.ack(ack_write_lcd),
	.busy(busy_write_lcd),
     	.i2c_sdat(i2c_sdat)
);

divisor_frecuencia divisorfrecuencia (
    	.clk(clk),
	.divisor(divisor), 
    	.mclk(mclk)
);

endmodule
