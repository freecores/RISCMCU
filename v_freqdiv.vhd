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

entity v_freqdiv is
 port(	clock : in std_logic;
		div2, div4, div8, div16 : buffer std_logic);
end v_freqdiv;

architecture myfreqdiv of v_freqdiv is
begin
process(clock)
begin
	if clock'event and clock = '1' then
		div2 <= not div2;
		if div2 = '1' then
		 	div4 <= not div4;
		 	if div4 = '1' then
		  		div8 <= not div8;
				if div8 = '1' then
					div16 <= not div16;
				end if;
			end if;
		end if;
	end if;
end process;
end myfreqdiv;
