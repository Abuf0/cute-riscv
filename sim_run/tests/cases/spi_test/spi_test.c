#include <stdio.h>
#include <stdlib.h>
#include "string.h"
#include "datatype.h"
#include "spi.h"

int main(void){

    t_ck_spi_device spi0 = {0xFFFF};
    printf("\nSPI Open!\n");
    ck_spi_open(&spi0,0);
    printf("\nSPI putc done\n");
    ck_spi_putc(&spi0,0xf5);
    return 0;
}