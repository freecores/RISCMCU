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

entity v_ram is
 port(	addrbus : in std_logic_vector(7 downto 0);
		rd_ram, wr_ram, ld_mar, ld_mbr : in std_logic;
		clk, clrn : in std_logic;
		c : inout std_logic_vector(7 downto 0)
 );
end entity;
		
architecture ram of v_ram is

component lpm_ram_dq
 generic(	lpm_width: positive := 8;
			lpm_widthad: positive := 8;
			lpm_numwords: natural := 256;
			lpm_file: string := "ram.mif";
			lpm_indata: string := "unregistered";
			lpm_address_control: string := "unregistered";
			lpm_outdata: string := "unregistered"
 );
 port(	data: in std_logic_vector(lpm_width-1 downto 0);
		address: in std_logic_vector(lpm_widthad-1 downto 0);
		we: in std_logic;
		inclock: in std_logic := '0';
		outclock: in std_logic := '0';
		q: out std_logic_vector(lpm_width-1 downto 0)
 );
end component;

signal mar, mbr, ram_out : std_logic_vector(7 downto 0);

begin

sram: lpm_ram_dq
	port map(data => mbr, address => mar, we => wr_ram, q => ram_out);

c <= ram_out when rd_ram = '1' else
	"ZZZZZZZZ";

process(clk,clrn)
begin
	if clrn = '0' then
		mar <= "00000000";
		mbr <= "00000000";
	elsif clk'event and clk = '1' then
		if ld_mbr = '1' then
			mbr <= c;
		end if;
		if ld_mar = '1' then
			mar <= addrbus;
		end if;
	end if;
end process;

end ram;
