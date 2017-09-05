#include "soc-hw.h"

uart_t  *uart0  = (uart_t *)   0x20000000;
timer_t *timer0 = (timer_t *)  0x30000000;
gpio_t  *gpio0  = (gpio_t *)   0x40000000;
//uart_t  *uart1  = (uart_t *)   0x20000000;
spi_t   *spi0   = (spi_t *)    0x50000000;
i2c_t   *i2c0   = (i2c_t *)    0x60000000;

isr_ptr_t isr_table[32];

//Variables de uso global para el uso de la interrupción

void tic_isr();
/******************************************
 * IRQ handling
 * interrupciones
*/
void isr_null()
{
}

void irq_handler(uint32_t pending)
{
	switch(pending){
		case 0x01:
		       	lcdInit();
			clearDisplay();
			entryModeSet2();
			returnHome();
			writeStringlcd("interrupción");
			displayAddress(0,1);
			writeStringlcd("WiFi");
			msleep (1000);		
			break;
		default:
			break;
	}

}

void isr_init()
{
	int i;
	for(i=0; i<32; i++)
		isr_table[i] = &isr_null;
}

void isr_register(int irq, isr_ptr_t isr)
{
	isr_table[irq] = isr;
}

void isr_unregister(int irq)
{
	isr_table[irq] = &isr_null;
}

/***************************************************************************
 * TIMER Functions
 */

void msleep(uint32_t msec)
{
	uint32_t tcr;

	// Use timer0.1
	timer0->compare1 = (FCPU/1000)*msec;
	timer0->counter1 = 0;
	timer0->tcr1 = TIMER_EN | TIMER_IRQEN;
	do {
		//halt();
 		tcr = timer0->tcr1;
 	} while ( ! (tcr & TIMER_TRIG) );
}

void nsleep(uint32_t nsec)
{
	uint32_t tcr;

	// Use timer0.1
	//timer0->compare1 = (nsec/10);
	timer0->compare1 = (FCPU/1000000000)*nsec;
	timer0->counter1 = 0;
	timer0->tcr1 = TIMER_EN| TIMER_IRQEN;

	do {
		//halt();
 		tcr = timer0->tcr1;
 	} while ( ! (tcr & TIMER_TRIG) );
}
uint32_t tic_msec;

void tic_isr()
{
	tic_msec++;
	timer0->tcr0     = TIMER_EN | TIMER_AR | TIMER_IRQEN;
}

void tic_init()
{
	tic_msec = 0;

	// Setup timer0.0
	timer0->compare0 = (FCPU/10000);
	timer0->counter0 = 0;
	timer0->tcr0     = TIMER_EN | TIMER_AR | TIMER_IRQEN;

	isr_register(1, &tic_isr);
}

/***************************************************************************
 * UART Functions
 */

void uart_init()
{
}

void uart_putstr(char *str)
{
	char *c = str;
	while(*c) {
		uart_putchar(*c);
		c++;
	}
}

char uart_getchar()
{   
	while (! (uart0->ucr & UART_DR)) ;
	return uart0->rxtx;
}

void uart_putchar(char c)
{
	while (uart0->ucr & UART_BUSY) ;
	uart0->rxtx = c;
}
/*******************************
 **** FUNCIONES PARA WIFI   ****
 *******************************/

void init_wifi(){ //configurar el modulo como estación con puerto 80
	//comando de prueba
	int c=0;
	while(c==0){
		uart_gen_putstr(" AT+RST\r\n");
		c=ok();
	}
	
	msleep(200);
	c = 0;
	while(c==0){  //con el siguiente comando aceptamos que el modulo tenga multiples conexiones
		uart_gen_putstr("AT+CIPMUX=1\r\n");
		c = ok();
	}
	msleep(10);
	c = 0;
	
	//Se configura el modulo como un servidor con puerto 80
	while (c==0){
		uart_gen_putstr("AT+CIPSERVER=1,80\r\n");
		c = ok();
	}

	//configurar Servidor como un acces point
	//con esto no spodemos conectar desde cualquier dispositivo
	msleep(10);
	c=0;
	while(c==0){
		uart_gen_putstr("AT+CWSAP_CUR=\"SecadorCafe\",\"cafe1234\",5,3\r\n");
		c=ok();
	}


	//inicio segmento para obtener dirección IP
	msleep(10);
	c=0;
	while(c==0){
		uart_gen_putstr("AT+CIFSR\r\n");
		c=ok();
	}//fin de segmento
}


	//funciones con la secuencia para enviar datos a travez del periferico UART a el modulo ESP8266
