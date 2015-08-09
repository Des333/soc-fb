PWD  := $(shell pwd)

# This is default values until you set them from env.
ARCH ?= arm
CROSS_COMPILE ?= arm-linux-gnueabihf-

obj-m += etn_fb.o

default:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

