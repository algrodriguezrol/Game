SPI Flash Controller with Wear-Leveling
===============================================================================

File List (26 files)
 1. /RD1102/docs/rd1102.pdf                           	 					--> RD1102 design document
    /RD1102/docs/rd1102_readme.txt                     						--> Read me file (this file)
 2. /RD1102/Project/spi_flash_controller_wl_top.lpf    						--> preference file for the design
    /RD1102/Project/spi_flash_wl_tb_tf.udo_example     						--> vital glitch removal example
 3. /RD1102/Simulation/verilog/rtl_verilog.do		       						--> verilog rtl simulation script
    /RD1102/Simulation/verilog/timing_verilog.do		   						--> verilog timing simulation script
 4. /RD1102/Source/verilog/spi_flash_controller_wl_top.v         	--> source file - top level
		/RD1102/Source/verilog/spi_flash_controller_wl_top_vhd.vhd   	--> source file - top level(Vhdl Wrapper file )
    /RD1102/Source/verilog/spi_ctrl_wb_int.v      								--> source file
    /RD1102/Source/verilog/spi_wear_leveling.v       							--> source file
    /RD1102/Source/verilog/wb_slave_to_master.v      							--> source file
    /RD1102/Source/verilog/readWriteSPIWireData.v        					--> source file
		/RD1102/Source/verilog/Ipexpress/page_valid_mem.lpc    				-->	source file
		/RD1102/Source/verilog/Ipexpress/page_valid_mem.v    					-->	source file
		/RD1102/Source/verilog/Ipexpress/phy_addr_mem.lpc							-->	source file
		/RD1102/Source/verilog/Ipexpress/phy_addr_mem.v								-->	source file
		/RD1102/Source/verilog/Ipexpress/sector_erase_cnt_memory.lpc	-->	source file
		/RD1102/Source/verilog/Ipexpress/sector_erase_cnt_memory.v		-->	source file
		/RD1102/Source/verilog/Ipexpress/ufm.lpc											-->	source file
		/RD1102/Source/verilog/Ipexpress/ufm.v												-->	source file
5. 	/RD1102/Testbench/verilog/spi_flash_wl_tb.v         					--> Testbench for simulation - top-level
    /RD1102/Testbench/verilog/spi_flash_model.v        						--> Testbench for simulation
    /RD1102/Testbench/verilog/wb_master_model.v        						--> Testbench for simulation

===================================================================================================
!!IMPORTANT NOTES:!!
1. Unzip the RD1102_revyy.y.zip file using the existing folder names, where yy.y is the current
   version of the zip file
2. If there is lpf file or lci file available for the reference design:
	3.1 copy the content of the provided lpf file to the <project_name>.lpf file under your ispLEVER project,
	3.2 use Constraint Files >> Add >> Exiting File to import the lpf to Diamond project and set it to be active,
	3.3 copy the content of the provided lct file to the <project_name>.lct under your cpld project.
4. If there is sty file (strategy file for Diamond) available for the design, go to File List tab on the left
   side of the GUI. Right click on Strategies >> Add >> Existing File. Then right click on the imported file
   name and select "Set as Active Strategy".

===================================================================================================
Using ispLEVER software
---------------------------------------------------------------------------------------------------
HOW TO CREATE A ISPLEVER OR ISPLEVER CLASSIC PROJECT:
1. Bring up ISPLEVER OR ISPLEVER CLASSIC software, in the GUI, select File >> New Project
2. In the New Project popup, select the Project location, provide a Project name, select Design Entry Type
   and click Next.
3. Use RD1102.pdf to see which device /speedgrade should be selected to achieve the desired timing result
4. Add the necessary source files from the RD1102\source directory, click Next
5. Click Finish. Now the project is successfully created.
6. Make sure the provided lpf or lct is used in the current directory.
7. The one_wire_top_with_wishbone_wrapper.vhd file is for the vhdl user.If the user prefers the vhdl language, he needs to creat a mixed 
   language project, add this vhdl wrapper file as the top file, and add the other verilog files as the source file.
