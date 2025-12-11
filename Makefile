CROSS_COMPILE ?= ../oc-freertos-dsp/tools/xtensa-hifi4-gcc/bin/xtensa-hifi4-elf-
CC      := $(CROSS_COMPILE)gcc
AS      := $(CROSS_COMPILE)as
LD      := $(CROSS_COMPILE)ld
OBJCOPY := $(CROSS_COMPILE)objcopy

CFLAGS = -O2 -mlongcalls -mtext-section-literals -mabi=call0
ASFLAGS = --abi-call0
LDFLAGS = -T link.ld

all: clean test.elf test.bin

crt1.o: crt1.S
	$(AS) $(ASFLAGS) -o crt1.o crt1.S oemhead.S

main.o: main.c
	$(CC) $(CFLAGS) -c -o main.o main.c

test.elf: crt1.o main.o link.ld
	$(CC) $(LDFLAGS) -nostdlib -o test.elf crt1.o main.o

test.bin: test.elf
	$(OBJCOPY) -O binary test.elf test.bin

clean:
	rm -f *.o test.elf test.bin

install: all
	scp test.elf carbon:/root/dsp.elf
	ssh carbon -t 'dd if=/root/dsp.elf of=/dev/by-name/dsp0A; reboot'
