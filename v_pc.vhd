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
use ieee.std_logic_unsigned.all;

entity v_pc is
 port(	offset : in std_logic_vector(8 downto 0);
		en, addoffset, push, pull, vec2, vec4 : in std_logic;
		clk, clrn : in std_logic;
		pc : buffer std_logic_vector(8 downto 0)
 );
end v_pc;

architecture pc of v_pc is
constant vector2 : std_logic_vector(8 downto 0) := "000000001";
constant vector4 : std_logic_vector(8 downto 0) := "000000010";
signal pcb, stack0, stack1, stack2, stack3 : std_logic_vector(8 downto 0);
begin

process(clk, clrn)
begin
	if clrn = '0' then
		pc <= "000000000";
		pcb <= "000000000";
		stack0 <= "000000000";
		stack1 <= "000000000";
		stack2 <= "000000000";
		stack3 <= "000000000";
	elsif clk'event and clk = '1' then
		if en = '1' then
			pcb <= pc;
			if addoffset = '1' then
				pc <= pcb + offset;
			elsif pull = '1' then
				pc <= stack0;
			elsif vec2 = '1' then
				pc <= vector2;
			elsif vec4 = '1' then
				pc <= vector4;
			else
				pc <= pc + 1;
			end if;

			if push = '1' then
				if addoffset = '1' then
					stack0 <= pcb;
				else
					stack0 <= pcb - 1;
				end if;
				stack1 <= stack0;
				stack2 <= stack1;
				stack3 <= stack2;
			elsif pull = '1' then
				stack0 <= stack1;
				stack1 <= stack2;
				stack2 <= stack3;
			end if;			
		end if;	
	end if;		
end process;
end pc;