---------------------------------------------------------------------------------------------------
HOW TO RUN SIMULATION FROM ISPLEVER OR ISPLEVER CLASSIC PROJECT:
1. Import the top-level testbench into the project as test fixture and associate with the device
	1.1 Import the rest as Testbench Dependency File by highligh and right click on the test bench file
2. In the Project Navigator, highlight the testbench file on the left-side panel, user will see 3
   simulation options on the right panel.
3. For functional simulation, double click on Verilog Functional Simulation with Aldec
   Active-HDL. Aldec simulator will be brought up, click yes to overwrite the existing file. The
   simulator will initialize and run for 1us.
4. Type "run -all" for verilog in the Console panel. A script similar to this
   will be in the Console panel:

     run -all
# KERNEL: 
# KERNEL: 
# KERNEL: 
# KERNEL: <<Test read/write user register>>
# KERNEL: <<Test read/write user register is over>>
# KERNEL: <<Write logic address map table>>
# KERNEL: Read the logic address map table
# KERNEL: 
# KERNEL: 
# KERNEL: 
# KERNEL: <<Erase every sector 2066780 ns>>
# KERNEL: <<Write the low byte of the physical address              2067860 ns>>
# KERNEL: <<Write the middle byte of the physical address              2068820 ns>>
# KERNEL: <<Write the high byte of the physical address              2069780 ns>>
# KERNEL: <<Write the low byte of the physical address              2072660 ns>>
# KERNEL: <<Write the middle byte of the physical address              2073620 ns>>
# KERNEL: <<Write the high byte of the physical address              2074580 ns>>
# KERNEL: <<Write the low byte of the physical address              2077460 ns>>
# KERNEL: <<Write the middle byte of the physical address              2078420 ns>>
# KERNEL: <<Write the high byte of the physical address              2079380 ns>>
# KERNEL: <<Write the low byte of the physical address              2082260 ns>>
# KERNEL: <<Write the middle byte of the physical address              2083220 ns>>
# KERNEL: <<Write the high byte of the physical address              2084180 ns>>
# KERNEL: <<Write the low byte of the physical address              2087060 ns>>
# KERNEL: <<Write the middle byte of the physical address              2088020 ns>>
# KERNEL: <<Write the high byte of the physical address              2088980 ns>>
# KERNEL: <<Write the low byte of the physical address              2091860 ns>>
# KERNEL: <<Write the middle byte of the physical address              2092820 ns>>
# KERNEL: <<Write the high byte of the physical address              2093780 ns>>
# KERNEL: <<Write the low byte of the physical address              2096660 ns>>
# KERNEL: <<Write the middle byte of the physical address              2097620 ns>>
# KERNEL: <<Write the high byte of the physical address              2098580 ns>>
# KERNEL: <<Write the low byte of the physical address              2101460 ns>>
# KERNEL: <<Write the middle byte of the physical address              2102420 ns>>
# KERNEL: <<Write the high byte of the physical address              2103380 ns>>
# KERNEL: <<Read the erase times memory              2106340 ns>>
# KERNEL: <<Write the bulk erase command              2108860 ns>>
# KERNEL: <<Read the erase times memory              2118980 ns>>
# KERNEL: <<Test the page program command              2121500 ns>>
# KERNEL: <<Write the physical address              2122460 ns>>
# KERNEL: <<Write the low byte of the physical address              2122460 ns>>
# KERNEL: <<Write the middle byte of the physical address              2123420 ns>>	
# KERNEL: <<Write the high byte of the physical address              2124380 ns>>	
# KERNEL: <<Write one page data for the selected sector              2125340 ns>>
# KERNEL: <<Read the page valid memory	             2372100 ns>>
# KERNEL: <<Test wear leveling is over:              2454980 ns>>	
# KERNEL: 
# KERNEL: 
# KERNEL: 
# KERNEL: Initialization efb module
# KERNEL: <<EFB initialization finished              2456440 ns>>
# KERNEL: <<Enable UFM              2456440 ns>>
# KERNEL: <<SELECT A PAGE FOR WRITE OPERATION              2457820 ns>>
# KERNEL: <<SELECT UFM              2458140 ns>>
# KERNEL: <<Write Page Address              2458220 ns>>
# KERNEL: <<write wbcfg_ctrl0 register with disable/enable signal              2458460 ns>>
# KERNEL: <<Write One page write command              2458620 ns>>
# KERNEL: <<Transmit 128bit data for UFM              2458940 ns>>
# KERNEL: <<Select a page for read operation              2460320 ns>>
# KERNEL: <<SELECT UFM              2460620 ns>>
# KERNEL: <<Write Page Address              2460700 ns>>
# KERNEL: <<Write wbcfg_ctrl0 register with disable/enable signal              2460940>>
# KERNEL: <<Read page              2461100 ns>>
# KERNEL: <<Read UFM page              2461420 ns>>
# KERNEL: 
# KERNEL: 
# KERNEL: 
# RUNTIME: RUNTIME_0070 spi_flash_wl_tb.v (319): $stop called.

