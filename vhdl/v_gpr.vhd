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

entity v_gpr is
 port(	c : in std_logic_vector(7 downto 0);		
		wr_reg, inc_zp, dec_zp : in std_logic;
		rd, rr, dest : in integer range 0 to 15;
		clk, clrn : in std_logic;
		reg_rd, reg_rr, addrbus : out std_logic_vector(7 downto 0)
 );
end v_gpr;

architecture gpr of v_gpr is

type regfiletype is array (0 to 15) of std_logic_vector(7 downto 0);

signal reg : regfiletype;

begin

addrbus <=	reg(14) - 16#61# when dec_zp = '1' else
			reg(14) - 16#60#;

reg_rd <= reg(rd);
reg_rr <= reg(rr);

process(clk, clrn)
begin
	if clrn = '0' then
		for i in 0 to 15 loop
			reg(i) <= "00000000";
		end loop;	
	elsif clk'event and clk = '1' then
		if wr_reg = '1' then
			reg(dest) <= c;	
		end if;
		if inc_zp = '1' then
			reg(14) <= reg(14) + 1;
		elsif dec_zp = '1' then
			reg(14) <= reg(14) - 1;
		end if;		
	end if;
end process;

end gpr;
