-----
FILES
-----

readme.txt		This file
simple_calculator.asm	A simple calculator program which I use to test RISCMCU
memory_game.asm		A simple memory game which I use to test RISCMCU
riscmcu.inc		AVR Assembler include file for this RISCMCU
riscmcu.aio		AVR Studio I/O View setting file for RISCMCU
counter.asm		Simulation DEMO program for RISCMCU, which is
			  the program contains in program.mif in the vhdl directory
			  and the program the MCU run in the simulation waveform (simulation directory)
counter.lst		List file for counter.asm



-----------------
AVR Assember 1.30
-----------------

Click on 'Options...' Menu
1. Select 'Generic Format' under the Output file format (MUST for HEX2MIF to work!)
2. Check the 'Save before assemble' box.

riscmcu.inc	Include File for *.ASM (I/O register and bit definition for this design)

With an ASM file and the riscmcu.inc file, AVR Assembler generates

*.hex		Hex file : used by HEX2MIF
*.lst		Listing file
*.obj		Object file : used by AVR Studio for simulation


--------------
AVR Studio 3.0
--------------

Open the OBJ file, set

Prog.Memory		512
Data Memory		256* 
EEPROM			0		
I/O Size		64
Hardware Stack		check
Levels			4
Map I/O in Data Area	check
Frequency		any

You can go to Simulator Options (under Options menu) to set this anytime.

Then press
ALT-0	Registers View
ALT-4	New Memory View
ALT-5	New I/O View, choose riscmcu.aio

* The design only have 128 bytes of data RAM, but the simulator can not display the 128 locations when I put 128. 256 works, just ignored anything after the valid 128 byes.





