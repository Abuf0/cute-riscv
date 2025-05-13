#include "datatype.h"
#include "stdio.h"
#include "spi.h"

uint32_t ck_spi_open(p_ck_spi_device spi_device, uint32_t id){
    if(id==0){
        spi_device->spi_id = 0;
        spi_device->register_map = (uint32_t*)SPI0_BASE_ADDR;
        return 0;
    }
    else {
        return 1;
    }
}

uint32_t ck_spi_init(p_ck_spi_device spi_device, p_ck_spi_cfig spi_cfig){
    
}

uint32_t ck_spi_close(p_ck_spi_device spi_device){
        return 0;
}

uint32_t ck_spi_status(p_ck_spi_device spi_device){
        return 0;
}

uint32_t ck_spi_putc(p_ck_spi_device spi_device, uint8_t c){
        *(reg8_t*)(spi_device->register_map+0x4) = c;
        return 0;
}