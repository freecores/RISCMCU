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

entity v_timer is
 port(	extpin, clr_tov0 : in std_logic;
		rd_timsk, wr_timsk, rd_tifr, wr_tifr : in std_logic;
		rd_tccr0, wr_tccr0, rd_tcnt0, wr_tcnt0 : in std_logic;
		clk, clrn : in std_logic;
		c : inout std_logic_vector(7 downto 0);
		timerirq : out std_logic
 );
end v_timer;

architecture timer of v_timer is

signal toie0, tov0 : std_logic;
signal cs : integer range 0 to 7;
signal tcnt0 : std_logic_vector(7 downto 0);
signal div1, div2, div4, div8, div16, div32, div64, div128, div256, div512, div1024 : std_logic;
signal timerclk, inc_tcnt0, currentstate, laststate : std_logic;

begin

-- Timer Interrupt Request
timerirq <= toie0 and tov0;

-- Read 4 Registers
c <= 	"000000" & toie0 & "0" 		when rd_timsk = '1' else 
  		"000000" & tov0 & "0" 		when rd_tifr  = '1' else
		conv_std_logic_vector(cs,8) when rd_tccr0 = '1' else
		tcnt0 						when rd_tcnt0 = '1' else
		"ZZZZZZZZ";

-- Select Clock Source
with cs select
	timerclk <=	'0'			when 0,
 				clk			when 1,
				div8 		when 2,
				div64		when 3, 
				div256 		when 4, 
				div1024 	when 5,
				not extpin 	when 6,
				extpin 		when 7;

-- Timer : clear/write 4 registers, increment timer, set overflow flag, sample clock source
process(clrn, clr_tov0, wr_tifr, c, clk)
begin
	if clrn = '0' then
		toie0 <= '0';
		cs <= 0;
		tcnt0 <= "00000000";
		tov0 <= '0';	
		currentstate <= '0';
		laststate <= '0';

	elsif clr_tov0 = '1' or (wr_tifr = '1' and c(1) = '1') then
		tov0 <= '0';

	elsif clk'event and clk = '1' then

		if wr_tcnt0 = '1' then
			tcnt0 <= c;
		elsif inc_tcnt0 = '1' then
			tcnt0 <= tcnt0 + 1;
			if tcnt0 = "11111111" then
				tov0 <= '1';
			end if;
		end if;

		if wr_timsk = '1' then
			toie0 <= c(1);
		end if;
		if wr_tccr0 = '1' then
			cs <= conv_integer(c(2 downto 0));
		end if;

		currentstate <= timerclk;
		laststate <= currentstate;

	end if;
end process;

-- Detect rising edge
inc_tcnt0 <=	'1' when (laststate ='0' and currentstate = '1') or cs = 1 else
				'0';

-- 10 bit prescaler
process(clk, clrn)
begin
	if clrn = '0' then
		div2 <= '0';
		div4 <= '0';
		div8 <= '0';
		div16 <= '0';
		div32 <= '0';
		div64 <= '0';
		div128 <= '0';
		div256 <= '0';
		div512 <= '0';
		div1024 <= '0';

	elsif clk'event and clk = '1' then
		div2 <= not div2;
		if div2 = '1' then
		 	div4 <= not div4;
		 	if div4 = '1' then
		  		div8 <= not div8;
				if div8 = '1' then
					div16 <= not div16;
					if div16 = '1' then
						div32 <= not div32;
						if div32 = '1' then
							div64 <= not div64;
							if div64 = '1' then
								div128 <= not div128;
								if div128 = '1' then
									div256 <= not div256;
									if div256 = '1' then
										div512 <= not div512;
										if div512 = '1' then
											div1024 <= not div1024;
										end if;
									end if;
 								end if;
							end if;
						end if;
					end if;
				end if;
			end if;
		end if;
	end if;
end process;

end timer;
