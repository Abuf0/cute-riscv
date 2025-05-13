/*Copyright 2020-2021 T-Head Semiconductor Co., Ltd.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
#include <stdio.h>
//#include "uart.h"
/*
// uart print //
t_ck_uart_device uart0;

int fputc(int ch, FILE *stream)
{
    return(ck_uart_putc(&uart0,ch));
}
*/

// std out print //
int fputc(int ch, FILE *stream)
{
  asm(
      //"li   x13, 0x6000fff8 \n\t" 
      "li   x13, 0x90000000 \n\t" // std out
      "sw   %0, 0(x13) \n\t"
      : :"r" (ch): "x13" );
}


void os_critical_enter(void)
{
}

void os_critical_exit(void)
{
}