void wifi_putchar2(char a){
	int c = 0; 	  
	while(c == 0){
		uart_gen_putstr("AT+CIPSEND=0,1\r\n");
		msleep(10);
		uart_gen_putchar(a);
		c = ok();
		msleep(100);
	}
	c = 0; 	  
	while(c == 0){
		uart_gen_putstr("AT+CIPCLOSE=0\r\n");
		c = ok();
	}
}

void wifi_putstr(char *a){
	int c = 0;   
	char *cc = a;
	int counter = 0;
	while(*cc) {
		uart_putchar(*cc);
		cc++;
		counter ++;
	}

	while(c == 0){
		uart_gen_putstr("AT+CIPSEND=0,");
		uart_gen_putstr(counter);
		uart_gen_putstr("\r\n");
		msleep(10);
		uart_gen_putchar(a);
		c = ok();
		msleep(100);
	}
	c = 0; 	  
	while(c == 0){
		uart_gen_putstr("AT+CIPCLOSE=0\r\n");
		c = ok();
	}
}
	
char wifi_getchar2(){
	char c='\n';
	int i=0;
	for(i=0;i<20;i++){
		c = uart_one_getchar();
		if (c ==':'){
			c = uart_one_getchar();
			return c;
		}
	}
	return '\n';
}
	//función para comprobar que el comando fue enviado correctamente.
int ok(){
	int i=0;
	char a;
	for(i=0;i<30;i++){
		a = uart_one_getchar();
		if(a=='K'){
			return 1;
		}
	}
	return 0;

}

void uart_gen_putstr(char *str)
{
	char *c = str;
	while(*c) {
		uart_gen_putchar(*c);
		c++;
	}
}

void uart_gen_putchar(char c)
{
	 uart_putchar(c);
}

void uart_one_putchar(char c)
{
	while (uart0->ucr & UART_BUSY) ; 
	uart0->rxtx = c;
}

char uart_one_getchar()
{   
	while (! (uart0->ucr & UART_DR)) ;
	return uart0->rxtx;
}


/********************
 * SPI0 Funtions
 */

void spi_putchar(char c){
	while (spi0->cs & SPI_BUSY) //
	spi0->rxtx=c;		
}
void spi_init();
char spi_getchar();


/******************************
 ****   I2C Functions      ****
 ******************************/

void start_Read (int r)
{  i2c0->startRead = r;
}
void start_Write (int w)
{  i2c0->startWrite = w;
}
void start_Write_lcd (int wlcd)
{  i2c0->startWrite_lcd = wlcd;
}
void rw(int data_rw)
{  i2c0->rw = data_rw;
}

void i2c_write (int dirI2C, int dirIntern, int data)
{		
	i2c0->data = ((dirI2C<<16)|(dirIntern<<8)|data);	
	rw(0);
	start_Write(1);
   	nsleep(20000);
   	start_Write(0);
	
        while(!((i2c0->availWrite)==0x01));
}

void i2c_write_lcd (int dirI2C, int data)
{		
	i2c0->data = ((dirI2C<<8)|data);
	rw(2);
	start_Write_lcd(1);
   	nsleep(20000);
   	start_Write_lcd(0);

        while(!((i2c0->availWrite)==0x01));
}

char i2c_read (int dirI2C, int dirIntern)
{  
	i2c0->data = ((dirI2C<<15)|(dirIntern<<7)|dirI2C);
	rw(1);
	start_Read(1);
   	nsleep(20000);
	start_Read(0);

	while(!((i2c0->availRead)==0x05));

	return i2c0->i2c_data_out;
}
