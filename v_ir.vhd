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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity v_ir is
 port(	instruction : in std_logic_vector(15 downto 0);
		en, clk, clrn : in std_logic;
		ir : buffer std_logic_vector(15 downto 0);
		imm_value : out std_logic_vector(7 downto 0);
		rd, rr : out integer range 0 to 15
);
end v_ir;

architecture ir of v_ir is
begin

process(clk,clrn)
begin
	if clrn = '0' then
		ir <= "0000000000000000";
	elsif clk'event and clk = '1' then
		if en = '1' then
			ir <= instruction;
		end if;
	end if;
end process;

imm_value <= ir(11 downto 8) & ir(3 downto 0);
rd <= conv_integer(ir(7 downto 4));
rr <= conv_integer(ir(3 downto 0));

end ir;
