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

entity v_port_bit is
 port(	rd_port,wr_port,rd_ddr,wr_ddr,rd_pin : in std_logic;
		clk,clrn : in std_logic;
		c : inout std_logic;
		pin : inout std_logic
 );
end v_port_bit;

architecture port_bit of v_port_bit is

signal datareg, ddr : std_logic;

begin

c <=	datareg when rd_port = '1' else
		ddr when rd_ddr = '1' else
		pin when rd_pin = '1' else
		'Z';

pin <= 	datareg when ddr = '1' else
		'Z';

process(clrn, clk)
begin
	if clrn = '0' then
		datareg <= '0';
		ddr <= '0';
	elsif clk'event and clk = '1' then
		if wr_port = '1' then
			datareg <= c;
		end if;
		if wr_ddr = '1' then
			ddr <= c;
		end if;
	end if;	
end process;

end port_bit;

