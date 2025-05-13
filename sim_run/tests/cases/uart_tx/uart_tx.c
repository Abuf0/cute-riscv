#include "datatype.h"
#include "uart.h"
#include "stdio.h"
int main (void)
{
  t_ck_uart_device uart0 = {0xFFFF};

  t_ck_uart_cfig   uart_cfig;

  uart_cfig.baudrate = BAUD;       // any integer value is allowed
  uart_cfig.parity = PARITY_NONE;     // PARITY_NONE / PARITY_ODD / PARITY_EVEN
  uart_cfig.stopbit = STOPBIT_1;      // STOPBIT_1 / STOPBIT_2
  uart_cfig.wordsize = WORDSIZE_8;    // from WORDSIZE_5 to WORDSIZE_8
  uart_cfig.txmode = ENABLE;          // ENABLE or DISABLE

  // open UART device with id = 0 (UART0)
  printf("\nUart Open!\n");
  ck_uart_open(&uart0, 0);

  // initialize uart using uart_cfig structure
  printf("\nUart Initiation!\n");
  ck_uart_init(&uart0, &uart_cfig);
  printf("baudrate = %d\n",BAUD);
  printf("parity = %d\n",PARITY_NONE);
  printf("stopbit = %d\n",STOPBIT_1);
  printf("wordsize = %d\n",WORDSIZE_8);
  printf("txmode = %d\n",ENABLE);
  //--------------------------------------------------------
  printf("\nUART trans...\n");
  ck_uart_putc(&uart0,0xf5);
  printf("\nUART putc done...\n");
  while (ck_uart_status(&uart0));
  printf("\nUART done...\n");
  asm(
    "nop \n\t"
    "nop \n\t"
    "nop \n\t"
    "nop \n\t"
    "nop \n\t"
    "li x4, 0x5f \n\t"
    "andi x4, x4, 0x1b \n\t"
    "nop \n\t"
    "nop \n\t"
    "nop \n\t"
    "nop \n\t"
    "nop \n\t"
  );
  printf("Done");
  return 0;
}
