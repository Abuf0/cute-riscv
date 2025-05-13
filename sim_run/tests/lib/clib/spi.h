
#ifndef __SPI_H__
#define __SPI_H__

#include "datatype.h"
#include "stdio.h"


#define SPI0_BASE_ADDR  0x10016000
/* SPI registers addr definition */
//#define CK_SPI_RBR       0x00    /* Receive Buffer Register (32 bits, R) */

typedef enum {
    PARITY_NONE,
    PARITY_ODD,
    PARITY_EVEN
} t_ck_spi_parity;

typedef enum {
    BYTELEN_1,
    BYTELEN_2,
    BYTELEN_3,
    BYTELEN_4,
    BYTELEN_5,
    BYTELEN_6,
    BYTELEN_7,
    BYTELEN_8
} t_ck_spi_bytelen;

typedef enum {
    DISABLE,
    ENABLE
} t_ck_spi_mode;


typedef struct {
    uint32_t spi_id;
    uint32_t* register_map;
} t_ck_spi_device, *p_ck_spi_device;

typedef struct {
    t_ck_spi_parity    cpha;
    t_ck_spi_parity    cpol;
    t_ck_spi_bytelen   bytelen;
    t_ck_spi_mode      mater;
    t_ck_spi_mode      slave;
} t_ck_spi_cfig, *p_ck_spi_cfig;


/*
 * @brief  open a SPI device, use id to select
 *         if more than one SPI devices exist in SOC
 * @param  spi_device: spi device handler
 * @param  id: SPI device ID
 * @retval 0 if success, 1 if fail
 */
uint32_t ck_spi_open(p_ck_spi_device spi_device, uint32_t id);

/*
 * @brief  close SPI device handler
 * @param  spi_device: spi device handler
 * @retval 0 if success, 1 if fail
 */
uint32_t ck_spi_close(p_ck_spi_device spi_device);

/*
 * @brief  Initialize SPI configurations from spi_cfig data structure
 * @param  spi_device: spi device handler
 * @param  spi_cfig: spi configurations collection, a structure datatype
 * @retval 0 if success, 1 if fail
 */
uint32_t ck_spi_init(p_ck_spi_device spi_device, p_ck_spi_cfig spi_cfig);

/*
 * @brief  transmit a character through SPI
 * @param  spi_device: spi device handler
 * @param  c: character needs to transmit
 * @retval 0 if success, 1 if fail
 */
uint32_t ck_spi_putc(p_ck_spi_device spi_device, uint8_t c);

/*
 * @brief  check spi device's status, busy or idle
 * @param  spi_device: spi device handler
 * @retval 0 if spi is in idle, 1 if busy
 */
uint32_t ck_spi_status(p_ck_spi_device spi_device);

#endif

