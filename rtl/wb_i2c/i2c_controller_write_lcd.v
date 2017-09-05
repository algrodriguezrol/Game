`timescale 1ns / 1ps
/////////////////////////////
module i2c_controller_write_lcd(
	input  clk_n,
	input  clk,
	input 		reset,
	input  		start,
	input 	[31:0]  i2c_data,

    	output 		i2c_sclk,
	output 		done,
    	output 		ack,
	output		busy,

	inout  		i2c_sdat    
);

reg [31:0] data;
reg [4:0] stage;
reg [6:0] sclk_divider;
reg clock_en = 1'b0;
reg done = 1'b1;
reg busy = 1'b0;

// don't toggle the clock unless we're sending data
// clock will also be kept high when sending START and STOP symbols
assign i2c_sclk = (!clock_en) || sclk_divider[6];
wire midlow = (sclk_divider == 7'h1f);

reg sdat = 1'b1;
// rely on pull-up resistor to set SDAT high
assign i2c_sdat = (sdat) ? 1'bz : 1'b0;

reg [2:0] acks;

parameter LAST_STAGE = 5'd20;
assign ack = (acks == 3'b0);
//assign done = (stage == LAST_STAGE);

reg [1:0] stageclk = 0;
reg startslow = 0;

always @(posedge clk_n) begin
	case (stageclk)
		0: begin
		if (start == 1) begin
			startslow = 1;
			stageclk = 1;
			end
		end
		1: begin
		if (clk == 0) begin
			stageclk = 2;
			end
		end
		2: begin
		if (clk == 1) begin
			stageclk = 3;
			end
		end
		3: begin
			startslow = 0;
			stageclk = 0;
		end
	endcase
end

always @(posedge clk) begin
   if(reset) begin
	sclk_divider <= 7'd0;
	stage <= LAST_STAGE;
	clock_en <= 1'b0;
	done <= 1'b0;
	busy <= 1'b0;
	sdat <= 1'b1;
	acks <=3'b111;
	data <= 32'b0;	  
   end

   if (startslow) begin
        sclk_divider <= 7'd0;
        stage <= 5'd0;
        clock_en <= 1'b0;
	done <= 1'b0;
	busy <= 1'b0;//1'b0;
        sdat <= 1'b1;
	acks <= 3'b111;
        data <= i2c_data;
   end else begin
        
	if (sclk_divider == 7'd127) begin
            sclk_divider <= 7'd0;
	if (stage != LAST_STAGE)
            stage <= stage + 1'b1;

		case (stage)
                // after start
                5'd0:  begin
			clock_en <= 1'b1;
			done <= 1'b0;
			busy <= 1'b1;
			end
                // receive acks
                5'd9:  acks[0] <= i2c_sdat;
                5'd18: acks[1] <= i2c_sdat;
                // before stop
                5'd19: begin
			clock_en <= 1'b0;
			done <= 1'b1;
			busy <= 1'b0;
			end
            endcase
        end else
            sclk_divider <= sclk_divider + 1'b1;

        if (midlow) begin
            case (stage)
                // start
                5'd0:  sdat <= 1'b0;
                // byte 1 Register I2C
                5'd1:  sdat <= data[14];
                5'd2:  sdat <= data[13];
                5'd3:  sdat <= data[12];
                5'd4:  sdat <= data[11];
                5'd5:  sdat <= data[10];
                5'd6:  sdat <= data[9];
                5'd7:  sdat <= data[8];
		//write
                5'd8:  sdat <= 1'b0;
                // ack 1
                5'd9:  sdat <= 1'b1;
		// byte 3 Transmit Data
                5'd10: sdat <= data[7];
                5'd11: sdat <= data[6];
                5'd12: sdat <= data[5];
                5'd13: sdat <= data[4];
                5'd14: sdat <= data[3];
                5'd15: sdat <= data[2];
                5'd16: sdat <= data[1];
                5'd17: sdat <= data[0];
                // ack 3
                5'd18: sdat <= 1'b1;
                // stop
                5'd19: sdat <= 1'b0;
                5'd20: sdat <= 1'b1;
            endcase
        end
    end
end

endmodule


