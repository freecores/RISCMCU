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

entity v_extint is
 port(	clk, clrn, extpin, clr_intf : in std_logic;
		rd_mcucr, wr_mcucr, rd_gimsk, wr_gimsk : in std_logic;
		extirq	: out std_logic;
		c : inout std_logic_vector(7 downto 0));
end v_extint;

architecture extint of v_extint is

signal int0, flag, currentstate, laststate : std_logic;
signal isc0 : integer range 0 to 3;

begin

c <= "000000" & conv_std_logic_vector(isc0,2) 	when rd_mcucr = '1' else
	 '0' & int0 & "000000" 						when rd_gimsk = '1' else
	 "ZZZZZZZZ";

extirq <= 	int0 and not extpin when isc0 = 0 else
			int0 and flag;

process(clk, clrn)
begin
	if clrn = '0' then
		int0 <= '0';
		isc0 <= 0;
		currentstate <= '0';
		laststate <= '0';
	elsif clk'event and clk = '1' then
		if wr_gimsk = '1' then
			int0 <= c(6);
		end if;
		if wr_mcucr = '1' then
			isc0 <= conv_integer(c(1 downto 0));
		end if;
		currentstate <= extpin;
		laststate <= currentstate;
	end if;	
end process;

process(clrn, clr_intf, clk, isc0, currentstate)
begin
	if clrn = '0' or clr_intf = '1' then
		flag <= '0';
	elsif clk'event and clk = '1' then
		if isc0 = 2 then
			if currentstate = '0' and laststate = '1' then
				flag <= '1';
			end if;
		elsif isc0 = 3 then 
			if currentstate = '1' and laststate = '0' then
				flag <= '1';
			end if;
		end if;
	end if;	
end process;

end extint;
