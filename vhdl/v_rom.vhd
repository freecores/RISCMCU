----------------------------------------------------------------------------
---- 									----
---- WISHBONE RISCMCU IP Core 						----
---- 									----
---- This file is part of the RISCMCU project 				----
---- http://www.opencores.org/projects/riscmcu/ 			----
---- 									----
---- Description 							----
---- Implementation of a RISC Microcontroller based on Atmel AVR	----
---- AT90S1200 instruction set and features with Altera	Flex10k20 FPGA. ----
---- 									----
---- Author(s): 							----
---- 	- Yap Zi He, yapzihe@hotmail.com 				----
---- 									----
----------------------------------------------------------------------------
---- 									----
---- Copyright (C) 2001 Authors and OPENCORES.ORG 			----
---- 									----
---- This source file may be used and distributed without 		----
---- restriction provided that this copyright statement is not 		----
---- removed from the file and that any derivative work contains 	----
---- the original copyright notice and the associated disclaimer. 	----
---- 									----
---- This source file is free software; you can redistribute it 	----
---- and/or modify it under the terms of the GNU Lesser General 	----
---- Public License as published by the Free Software Foundation; 	----
---- either version 2.1 of the License, or (at your option) any 	----
---- later version. 							----
---- 									----
---- This source is distributed in the hope that it will be 		----
---- useful, but WITHOUT ANY WARRANTY; without even the implied 	----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 		----
---- PURPOSE. See the GNU Lesser General Public License for more 	----
---- details. 								----
---- 									----
---- You should have received a copy of the GNU Lesser General 		----
---- Public License along with this source; if not, download it 	----
---- from http://www.opencores.org/lgpl.shtml 				----
---- 									----
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity v_rom is
 port(	pc : in std_logic_vector(8 downto 0);
		instruction : out std_logic_vector(15 downto 0));
end v_rom;

architecture rom of v_rom is

	component LPM_ROM
	generic (
		LPM_WIDTH: integer := 16;
		LPM_WIDTHAD: integer := 9;
		LPM_NUMWORDS: integer := 512;
		LPM_FILE: string := "program.mif";
		LPM_ADDRESS_CONTROL: string := "UNREGISTERED";
		LPM_OUTDATA: string := "UNREGISTERED"
	);
	port (
		ADDRESS: in STD_LOGIC_VECTOR(LPM_WIDTHAD-1 downto 0);
		inclock: IN STD_LOGIC := '0';
		outclock: IN STD_LOGIC := '0';
		memenab: IN STD_LOGIC := '1';
		Q: out STD_LOGIC_VECTOR(LPM_WIDTH-1 downto 0)
	);
	end component;

signal gnd, vcc : std_logic;

begin

vcc <= '1';
gnd <= '0';

	v1 : LPM_ROM
		port map (address => pc, memenab => vcc, q => instruction);

end rom;
