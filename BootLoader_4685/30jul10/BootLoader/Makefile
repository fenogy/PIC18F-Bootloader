# MPLAB IDE generated this makefile for use with GNU make.
# Project: rreset.mcp
# Date: Fri Feb 12 15:16:01 2010

AS = MPASMWIN.exe
CC = mcc18.exe
LD = mplink.exe
AR = mplib.exe
RM = rm

flash_write.cof : flash_write.o
	$(LD) /p18F4682 "flash_write.o" /z__MPLAB_BUILD=1 /o"flash_write.cof" /M"flash_write.map" /W /x

flash_write.o : flash_write.ASM C:/Program\ Files/Microchip/MPASM\ Suite/p18f4682.inc
	$(AS) /q /p18F4682 "flash_write.ASM" /l"flash_write.lst" /e"flash_write.err"

clean : 
	$(RM) "flash_write.o" "flash_write.hex" "flash_write.err" "flash_write.lst" "flash_write.cof"

