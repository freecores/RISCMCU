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

entity v_sr is
	port( 	clk,clrn: in std_logic;
			sren,tosr : in std_logic_vector(6 downto 0);
			srsel : in integer range 0 to 7;
			clr_i,set_i,bset,bclr : in std_logic;
			rd_sreg, wr_sreg : in std_logic;
			c : inout std_logic_vector(7 downto 0);
			sr : inout std_logic_vector(7 downto 0)			
	);
end v_sr;

architecture sr of v_sr is
begin

c <= 	sr when rd_sreg = '1' else
		"ZZZZZZZZ";

process(clk,clrn,rd_sreg,sr)
begin
	if clrn = '0' then
		sr <= "00000000";
	elsif clk'event and clk = '1' then
		if wr_sreg = '1' then
			sr <= c;
		elsif bset = '1' or bclr = '1' then
			sr(srsel) <= bset;
		elsif clr_i = '1' or set_i = '1' then
			sr(7) <= set_i;
		else
			for i in 0 to 6 loop
				if sren(i) = '1' then
					sr(i) <= tosr(i);
				end if;
			end loop;
		end if;
	end if;

end process;

end sr;


