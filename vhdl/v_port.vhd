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

entity v_port is
 port(	rd_port, wr_port, rd_ddr, wr_ddr, rd_pin : in std_logic;
		clk, clrn : in std_logic;
		c : inout std_logic_vector(7 downto 0);
		pin : inout std_logic_vector(7 downto 0)
 );
end v_port;

architecture ioport of v_port is

component v_port_bit
 port(	rd_port,wr_port,rd_ddr,wr_ddr,rd_pin : in std_logic;
		clk,clrn : in std_logic;
		c : inout std_logic;
		pin : inout std_logic
 );
end component;

begin

	g1:
	for i in 0 to 7 generate
		u1 : v_port_bit
			port map (rd_port, wr_port, rd_ddr, wr_ddr, rd_pin, clk, clrn, c(i), pin(i));
	end generate;

end ioport;
