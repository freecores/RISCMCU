------------
AVR Assember
------------

Click on 'Options...' Menu
1. Select 'Generic Format' under the Output file format (MUST for HEX2MIF to work!)
2. Check the 'Save before assemble' box.

calc.asm	Simple Calculator Source Code
memgame.asm	Simple Memory Game Source Code
riscmcu.inc	Include File for *.ASM (I/O register and bit definition for this design)

With an ASM file and the riscmcu.inc file, AVR Assembler generates

*.hex		Hex file : used by HEX2MIF
*.lst		Listing file
*.obj		Object file : used by AVR Studio for simulation


----------
AVR Studio
----------

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
ALT-5	New I/O View, choose riscmcu.aio**

* The design only have 128 bytes of data RAM, but the simulator can not display the 128 locations when I put 128. 256 works, just ignored anything after the valid 128 byes.
** External interrupt can not be simulated because the design mapped the external interrupt pin to D7 but the simulator map it to pin D2 (according to AT90S1200).


-------
HEX2MIF
-------

calc.mif	Simple Calculator MIF file
game.mif	Simple Memory Game MIF file

Both generated from the hex file by HEX2MIF to 'program.mif', then I rename it to reflect its application





