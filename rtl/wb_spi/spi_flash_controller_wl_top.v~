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
`timescale 1ns/1ps
module spi_flash_controller_wl_top
			 (
			 	//input 				ufm_sn,
			 	input					ufm_sel,		
			 	input 					wb_clk_i,
			 	input 					wb_rst_i,
			 	//slave wishbone interface
			 	input 		 			wb_sel_i,
			 	input			 		wb_we_i,
			 	input[7:0] 				wb_adr_i,
			 	input[7:0] 				wb_dat_i,
			 	output[7:0] 				wb_dat_o,
			 	input 					wb_stb_i,
			 	input					wb_cyc_i,
			 	output reg				wb_ack_o,
			  	output					wb_int_req,
				//Spi interface
			 	output 					spiClkOut,
				input  					spiDataIn,
				output 					spiDataOut,
				output					spiCsn
			 );
//signal declare and definition
wire[7:0]		txDataOut;
wire				txDataFull;
wire 				txDataFullclr;
wire				txDataEmpty;
wire[7:0] 	rxDataIn;
wire  			rxDataRdySet;
wire 				tx_cmd_wren;
wire[7:0]		cmd;
wire[7:0]		logical_addr_l;
wire[7:0]		logical_addr_m;
wire[7:0]		logical_addr_h;
wire[7:0]		physical_addr_l;
wire[7:0]		physical_addr_m;
wire[7:0]		physical_addr_h;
wire 				wr_phy_addr_l;
wire 				wr_phy_addr_m;
wire 				wr_phy_addr_h,wr_phy_addr_h_non;
wire[2:0] 	erase_time_mem_addr;
wire 				erase_time_mem_rden;
wire[23:0] 	erase_mem_rdata;
wire[10:0] 	phy_addr;
wire 				phy_addr_rden;
wire[15:0] 	phy_addr_rdata;
wire[7:0]		page_valid_addr;
wire				page_valid_rden;
wire[7:0]		rd_page_data;
wire[7:0]		SPI_clk_delay;
wire				ufm_sel;
wire[7:0] 	wbm_adr_o;
wire[7:0] 	wbm_dat_i;
wire[7:0] 	wbm_dat_o;
wire 				wbm_sel_o;
wire 				wbm_cyc_o;
wire 				wbm_stb_o;
wire 				wbm_we_o;
wire 				wbm_ack_i;
wire 				wbm_rty_i;
wire 				wbm_err_i;
wire				wbm_ack_o;
//--
wire[7:0] 	wb_dat_o_from_ufm;
wire				wb_ack_o_from_ufm;
wire[7:0] 	wb_dat_o_from_controller;
wire				wb_ack_o_from_controller;
wire				wbc_ufm_irq;
assign 			wb_int_req =wbc_ufm_irq;
//
//assign 		wb_ack_o = 1'b1 ? wb_ack_o_from_ufm : (1'b1 ? wb_ack_o_from_controller : 1'b0);
always @( wb_ack_o_from_ufm,wb_ack_o_from_controller )
begin
		if( wb_ack_o_from_ufm )
		begin
				wb_ack_o	<= 1'b1;
		end
		else if( wb_ack_o_from_controller )
		begin
				wb_ack_o	<= 1'b1;
		end
		else
		begin
				wb_ack_o	<= 1'b0;
		end
end
//--
assign		wb_dat_o = wb_ack_o_from_ufm?wb_dat_o_from_ufm:(wb_ack_o_from_controller?wb_dat_o_from_controller:wb_dat_o);
spi_ctrl_wb_int    uut0
									(
									//global interface
									.wb_clk_i				(	wb_clk_i 									),
									.wb_rst_i				( wb_rst_i 									),
									//slave wishbone interface
									.wb_sel_i				( wb_sel_i  								),
									.wb_wr_i				( wb_we_i   								),
									.wb_adr_i				( wb_adr_i  								),
									.wb_dat_i				( wb_dat_i  								),
									.wb_dat_o				( wb_dat_o_from_controller  ),
									.wb_stb_i				( wb_stb_i &(~ufm_sel)  		),
									.wb_ack_o				( wb_ack_o_from_controller  ),

									//Spi tx data
									.txDataOut			( txDataOut 		),
									.txDataFull			( txDataFull 		),
									.txDataFullClr	( txDataFullclr ),
									.txDataEmpty		( txDataEmpty 	),

									//Spi rx data
									.rxDataIn				( rxDataIn ),
									.rxDataRdySet		( rxDataRdySet ),

									//Interface to command check block
									.tx_cmd_wren		( tx_cmd_wren ),
									.cmd						( cmd ),

									//Interface to logical address map to physical address
									//.logical_addr_l	( logical_addr_l ),
									.logical_addr_m	( logical_addr_m ),
									.logical_addr_h	( logical_addr_h ),

									.physical_addr_l( physical_addr_l ),
									.physical_addr_m( physical_addr_m ),
									.physical_addr_h( physical_addr_h ),

									//.wr_phy_addr_l	( wr_phy_addr_l ),
									//.wr_phy_addr_m	( wr_phy_addr_m ),
									.wr_phy_addr_h	( wr_phy_addr_h ),
									.wr_phy_addr_h_non(wr_phy_addr_h_non),

									//Interface  to sector erase time address memory
									.erase_time_mem_addr( erase_time_mem_addr ),
									.erase_time_mem_rden( erase_time_mem_rden ),
									.erase_mem_rdata		( erase_mem_rdata		  ),

									//Interface to physical address memory
									//.phy_addr						( phy_addr				),
									//.phy_addr_rden			( phy_addr_rden	  ),
									.phy_addr_rdata			( phy_addr_rdata  ),

									.page_valid_addr		( page_valid_addr ),
									.page_valid_rden		( page_valid_rden ),
									.rd_page_data				( rd_page_data		),
									//.ufm_sel				( ufm_sel ),
									.SPI_clk_delay			( SPI_clk_delay   )
									);
//
spi_wear_leveling uut1
									(
									.wb_clk_i( wb_clk_i ),
									.wb_rst_i( wb_rst_i ),

									.tx_cmd_wren( tx_cmd_wren ),
									.cmd				( cmd				  ),

									//.logical_addr_l( logical_addr_l ),
									.logical_addr_m( logical_addr_m ),
									.logical_addr_h( logical_addr_h ),

									.physical_addr_l( physical_addr_l ),
									.physical_addr_m( physical_addr_m ),
									.physical_addr_h( physical_addr_h ),

									//.wr_phy_addr_l( wr_phy_addr_l ),
									//.wr_phy_addr_m( wr_phy_addr_m ),
									.wr_phy_addr_h	( wr_phy_addr_h ),
									.wr_phy_addr_h_non( wr_phy_addr_h_non ),

									//interface to erase times memory
									.erase_mem_rd_addr_from_host( erase_time_mem_addr ),
									.erase_mem_rden_from_host		( erase_time_mem_rden ),
									.erase_mem_rd_data					( erase_mem_rdata		  ),

									//.phy_addr_rd_from_host	( phy_addr			 ),
									//.phy_addr_rden_from_host( phy_addr_rden	 ),
									.phy_addr_rdata					( phy_addr_rdata ),

									.page_valid_rd_addr_from_host	( page_valid_addr  ),
									.page_rden_from_host					( page_valid_rden  ),
									.rd_page_data								  ( rd_page_data		 )
									);
//
readWriteSPIWireData uut2
										(
										.clk						( wb_clk_i ),
										.clkDelay				( SPI_clk_delay ),
										.rst						( wb_rst_i ),
										.rxDataOut			( rxDataIn ),
										.rxDataRdySet		( rxDataRdySet ),
										.spiClkOut			( spiClkOut	  ),
										.spiDataIn			( spiDataIn	  ),
										.spiDataOut			( spiDataOut	),
										.spiCsn					( spiCsn			),
										.txDataEmpty		( txDataEmpty	  ),
										.txDataFull			( txDataFull		),
										.txDataFullClr	( txDataFullclr ),
										.txDataIn				( txDataOut			)
										);
//
wb_slave_to_master uut3
									(
									.wbs_clk_i				( wb_clk_i ),
		  						.wbs_rst_i				( wb_rst_i ),
									 	//slave wishbone interface
									.wbs_sel_i				( wb_sel_i ),
									.wbs_wr_i					( wb_we_i	),
									.wbs_adr_i				( wb_adr_i ),
									.wbs_dat_i				( wb_dat_i ),
									.wbs_dat_o				( wb_dat_o_from_ufm ),
									.wbs_stb_i				( wb_stb_i & ufm_sel),
									.wbs_cyc_i				( wb_cyc_i),
									.wbs_ack_o				( wb_ack_o_from_ufm ),

									//wishbone master interface
      						.wbm_adr_o				( wbm_adr_o ),
      						.wbm_dat_i				( wbm_dat_i ),
      						.wbm_dat_o				( wbm_dat_o ),
      						.wbm_sel_o				( wbm_sel_o ),
      						.wbm_cyc_o				( wbm_cyc_o ),
      						.wbm_stb_o				( wbm_stb_o ),
      						.wbm_we_o					( wbm_we_o	),
      						.wbm_ack_i				( wbm_ack_o ),
      						.wbm_rty_i				(  ),
      						.wbm_err_i				(  )
      						);
//--
ufm  	uut4
			(
			.wb_clk_i						( wb_clk_i 	),
			.wb_rst_i						( wb_rst_i 	),
			.wb_cyc_i						( wbm_cyc_o ),
			.wb_stb_i						( wbm_stb_o ),//ufm_sel),//),
			.wb_we_i						( wbm_we_o 	),
			.wb_adr_i						( wbm_adr_o ),
    	.wb_dat_i						( wbm_dat_o ),
    	.wb_dat_o						( wbm_dat_i ),
    	.wb_ack_o						( wbm_ack_o	),    	
  	  .wbc_ufm_irq				( wbc_ufm_irq	)
    	);

/*ufm  	uut4
			(
			.wb_clk_i						( wb_clk_i 	),
			.wb_rst_i						( wb_rst_i 	),
			.wb_cyc_i						( wb_cyc_i ),
			.wb_stb_i						( wb_stb_i ),//& ufm_sel),
			.wb_we_i						( wb_we_i 	),
			.wb_adr_i						( wb_adr_i ),
    	.wb_dat_i						( wb_dat_i ),
    	.wb_dat_o						( wb_dat_o ),
    	.wb_ack_o						( wb_ack_o	),
//    	.ufm_sn							( ufm_sn 			)
  	  .wbc_ufm_irq				( wbc_ufm_irq	)
    	);*/
endmodule
