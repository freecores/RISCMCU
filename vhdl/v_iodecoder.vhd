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

entity v_iodecoder is
 port(	ioaddr : in integer range 0 to 16#3f#;
		rd_io, wr_io : in std_logic;
		rd_sreg, wr_sreg : out std_logic; 
		rd_gimsk, wr_gimsk, rd_timsk, wr_timsk, rd_tifr,wr_tifr : out std_logic;
		rd_mcucr,wr_mcucr, rd_tccr0, wr_tccr0, rd_tcnt0,wr_tcnt0 : out std_logic;
		rd_portb, wr_portb, rd_ddrb, wr_ddrb, rd_pinb : out std_logic;
		rd_portc, wr_portc, rd_ddrc, wr_ddrc, rd_pinc : out std_logic;
		rd_portd, wr_portd, rd_ddrd, wr_ddrd, rd_pind : out std_logic
 );
end v_iodecoder;

architecture iodecoder of v_iodecoder is
begin

process(rd_io, ioaddr)
begin

 rd_sreg <= '0';
 rd_gimsk <= '0';
 rd_timsk <= '0';
 rd_tifr <= '0';
 rd_mcucr <= '0';
 rd_tccr0 <= '0';
 rd_tcnt0 <= '0';

 rd_portb <= '0';
 rd_ddrb <= '0';
 rd_pinb <= '0';
 rd_portc <= '0';
 rd_ddrc <= '0';
 rd_pinc <= '0';
 rd_portd <= '0';
 rd_ddrd <= '0';
 rd_pind <= '0';

 if rd_io = '1' then
	case ioaddr is
		when 16#3f# => rd_sreg  <= '1';
		when 16#3b# => rd_gimsk <= '1';
		when 16#39# => rd_timsk <= '1';
		when 16#38# => rd_tifr  <= '1';
		when 16#35# => rd_mcucr <= '1';
		when 16#33# => rd_tccr0 <= '1';
		when 16#32# => rd_tcnt0 <= '1';

		when 16#18# => rd_portb <= '1';
		when 16#17# => rd_ddrb  <= '1';
		when 16#16# => rd_pinb  <= '1';
		when 16#15# => rd_portc <= '1';
		when 16#14# => rd_ddrc  <= '1';
		when 16#13# => rd_pinc  <= '1';
		when 16#12# => rd_portd <= '1';
		when 16#11# => rd_ddrd  <= '1';
		when 16#10# => rd_pind  <= '1';
		when others => 
	end case;
 end if;
end process;

process(wr_io, ioaddr)
begin

 wr_sreg <= '0';
 wr_gimsk <= '0';
 wr_timsk <= '0';
 wr_tifr <= '0';
 wr_mcucr <= '0';
 wr_tccr0 <= '0';
 wr_tcnt0 <= '0';
	
 wr_portb <= '0';
 wr_ddrb <= '0';
 wr_portc <= '0';
 wr_ddrc <= '0';
 wr_portd <= '0';
 wr_ddrd <= '0';

 if wr_io = '1' then
	case ioaddr is
		when 16#3f# => wr_sreg  <= '1';
		when 16#3b# => wr_gimsk <= '1';
		when 16#39# => wr_timsk <= '1';
		when 16#38# => wr_tifr  <= '1';
		when 16#35# => wr_mcucr <= '1';
		when 16#33# => wr_tccr0 <= '1';
		when 16#32# => wr_tcnt0 <= '1';

		when 16#18# => wr_portb <= '1';
		when 16#17# => wr_ddrb  <= '1';
		when 16#15# => wr_portc <= '1';
		when 16#14# => wr_ddrc  <= '1';
		when 16#12# => wr_portd <= '1';
		when 16#11# => wr_ddrd  <= '1';
		when others =>  
	end case;
 end if;
end process;

end iodecoder;
