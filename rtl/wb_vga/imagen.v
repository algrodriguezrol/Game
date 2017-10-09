module imagen(
	input datavga,
	output hsync,vsync, 
	output [2:0] red,
	output [2:0] gren,
	output [1:0] blu 
  



);


vga #() vga0 (
	  .hsync(       hsync     ),
          .vsync(     vsync    )
           );




endmodule
