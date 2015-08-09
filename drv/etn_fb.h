
#ifndef _ETN_FB_H
#define _ETN_FB_H


#define NAME "etn_fb"

#define FPGA_REGS_BASE                    (0xc0000000)
#define REGSIZE                           (128)

#define DISPLAY_WIDTH                     (320)
#define DISPLAY_HEIGHT                    (240)
#define DISPLAY_BPP                       (16)

#define MIN_FPS                           (1)
#define MAX_FPS                           (100)


#define ILI9341_DISPLAY_ON                (0x29)
#define ILI9341_SLEEP_OUT                 (0x11)
#define ILI9341_INVERTION_OFF             (0x20)

#define ILI9341_MEM_ACCESS_CTRL           (0x36)
        #define MY                        BIT(7)
        #define MX                        BIT(6)
        #define MV                        BIT(5)
        #define ML                        BIT(4)
        #define BGR                       BIT(3)
        #define MH                        BIT(2)

#define ILI9341_PIXEL_FORMAT              (0x3A)

#define ILI9341_COLUMN_ADDR               (0x2A)
#define ILI9341_PAGE_ADDR                 (0x2B)

#define ILI9341_MEM_WRITE                 (0x2C)


#define LCD_DATA_CR                       (0)

#define LCD_CTRL_CR                       (1)
        #define LCD_CTRL_CR_RD            BIT(0)
        #define LCD_CTRL_CR_WR            BIT(1)
        #define LCD_CTRL_CR_RS            BIT(2)

#define LCD_DMA_CR                        (2)
        #define LCD_DMA_CR_REDRAW_STB     (0)
        #define LCD_DMA_CR_WR_EN          (1)
        #define LCD_DMA_CR_REDRAW_EN      (2)

#define LCD_DMA_ADDR_CR0                  (3)
#define LCD_DMA_ADDR_CR1                  (4)

#define LCD_FPS_DELAY_CR                  (5)



#endif // _ETN_FB_H
