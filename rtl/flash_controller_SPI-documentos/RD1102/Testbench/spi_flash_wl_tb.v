// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Copyright (c) 2010 by Lattice Semiconductor Corporation
//---------------------------------------------------------------------
// Permission:
//
//   Lattice Semiconductor grants permission to use this code for use
//   in synthesis for any Lattice programmable logic product.  Other
//   use of this code, including the selling or duplication of any
//   portion is strictly prohibited.
//
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
// V1.0 | Peter.Zhou |10/18/10  |
//
// --------------------------------------------------------------------
//
`define NOP 		 	8'hFF 			// no cmd to execute
`define WREN 		 	8'h06 			// write enable
`define WRDI 			8'h04  		// write disable
`define RDSR 		 	8'h05 			// read status reg
`define WRSR 		 	8'h01  		// write stat. reg
`define RDCMD 	 	8'h03 			// read data
`define F_RD 		 	8'h0B 			// fast read data
`define PP 			 	8'h02  		// page program
`define SE 			 	8'hD8  		// sector erase
`define BE 			 	8'hC7  		// bulk erase
`define DP 			 	8'hB9  		// deep power down
`define RES 		 	8'hAB  		// read signature

//define the configuration registers
`define timercounter_ctrl6 8'h64

`define wbcfg_ctrl0 8'h70 		//This is control register
`define wbcfg_ctrl1 8'h71 		//This is transmit data register
`define wbcfg_sts0	8'h72 		//This is status register
`define wbcfg_sts1  8'h73 		//This is receive data register
`define wbcfg_irq0	8'h74 		//This is interrupt request register
`define wbcfg_ena0	8'h75 		//This is interrupt request enable register

`define IDCODE			8'hE0			//This is IDCODE register
`define UFM_ENABLE  8'h74 		//This is UFM enable register
`define UFM_DIRECT_ADDR 8'hB4 //This is UFM accesstion address register
`define UFM_WRITE		8'hC9			//This is UFM page access code
`define UFM_READ		8'hCA			//This is UFM page read command code
`define UFM_ERASE		8'hCB			//This is UFM erase command 
`define UFM_DISABLE 8'h26			//This is UFM diable code
`timescale 1ns/1ps
module spi_flash_wl_tb;
//Inputs
reg					ufm_sel;
reg 				wb_clk_i;
reg 				wb_rst_i;
wire 				wb_cyc_i;
wire 				wb_stb_i;
wire 				wb_we_i;
wire[7:0] 	wb_adr_i;
wire[7:0] 	wb_dat_i;
reg 				ufm_sn;
wire				wb_sel_i;
wire			wb_int_req;
//Outputs
wire[7:0] 	wb_dat_o;
wire 				wb_ack_o;
reg[7:0]  	data_read;
wire 				spiClkOut;
wire 				spiCsn;
wire 				spiDataIn;
wire 				spiDataOut;
integer 		i;
reg[7:0] 		user_reg_addr;
reg[7:0] 		user_reg_data;
reg[2:0] 		sector_addr;
reg[10:0] 	logic_addr_index;
reg[10:0] 	phy_addr_index;
reg[7:0] 		write_data;
//Initialize Inputs
//You can add your stimulus here
initial
begin
    i 								= 0;  
    ufm_sel						= 0;
		user_reg_addr 		= 8'b0;
		user_reg_data 		= 8'b0;
		sector_addr				= 8'h0;
		logic_addr_index	= 11'h0;
		phy_addr_index 		= 11'h0;
		wb_clk_i 					= 1'b0;
    wb_rst_i 					= 1'b1;
		write_data	 			= 8'd0;
    ufm_sn   					= 1'b0;
    #98765;
    wb_rst_i 					= 1'b0;
end
//Generate the clock
always #20 wb_clk_i = ~wb_clk_i;
//Generate the test vector
initial
begin
		$display("\n\n");
		@(negedge wb_rst_i);
		$display("<<Test read/write user register>>");
		uut1.wb_write(1,8'h77,user_reg_data);
		uut1.wb_cmp(1,8'h77,user_reg_data);
		uut1.wb_read(1,8'hFF,data_read);//checking the data transmitted fifo
		while(!data_read[0])
		begin
				uut1.wb_read(1,8'hFF,data_read);
		end
		$display("<<Test read/write user register is over>>");
		$display("<<Write logic address map table>>");
		for(i=0;i<=2047;i=i+1)
		begin
				//uut1.wb_write(1,8'h78,8'h0);
				//uut1.wb_cmp(1,8'h78,8'h0);
				uut1.wb_write(1,8'h78,logic_addr_index[7:0]);
				uut1.wb_cmp(1,8'h78,logic_addr_index[7:0]);
				uut1.wb_write(1,8'h79,{5'b0,logic_addr_index[10:8]});
				uut1.wb_cmp(1,8'h79,{5'b0,logic_addr_index[10:8]});
				@(posedge wb_clk_i);
				phy_addr_index = logic_addr_index + 8;
				//**************************************************
				uut1.wb_write(1,8'h80,8'h0);
				//uut1.wb_cmp(1,8'h4,8'h0);
				uut1.wb_write(1,8'h81,phy_addr_index[7:0]);
				//uut1.wb_cmp(1,8'h5,phy_addr_index[7:0]);
				uut1.wb_write(1,8'h82,{1'b1,4'b0,phy_addr_index[10:8]});
				//uut1.wb_cmp(1,8'h6,{1'b1,4'b0,phy_addr_index[10:8]});
				logic_addr_index = logic_addr_index + 1;
		end
		$display("Read the logic address map table");
		logic_addr_index = 0;
		for(i=0;i<=2047;i=i+1)
		begin
				uut1.wb_write(1,8'h78,logic_addr_index[7:0]);
				uut1.wb_cmp(1,8'h78,logic_addr_index[7:0]);
				uut1.wb_write(1,8'h79,{1'b1,4'b0,logic_addr_index[10:8]});
				@(posedge wb_clk_i);
				uut1.wb_read(1,8'h94,data_read);
				uut1.wb_read(1,8'h93,data_read);
				logic_addr_index = logic_addr_index + 1;
		end
		#1000;
		//$stop;
		$display("\n\n");
		$display("<<Erase every sector %0t ns>>",($time/10**3));
		user_reg_addr = 8'b0;
		user_reg_data = 8'b0;
		uut1.wb_write(1,8'h92,8'hFF );	//enable transmitting data to spi flash
		uut1.wb_cmp(1,8'h92,8'h01);
    for( i=0;i<=7;i=i+1)	//This block is used for erase every sector
		begin
				uut1.wb_write(1,8'h77,`SE);	//write the sector erase command to spi flash
				uut1.wb_cmp(1,8'h77,`SE);
				uut1.wb_read(1,8'hFF,data_read);
				while(!data_read[0])
				begin
						uut1.wb_read(1,8'hFF,data_read);
				end
				$display("<<Write the low byte of the physical address %t ns>>",($time/10**3));
				uut1.wb_write(1,8'h80,8'h0);	//write physical address low byte
				uut1.wb_cmp(1,8'h80,8'h0);
				uut1.wb_read(1,8'hFF,data_read);
				while(!data_read[0])
				begin
						uut1.wb_read(1,8'hFF,data_read);
				end
				$display("<<Write the middle byte of the physical address %t ns>>",($time/10**3));
				uut1.wb_write(1,8'h81,8'h0);
				uut1.wb_cmp(1,8'h81,8'h0);
				uut1.wb_read(1,8'hFF,data_read);
				while(!data_read[0])
				begin
		    		uut1.wb_read(1,8'hFF,data_read);
				end
				$display("<<Write the high byte of the physical address %t ns>>",($time/10**3));
				uut1.wb_write(1, 8'h82, {1'b1,4'b0,sector_addr});
				uut1.wb_cmp(1,8'h82,{1'b0,4'b0,sector_addr});
				uut1.wb_read(1,8'hFF,data_read);
				while(!data_read[0])
				begin
						uut1.wb_read(1,8'hFF,data_read);
				end
				#1000;
				sector_addr = sector_addr + 1;
		end
		//
		#1000;
		$display("<<Read the erase times memory %t ns>>",($time/10**3));
		user_reg_data =8'h80;
		for (i=0;i<=7;i=i+1)
		begin
				uut1.wb_write(1,8'h84,user_reg_data);
				@(posedge wb_clk_i);
				uut1.wb_read(1,8'h89,data_read);
				uut1.wb_read(1,8'h90,data_read);
				uut1.wb_read(1,8'h91,data_read);
				user_reg_data = user_reg_data + 1;
		end
	  
    
		$display("<<Write the bulk erase command %t ns>>",($time/10**3));
		uut1.wb_write(1,8'h77, `BE );
		uut1.wb_cmp(1,8'h77,`BE);
		uut1.wb_read(1,8'hFF,data_read);
		while(!data_read[0])
		begin
				uut1.wb_read(1,8'hFF,data_read);
		end
		uut1.wb_write(1,8'h77,`NOP);
		uut1.wb_cmp(1,8'h77,`NOP);
		#1000;
		#2000;
		#6000;
		$display("<<Read the erase times memory %t ns>>",($time/10**3));
		user_reg_data =8'h80;
		for (i=0;i<=7;i=i+1)
		begin
				uut1.wb_write(1,8'h84,user_reg_data);
				@(posedge wb_clk_i);
				uut1.wb_read(1,8'h89,data_read);
				uut1.wb_read(1,8'h90,data_read);
				uut1.wb_read(1,8'h91,data_read);
				user_reg_data = user_reg_data + 1;
		end
		$display("<<Test the page program command %t ns>>",($time/10**3));
		uut1.wb_write(1,8'h77,`PP );
		uut1.wb_cmp(1,8'h77,`PP);
		uut1.wb_read(1,8'hFF,data_read);
		while(!data_read[0])
		begin
				uut1.wb_read(1,8'hFF,data_read);
		end
		$display("<<Write the physical address %t ns>>",($time/10**3));
		$display("<<Write the low byte of the physical address %t ns>>",($time/10**3));
		uut1.wb_write(1, 8'h80, 8'h0);
		uut1.wb_cmp(1,8'h80,8'h0);
		uut1.wb_read(1,8'hFF,data_read);
		while(!data_read[0])
		begin
				uut1.wb_read(1,8'hFF,data_read);
		end
		$display("<<Write the middle byte of the physical address %t ns>>	",($time/10**3));
		uut1.wb_write(1, 8'h81, 8'hf);
		uut1.wb_cmp(1,8'h81,8'hf);
		uut1.wb_read(1,8'hFF,data_read);
		while(!data_read[0])
		begin
				uut1.wb_read(1,8'hFF,data_read);
		end
		$display("<<Write the high byte of the physical address %t ns>>	",($time/10**3));
		uut1.wb_write(1, 8'h82, {1'b1,4'b0,3'b0});
		uut1.wb_cmp(1,8'h82,{1'b0,4'b0,3'b0});
		uut1.wb_read(1,8'hFF,data_read);
		while(!data_read[0])
		begin
				uut1.wb_read(1,8'hFF,data_read);
		end
		$display("<<Write one page data for the selected sector %t ns>>",($time/10**3));
		for(i=0;i<=255;i=i+1)
		begin
				uut1.wb_write(1,8'h83,write_data);
				uut1.wb_cmp(1,8'h83,write_data);
				uut1.wb_read(1,8'hFF,data_read);
				while(!data_read[0])
				begin
						uut1.wb_read(1,8'hFF,data_read);
				end
				write_data	= write_data + 1'b1;
		end
		#1000;
		$display("<<Read the page valid memory	%t ns>>",($time/10**3));
		user_reg_data=0;
		for(i=0;i<=255;i=i+1)
		begin
				uut1.wb_write(1,8'h85,user_reg_data);
				uut1.wb_write(1,8'h86,8'h1);
				@(posedge wb_clk_i );
				uut1.wb_write(1,8'h86,8'h0);
				uut1.wb_read(1,8'h95,data_read);
				user_reg_data = user_reg_data + 1;
		end
		#1000;		
		$display("<<Test wear leveling is over: %t ns>>	",($time/10**3));
    $display("\n\n"); 
    
    //@(negedge wb_rst_i);
		$display("Initialization efb module");
		ufm_sel = 1'b1;
		uut1.wb_write(1,8'h76,8'hFF);
		efb_init;
		cfg_ufm;
  	$display("\n\n");   
		$stop;
end

// Bidirs
GSR GSR_INST
 		 (
 		 .GSR( 1'b1)
 		 );
 PUR PUR_INST
 		(
 		.PUR(1'b1)
 		);
//
spi_flash_controller_wl_top uut0
		(
		//.ufm_sn			(	1'b0					),
		.ufm_sel	(ufm_sel),
		.wb_clk_i		( wb_clk_i 			),
		.wb_rst_i		( wb_rst_i      ),
		//slave wishbone interface
		.wb_sel_i 	( wb_sel_i 			),
		.wb_we_i		( wb_we_i  			),
		.wb_adr_i 	( wb_adr_i 			),
		.wb_dat_i 	( wb_dat_i 			),
		.wb_dat_o 	( wb_dat_o 			),
		.wb_stb_i 	( wb_stb_i 			), 
		.wb_cyc_i		( wb_cyc_i			),
		.wb_ack_o 	( wb_ack_o 			),
		.wb_int_req	( wb_int_req 		),
		//Spi interface
		.spiClkOut	( spiClkOut	   	),
		.spiDataIn	( spiDataIn	   	),
		.spiDataOut ( spiDataOut   	),
		.spiCsn			( spiCsn			 	)
		);
//
wb_master_model uut1
			 (
			 .clk			( wb_clk_i ),
			 .rst			( wb_rst_i ),
			 .adr			( wb_adr_i ),
			 .din			( wb_dat_o ),
			 .dout		( wb_dat_i ),
			 .cyc			( wb_cyc_i ),
			 .stb			( wb_stb_i ),
			 .we			( wb_we_i  ),
			 .sel			( wb_sel_i ),
			 .ack			( wb_ack_o ),
			 .err			( 				 ),
			 .rty			( 				 )
			 );
//--
spi_flash_model uut2
			(
			.spiClk			( spiClkOut	  ),
			.spiDataIn	( spiDataOut	),
			.spiDataOut ( spiDataIn   ),
			.spiCS_n		( spiCsn			)
			);
			
/**********************************************************\
This task is used to initialize the EFB
\**********************************************************/
task efb_init;
//this part define the input signal and all used signals
begin // this block define process
		#1005; //delay 1000ns
		uut1.wb_write(1,`timercounter_ctrl6,8'h02); 	//reset TC_CNT register and loads TC_TOP_SET into TC_TOP
		uut1.wb_write(1,`timercounter_ctrl6,8'h00); 	//Clear reset
		#100;
		uut1.wb_write(1,`wbcfg_ctrl0,8'h80);					//Enable CFG connection
		#100;              
		$display("<<EFB initialization finished %t ns>>",($time/10**3));
end
endtask

task cfg_ufm;
//this part define the input signal and all used signals
reg[7:0] cfg_data;
begin
		cfg_data =0;
		$display("<<Enable UFM %t ns>>",($time/10**3));
		uut1.wb_cmp(1,`wbcfg_ctrl0,8'h80); // Read wbcfg_ctrl0 register
		#1000;
		//uut1.wb_read(1,`wbcfg_ctrl0,8'h50); // Read wbcfg_ctrl0 register 
		uut1.wb_write(1,`wbcfg_ctrl1,`UFM_ENABLE);
		uut1.wb_write(1,`wbcfg_ctrl1,8'h08);
		uut1.wb_write(1,`wbcfg_ctrl1,8'h0);
		uut1.wb_write(1,`wbcfg_ctrl1,8'h0);
		$display("<<SELECT A PAGE FOR WRITE OPERATION %t ns>>",($time/10**3));
		uut1.wb_write(1,`wbcfg_ctrl1,`UFM_DIRECT_ADDR);
		uut1.wb_write(1,`wbcfg_ctrl1,8'h0);
		uut1.wb_write(1,`wbcfg_ctrl1,8'h0);
		uut1.wb_write(1,`wbcfg_ctrl1,8'h0);
		$display("<<SELECT UFM %t ns>>",($time/10**3));
		uut1.wb_write(1,`wbcfg_ctrl1,8'h40);
		$display("<<Write Page Address %t ns>>",($time/10**3));
		uut1.wb_write(1,`wbcfg_ctrl1,8'h0);
		uut1.wb_write(1,`wbcfg_ctrl1,8'h0);
		uut1.wb_write(1,`wbcfg_ctrl1,8'h0);
		$display("<<write wbcfg_ctrl0 register with disable/enable signal %t ns>>",($time/10**3));
		uut1.wb_write(1,`wbcfg_ctrl0,8'h0);
		uut1.wb_write(1,`wbcfg_ctrl0,8'h80);
		$display("<<Write One page write command %t ns>>",($time/10**3));
		uut1.wb_write(1,`wbcfg_ctrl1,`UFM_WRITE);
		uut1.wb_write(1,`wbcfg_ctrl1,8'h0);	//Write operand
		uut1.wb_write(1,`wbcfg_ctrl1,8'h0);
		uut1.wb_write(1,`wbcfg_ctrl1,8'h0);
		$display("<<Transmit 128bit data for UFM %t ns>>",($time/10**3));
		for (i=0;i<=15;i=i+1)
		begin
				uut1.wb_write(1,`wbcfg_ctrl1,cfg_data);
				cfg_data = cfg_data + 1'b1;
		end
		//
		#100;
		$display("<<Select a page for read operation %t ns>>",($time/10**3));
		uut1.wb_write(1,`wbcfg_ctrl1,`UFM_DIRECT_ADDR);
		uut1.wb_write(1,`wbcfg_ctrl1,8'h0);	//Write operand
		uut1.wb_write(1,`wbcfg_ctrl1,8'h0);
		uut1.wb_write(1,`wbcfg_ctrl1,8'h0);
		$display("<<SELECT UFM %t ns>>",($time/10**3));
		uut1.wb_write(1,`wbcfg_ctrl1,8'h40);
		$display("<<Write Page Address %t ns>>",($time/10**3));
		uut1.wb_write(1,`wbcfg_ctrl1,8'h0);
		uut1.wb_write(1,`wbcfg_ctrl1,8'h0);
		uut1.wb_write(1,`wbcfg_ctrl1,8'h0);
		$display("<<Write wbcfg_ctrl0 register with disable/enable signal %t>>",($time/10**3));
		uut1.wb_write(1,`wbcfg_ctrl0,8'h0);
		uut1.wb_write(1,`wbcfg_ctrl0,8'h80);
		$display("<<Read page %t ns>>",($time/10**3));
		uut1.wb_write(1,`wbcfg_ctrl1,`UFM_READ);
		uut1.wb_write(1,`wbcfg_ctrl1,8'h0);	//Write operand
		uut1.wb_write(1,`wbcfg_ctrl1,8'h0);
		uut1.wb_write(1,`wbcfg_ctrl1,8'h0);
		//$display("write wbcfg_ctrl0 register with disable/enable signal %t",($time/10**3));
		//uut1.wb_write(1,`wbcfg_ctrl0,8'h0);
		//uut1.wb_write(1,`wbcfg_ctrl0,8'h80);
		cfg_data =0;
		$display("<<Read UFM page %t ns>>",($time/10**3));
		for(i=0;i<=15;i=i+1)
		begin
				uut1.wb_cmp(1,`wbcfg_sts1,cfg_data);
				cfg_data = cfg_data + 1;  
				#1000;
		end
		#1000;
end
endtask			
endmodule
