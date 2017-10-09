`timescale 1ns / 1ps
// Divisor de reloj para la nexys4, para converitir el reloj de i2c 
// a un rango permitido por el periférico
//
//////////////////////////////////////////////////////////////////////////////////
module divisor_frecuencia1(
    	input clk,
	//input divisor, 
    	output reg mclk
);

reg [2:0] contador;
//reg [2:0] mclko;

initial begin	 
contador<= 0;
mclk<=0;
//mclko<=0;
//assign mclk = mclko;
end

always @(posedge clk) begin
    contador <= contador + 1;
      if(contador == 1) begin
        mclk<= ~mclk; //genera la señal de reloj
        contador <= 0; 	//reset del contador
      end
end

endmodule 
