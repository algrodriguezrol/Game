/**
 * 
 */

#include "soc-hw.h"
//---------------------------------------------------------------------------
// LCD Functions
//--------------
//-------------------------------------------------------------
void writeCharlcd (char letter) 
{
	//para imprimir caracteres en la lcd, se usa la memoria
	//interna, la cual ya tiene configurada el mapa de caracteres
	//y su dirección corresponde a columnas dadas por lo primeros cuatro bits y a las filas, los otros 4 bits.
	//lo que se hace es pasar una mascara para cada caso, y luego
	//enviar cada posición como un comando.	
	char highnib;
	char lownib;
	highnib = letter&0xF0;
	lownib = letter&0x0F;

	i2c_write_lcd(ADDRESS_I2C_LCD,highnib|0b00001001);
	i2c_write_lcd(ADDRESS_I2C_LCD,highnib|0b00001101);
	i2c_write_lcd(ADDRESS_I2C_LCD,highnib|0b00001001);  

	i2c_write_lcd(ADDRESS_I2C_LCD,(lownib<<4)|0b00001001);
	i2c_write_lcd(ADDRESS_I2C_LCD,(lownib<<4)|0b00001101);
	i2c_write_lcd(ADDRESS_I2C_LCD,(lownib<<4)|0b00001001);

	msleep(2);
}

void writeCommandlcd (char command) 
{
	char highnib;
	char lownib;
	highnib = command&0xF0;
	lownib = command&0x0F;

	i2c_write_lcd(ADDRESS_I2C_LCD,highnib|0b00001000);
	i2c_write_lcd(ADDRESS_I2C_LCD,highnib|0b00001100);
	i2c_write_lcd(ADDRESS_I2C_LCD,highnib|0b00001000);  

	i2c_write_lcd(ADDRESS_I2C_LCD,(lownib<<4)|0b00001000);
	i2c_write_lcd(ADDRESS_I2C_LCD,(lownib<<4)|0b00001100);
	i2c_write_lcd(ADDRESS_I2C_LCD,(lownib<<4)|0b00001000);

	msleep(2);
}

void writeStringlcd (char *str) {
	char *c = str;
	while(*c) {
		writeCharlcd(*c);
		c++;
	}
}

void lcdInit () 
{  
	i2c_write_lcd(ADDRESS_I2C_LCD,0b00111000);
	i2c_write_lcd(ADDRESS_I2C_LCD,0b00111100);
	i2c_write_lcd(ADDRESS_I2C_LCD,0b00111000);
	nsleep(4500000);
	i2c_write_lcd(ADDRESS_I2C_LCD,0b00111000);
	i2c_write_lcd(ADDRESS_I2C_LCD,0b00111100);
	i2c_write_lcd(ADDRESS_I2C_LCD,0b00111000);
	nsleep(4500000);
	i2c_write_lcd(ADDRESS_I2C_LCD,0b00111000);
	i2c_write_lcd(ADDRESS_I2C_LCD,0b00111100);
	i2c_write_lcd(ADDRESS_I2C_LCD,0b00111000);
	nsleep(200000);
	i2c_write_lcd(ADDRESS_I2C_LCD,0b00101000);
	i2c_write_lcd(ADDRESS_I2C_LCD,0b00101100);
	i2c_write_lcd(ADDRESS_I2C_LCD,0b00101000);
	nsleep(50000);
	i2c_write_lcd(ADDRESS_I2C_LCD,0b00101000);
	i2c_write_lcd(ADDRESS_I2C_LCD,0b00101100);
	i2c_write_lcd(ADDRESS_I2C_LCD,0b00101000);
	nsleep(50000);
	i2c_write_lcd(ADDRESS_I2C_LCD,0b10001000);
	i2c_write_lcd(ADDRESS_I2C_LCD,0b10001100);
	i2c_write_lcd(ADDRESS_I2C_LCD,0b10001000);
	nsleep(50000);
	i2c_write_lcd(ADDRESS_I2C_LCD,0b00001000);
	i2c_write_lcd(ADDRESS_I2C_LCD,0b00001100);
	i2c_write_lcd(ADDRESS_I2C_LCD,0b00001000);
	nsleep(50000);
	i2c_write_lcd(ADDRESS_I2C_LCD,0b11001000);
	i2c_write_lcd(ADDRESS_I2C_LCD,0b11001100);
	i2c_write_lcd(ADDRESS_I2C_LCD,0b11001000);
	msleep(2);
}

//---------------------------------------------------------------------------
// LCD Commands
//---------------------------------------------------------------------------

void clearDisplay() 
{	writeCommandlcd(0b00000001);
}

void returnHome()
{	writeCommandlcd(0b00000010);
}

void entryModeSet2()
{  	writeCommandlcd(0b00000110);
}

void entryModeSet()
{	writeCommandlcd(0b00000111);
}

void entryModeSet3()
{	writeCommandlcd(0b00000100);
}

void entryModeSet4()
{	writeCommandlcd(0b00000101);
}

void displayOff()
{	writeCommandlcd(0b00001000);
}

void displayOn()
{	writeCommandlcd(0b00001111);
}

void cursorShiftRight()
{	writeCommandlcd(0b00010100);
}

void cursorShiftLeft()
{	writeCommandlcd(0b00010000);
}

void displayShiftRight()
{	writeCommandlcd(0b00011100);
}

void displayShiftLeft()
{	writeCommandlcd(0b00011000);
}

void functionSet()
{	writeCommandlcd(0b00101000);
}

void displayAddress(uint8_t col, uint8_t row){
	int row_offsets[] = { 0x00, 0x40, 0x14, 0x54 };
	if(row>2){
		row = 2-1;
	}
        writeCommandlcd (0x80|(col + row_offsets[row]));
}
//---------------------------------------------------------------------------
// ASCII Converter
// para los datos obtenidos de los modulos, ejemplo WIFI
//---------------------------------------------------------------------------

char asciiConv (char number)
{	return number+48;
}

char asciiConvLcd_Dig1 (char number)
{	char highnib;
	char lownib;
	highnib = number&0xF0;
	lownib = number&0x0F;
	return (lownib)+48;
}

char asciiConvLcd_Dig2 (char number)
{	char highnib;
	char lownib;
	highnib = number&0xF0;
	lownib = number&0x0F;
	return (highnib >> 4)+48;
}


//---------------------------------------------------------------------------
// Main project 1
//---------------------------------------------------------------------------

int main(){

	//habilito interruciones y la mascara de interruciones
	irq_enable();
	irq_set_mask(0x01);

	//Inicializando el modulo WiFi	
	init_wifi(); 

	//Inicializando el modulo de la pantalla LCD 16x2
	lcdInit();
	clearDisplay();
	entryModeSet2();
	returnHome();

while(1){

	//inicio: bloque con lectura de interrupción
	//------------------------------------------
/*	int secInterrup = 0 ; //contador para segundo en la pantalla
	switch (irqLeer()) {
	  case 1:
		if (secInterrup < 2){ //controlar que solo se muestre en dos ciclos
			writeStringlcd("interrupcion");
			secInterrup++;
		}
		else{	
			secInterrup = 0;
			irqEscribir(0);
		}

		break;
		  
	  default:
		writeStringlcd("Secador Cafe");
		break;
 	 }
*/	//fin: bloque lectura interrución 
	//-------------------------------------------	

	writeStringlcd("Juego Digital");
	displayAddress(0,1);
//	writeCharlcd(irqLeer());	


	//writeCharlcd('T');
	//writeCharlcd(0xDF); //para imprimir el cáracter º 
	//writeStringlcd(": no data");
	
	msleep (1000);
	returnHome();
	}
}
