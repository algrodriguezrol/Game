#ifndef SPIKEHW_H
#define SPIKEHW_H

#define PROMSTART 0x00000000
#define RAMSTART  0x00000800
#define RAMSIZE   0x400
#define RAMEND    (RAMSTART + RAMSIZE)

#define RAM_START 0x40000000
#define RAM_SIZE  0x04000000

#define FCPU      100000000

#define UART_RXBUFSIZE 32

// ******************************************************************************
// Register LCD
// ******************************************************************************

#define ADDRESS_I2C_LCD		0x27

/****************************************************************************
 * Types
 */
typedef unsigned int  uint32_t;    // 32 Bit
typedef signed   int   int32_t;    // 32 Bit

typedef unsigned char  uint8_t;    // 8 Bit
typedef signed   char   int8_t;    // 8 Bit

/****************************************************************************
 * Interrupt handling
 */
typedef void(*isr_ptr_t)(void);

void     irq_enable();
void     irq_disable();
void     irq_set_mask(uint32_t mask);
uint32_t irq_get_mak();

void     isr_init();
void     isr_register(int irq, isr_ptr_t isr);
void     isr_unregister(int irq);

/****************************************************************************
 * General Stuff
 */
void     halt();
void     jump(uint32_t addr);


/****************************************************************************
 * Timer
 */
#define TIMER_EN     0x08    // Enable Timer
#define TIMER_AR     0x04    // Auto-Reload
#define TIMER_IRQEN  0x02    // IRQ Enable
#define TIMER_TRIG   0x01    // Triggered (reset when writing to TCR)

typedef struct {
	volatile uint32_t tcr0;
	volatile uint32_t compare0;
	volatile uint32_t counter0;
	volatile uint32_t tcr1;
	volatile uint32_t compare1;
	volatile uint32_t counter1;
} timer_t;
void sleep(int msec);
void msleep(uint32_t msec);
void nsleep(uint32_t nsec);

void prueba();
void tic_init();


/***************************************************************************
 * GPIO0
 */
/*typedef struct {
	volatile uint32_t ctrl;
	volatile uint32_t dummy1;
	volatile uint32_t dummy2;
	volatile uint32_t dummy3;
	volatile uint32_t in;
	volatile uint32_t out;
	volatile uint32_t oe;
} gpio_t;*/

typedef struct {
	volatile uint32_t leer;
	volatile uint32_t escribir;
	volatile uint32_t dir;
} gpio_t;


/***************************************************************************
 * UART0
 */
#define UART_DR   0x01                    // RX Data Ready
#define UART_ERR  0x02                    // RX Error
#define UART_BUSY 0x10                    // TX Busy

typedef struct {
   volatile uint32_t ucr;
   volatile uint32_t rxtx;
} uart_t;

void uart_init();
void uart_putchar(char c);
void uart_putstr(char *str);
char uart_getchar();


void uart_gen_putstr(char *str);
void uart_gen_putchar(char c);
void uart_one_putchar(char c);
char uart_one_getchar();

void init_wifi();
void wifi_putchar2(char a);
void wifi_putstr(char *a);
char wifi_getchar2();
int ok();

/***************************************************************************
 * SPI0
 */

#define SPI_BUSY 0x01
	//Estructura del wb_spi

typedef struct {
   volatile uint32_t rxtx;
   volatile uint32_t run;
   volatile uint32_t cs;
   volatile uint32_t nop2;
   volatile uint32_t divisor;
} spi_t;

	//Funciones puestas previamente
void spi_init();
void spi_putchar(char c);
char spi_getchar();

	//Funciones para el lector de tarjetas SD
void spi_init_sd();



/***************************************************************************
 * I2C0
 */

typedef struct {  
   volatile uint32_t i2c_data_out;
   volatile uint32_t availWrite;
   volatile uint32_t availRead;	
   volatile uint32_t rw;
   volatile uint32_t data;
   volatile uint32_t startRead;
   volatile uint32_t startWrite;
   volatile uint32_t startWrite_lcd;
}i2c_t;

void i2c_write (int dirI2C, int dirIntern, int data);
char i2c_read (int dirI2C, int dirIntern);
void start_Read (int num);
void start_Write (int num);
void start_Write_lcd (int num);
void rw(int data_rw);


/***************************************************************************
 * Pointer to actual components
 */
extern timer_t  *timer0;
extern uart_t   *uart0; 
extern gpio_t   *gpio0; 
extern uint32_t *sram0; 
extern i2c_t *i2c0;

#endif // SPIKEHW_H