5. For timing simulation, double click on Verilog Post-Route Timing Simulation with Aldec
   Active-HDL. Similar message will be shown in the console panel of the Aldec Active-HDL simulator.
   4.1 Run all to see the complete simulation
   4.1 In timing simulation you may see some warnings about narrow widths or vital glitches. These
       warnings can be ignored.
   4.2 Vital glitches can be removed by added a vsim command in the udo file. Use the udo.example
       under the \project directory

===================================================================================================
Using Diamond Software
---------------------------------------------------------------------------------------------------
HOW TO CREATE A PROJECT IN DIAMOND:
1. Launch Diamond software, in the GUI, select File >> New Project, click Next
2. In the New Project popup, select the Project location and provide a Project name and implementation
   name, click Next.
3. Add the necessary source files from the RD1102\source directory, click Next
4. Select the desired part and speedgrade. You may use RD1102.pdf to see which device and speedgrade
   can be selected to achieve the published timing result
5. Click Finish. Now the project is successfully created.
6. MAKE SURE the provided lpf and/or sty files are used in the current directory.

----------------------------------------------------------------------------------------------------
HOW TO RUN SIMULATION UNDER DIAMOND:
1. Bring up the Simulation Wizard under the Tools menu
2. Next provide a name for simulation project, and select RTL or post-route simulation
	2.1 For post-route simulation, must export verilog or vhdl simulation file after Place and Route
3. Next add the test bench files from the RD1102\TestBench directory
	3.1 For VHDL, make sure the top-level test bench is last to be added
4. Next click Finish, this will bring up the Aldec simulator automatically
5. In Aldec environment, you can manually activate the simulation or you can use a script
	5.1 Use the provided script in the RD1102\Simulation\<language> directory
	  a. For functional simulation, change the library name to the device family
	  	i) MachXO2: ovi_machxo2 for verilog, machxo2 for vhdl
	  	ii) MachXO: ovi_machxo for verilog, machxo for vhdl
	  	iii)XP2: ovi_xp2 for verilog, xp2 for vhdl
		b. For POST-ROUTE simulation, open the script and change the following:
			i) The sdf file name and the path pointing to your sdf file.
		   The path usually looks like "./<implementation_name>/<sdf_file_name>.sdf"
		  ii) Change the library name using the library name described above
		c. Click Tools > Execute Macro and select the xxx.do file to run the simulation
		d. This will run the simulation until finish
	5.2 Manually activate the simulation
		a. Click Simulation > Initialize Simulation
		b. Click File > New > Waveform, this will bring up the Waveform panel
		c. Click on the top-level testbench, drag all the signals into the Waveform panel
		d. At the Console panel, or "run -all" for Verilog
		   simulation
		e. For timing simulation, you must manually add
		   -sdfmax uut0="./spi_flash_controller_wl_top/spi_flash_controller_wl_top_spi_flash_controller_wl_top_vo.sdf"
		   into the asim or vsim command. Use the command in timing_xxx.do as an example
6. The simulation result will be similar to the one described in ispLEVER simulation section.



