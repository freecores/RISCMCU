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
use ieee.std_logic_arith.all;

entity v_controlunit is
 port(	ir	: in std_logic_vector(15 downto 0);
		sr : in std_logic_vector(7 downto 0);
		clk, clrn : in std_logic;
		skip, extirq, timerirq : in std_logic;

		en : buffer std_logic;
		wr_reg : buffer std_logic;
		rd_ram, wr_ram, ld_mar, ld_mbr, inc_zp, dec_zp : out std_logic;
		sren : out std_logic_vector (6 downto 0);

		c2a,c2b : out std_logic;
		asel : out integer range 0 to 1;
		bsel : out integer range 0 to 3;
		bitsel : out integer range 0 to 7;
		set : out std_logic;

		add, subcp, logic, right, dir, pass_a : out std_logic;

		wcarry : out std_logic;
		logicsel : out integer range 0 to 3;
		rightsel : out integer range 0 to 2;
		dirsel : out integer range 0 to 1;

		addoffset : out std_logic;
		push, pull : out std_logic;

		cpse, skiptest : out std_logic;

		bclr,bset : out std_logic;
		bld : out std_logic;
	
		cbisbi : out std_logic;

		vec2, vec4 : buffer std_logic;

		dest : out integer range 0 to 15;
		srsel : out integer range 0 to 7;
		offset : out std_logic_vector(8 downto 0);
		
		clr_i, set_i, clr_intf, clr_tov0 : out std_logic;

		rd_sreg, wr_sreg : out std_logic; 
		rd_gimsk, wr_gimsk, rd_timsk, wr_timsk, rd_tifr,wr_tifr : out std_logic;
		rd_mcucr,wr_mcucr, rd_tccr0, wr_tccr0, rd_tcnt0,wr_tcnt0 : out std_logic;
		rd_portb, wr_portb, rd_ddrb, wr_ddrb, rd_pinb : out std_logic;
		rd_portc, wr_portc, rd_ddrc, wr_ddrc, rd_pinc : out std_logic;
		rd_portd, wr_portd, rd_ddrd, wr_ddrd, rd_pind : out std_logic

);
end v_controlunit;

architecture controlunit of v_controlunit is

type statetype is (exes, nop2s, nop1s, lds, sts, cbisbis, sbicss, sleeps); 

signal ibr : std_logic_vector(11 downto 0);
signal state : statetype;
signal one, neg, imm : std_logic;

signal
cpcm, sbcm, addm, cpsem, cpm, subm, adcm, andm, eorm, orm, movm,
cpim, sbcim, subim, orim, andim, ldm, stm, comm, negm, swapm, incm,
asrm, lsrm, rorm, decm, bsetm, bclrm, retm, retim, sleepm, 
cbisbim, sbicsm, inm, outm, rjmpm, rcallm, ldim,
brbcsm, bldm, bstm, sbrcsm, 
ld_incm, ld_decm, st_incm, st_decm : std_logic;

signal ioaddr : integer range 0 to 16#3f#;
signal rd_io, wr_io, break, irq, get_io, wr_ram_fast, branchtest, branch, jmp : std_logic;

	component v_iodecoder
	 port(	ioaddr : in integer range 0 to 16#3f#;
			rd_io, wr_io : in std_logic;
			rd_sreg, wr_sreg : out std_logic; 
			rd_gimsk, wr_gimsk, rd_timsk, wr_timsk, rd_tifr,wr_tifr : out std_logic;
			rd_mcucr,wr_mcucr, rd_tccr0, wr_tccr0, rd_tcnt0,wr_tcnt0 : out std_logic;
			rd_portb, wr_portb, rd_ddrb, wr_ddrb, rd_pinb : out std_logic;
			rd_portc, wr_portc, rd_ddrc, wr_ddrc, rd_pinc : out std_logic;
			rd_portd, wr_portd, rd_ddrd, wr_ddrd, rd_pind : out std_logic
	 );
	end component;

begin

-- Instruction Decoder
-- Decode 51 instructions generate 46 'm signals
-- Combine brbcs+brbs (brbcs) cbi+sbi (cbisbi)  sbrc+sbrs (sbrcs)  sbic+sbis (sbics)

process(ir, wr_reg, get_io, ibr)
begin

cpcm <= '0'; sbcm <= '0'; addm <= '0';
cpsem <= '0'; cpm <= '0'; subm <= '0'; adcm <= '0';
andm <= '0'; eorm <= '0'; orm <= '0'; movm <= '0';
cpim <= '0'; sbcim <= '0'; subim <= '0'; orim <= '0'; andim <= '0';
ldm <= '0'; stm <= '0'; comm <= '0'; negm <= '0'; swapm <= '0'; incm <= '0';
asrm <= '0'; lsrm <= '0'; rorm <= '0'; decm <= '0';
bsetm <= '0'; bclrm <= '0'; retm <= '0'; retim <= '0'; sleepm <= '0'; 
cbisbim <= '0'; sbicsm <= '0'; 
inm <= '0'; outm <= '0'; rjmpm <= '0'; rcallm <= '0'; ldim <= '0';
brbcsm <= '0'; bldm <= '0'; bstm <= '0'; sbrcsm <= '0';
ld_incm <= '0'; ld_decm <= '0'; st_incm <= '0'; st_decm <= '0';

case ir(15 downto 12) is
	when "0000" =>
		if ir(11 downto 10) = "01" then cpcm <= '1'; end if;
		if ir(11 downto 10) = "10" then sbcm <= '1'; end if;
		if ir(11 downto 10) = "11" then addm <= '1'; end if;		
	when "0001" =>
		if ir(11 downto 10) = "00" then cpsem<= '1'; end if;
		if ir(11 downto 10) = "01" then cpm  <= '1'; end if;
		if ir(11 downto 10) = "10" then subm <= '1'; end if;
		if ir(11 downto 10) = "11" then adcm <= '1'; end if;
	when "0010" =>
		if ir(11 downto 10) = "00" then andm <= '1'; end if;
		if ir(11 downto 10) = "01" then eorm <= '1'; end if;
		if ir(11 downto 10) = "10" then orm  <= '1'; end if;
		if ir(11 downto 10) = "11" then movm <= '1'; end if;
	when "0011" =>
		cpim <= '1';
	when "0100" =>
		sbcim <= '1';
	when "0101" =>
		subim <= '1';
	when "0110" =>
		orim <= '1';
	when "0111" =>
		andim <= '1';
	when "1000" =>
		if ir(11 downto 9) = "000" then ldm <= '1'; end if;
		if ir(11 downto 9) = "001" then stm <= '1'; end if;
	when "1001" =>
		if ir(11 downto 9) = "000" then 
			if ir(1 downto 0) = "01" then ld_incm <= '1'; end if;
			if ir(1 downto 0) = "10" then ld_decm <= '1'; end if;
		end if;
		if ir(11 downto 9) = "001" then 
			if ir(1 downto 0) = "01" then st_incm <= '1'; end if;
			if ir(1 downto 0) = "10" then st_decm <= '1'; end if;
		end if;	
		if ir(11 downto 9) = "010" then
			case ir(3 downto 0) is
				when "0000" => comm <= '1';
				when "0001" => negm <= '1';
				when "0010" => swapm <= '1';
				when "0011" => incm <= '1';
				when "0101" => asrm <= '1';
				when "0110" => lsrm <= '1';
				when "0111" => rorm <= '1';
				when "1010" => decm <= '1';
				when "1000" =>
					if ir(8 downto 7) = "00"  then bsetm  <= '1'; end if;
					if ir(8 downto 7) = "01"  then bclrm  <= '1'; end if;
					if ir(8 downto 7) & ir(4) = "100" then retm   <= '1'; end if;
					if ir(8 downto 7) & ir(4) = "101" then retim  <= '1'; end if;
					if ir(8 downto 7) = "11"  then sleepm <= '1'; end if;
				when others =>
			end case;
		elsif ir(11 downto 10) = "10" then
			if ir(8) = '0' then cbisbim <= '1'; -- cbi, sbi
			else sbicsm <= '1';  end if; -- sbic, sbis
		end if;
	when "1011" =>
		if ir(11) = '0' then inm  <= '1';
		else outm <= '1';
		end if;
	when "1100" =>
		rjmpm <= '1';
	when "1101" =>
		rcallm <= '1';
	when "1110" =>
		ldim <= '1';
	when "1111" =>
		if ir(11) = '0' then brbcsm <= '1'; end if;
		if ir(11 downto 9) = "100" then bldm  <= '1'; end if;
		if ir(11 downto 9) = "101" then bstm  <= '1'; end if;
		if ir(11 downto 10) = "11" then sbrcsm <= '1';  end if;-- sbrc, sbrs
	when others =>
end case;


-- Generate Fetch Stage Signals : C2A and C2B (C2A active also when fetch I/O)
if ((ibr(7 downto 4) = ir(7 downto 4)) and wr_reg = '1') or get_io = '1' then
	c2a <= '1';
else
	c2a <= '0';
end if;

if (ibr(7 downto 4) = ir(3 downto 0)) and wr_reg = '1' then
	c2b <= '1';
else
	c2b <= '0';
end if;

end process;

-- Generate wcarry, logicsel, rightsel and dirsel
-- Load IBR with IR when EN active
process(clk,clrn)
begin
if clrn = '0' then
	ibr <= "000000000000";

	wcarry <= '0';
	logicsel <= 0;
	rightsel <= 0;
	dirsel <= 0;

elsif clk'event and clk = '1' then
	if en = '1' then
		ibr <= ir(11 downto 0);
	end if;

	wcarry <= adcm or sbcm or sbcim or cpcm; 

	if    orm = '1' or orim = '1' then logicsel <= 1;
	elsif eorm = '1' then logicsel <= 2;
	elsif comm = '1' then logicsel <= 3;
	else logicsel <= 0;
	end if;
	
	if    rorm = '1' then rightsel <= 1;
	elsif asrm = '1' then rightsel <= 2;
	else rightsel <= 0;
	end if;	
	
	if swapm = '1' then dirsel <= 1;
	else dirsel <= 0;
	end if;
	
end if;
end process;


-- Finite State Machine

irq <= (timerirq or extirq) and sr(7);
break <= branch or skip or irq;

process(clk, clrn)
begin

if clrn = '0' then

	state <= exes;

 	en <= '1';	get_io <= '0';
	pass_a <= '0'; wr_reg <= '0'; sren <= "0000000";
 	rd_io <= '0'; wr_io <= '0'; rd_ram <= '0'; wr_ram_fast <= '0';
	ld_mar <= '0'; ld_mbr <= '0'; inc_zp <= '0'; dec_zp <= '0';
 	add <= '0'; subcp <= '0'; logic <= '0';	right <= '0'; dir <= '0';
 	jmp <= '0'; push <= '0'; pull <= '0';	branchtest <= '0'; 
 	bclr <= '0'; bset <= '0'; bld <= '0'; 
	cpse <= '0'; skiptest <= '0'; 
 	cbisbi <= '0';
	vec2 <= '0'; vec4 <= '0'; set_i <= '0';

elsif clk'event and clk = '1' then

 	en <= '1';	get_io <= '0';
	pass_a <= '0'; wr_reg <= '0'; sren <= "0000000";
 	rd_io <= '0'; wr_io <= '0'; rd_ram <= '0'; wr_ram_fast <= '0';
	ld_mar <= '0'; ld_mbr <= '0'; inc_zp <= '0'; dec_zp <= '0';
 	add <= '0'; subcp <= '0'; logic <= '0';	right <= '0'; dir <= '0';
 	jmp <= '0'; push <= '0'; pull <= '0';	branchtest <= '0'; 
 	bclr <= '0'; bset <= '0'; bld <= '0'; 
	cpse <= '0'; skiptest <= '0'; 
 	cbisbi <= '0';
	vec2 <= '0'; vec4 <= '0'; set_i <= '0';

	case state is

		when exes =>
		
			if break = '1' then

				if	branch = '1' then
					state <= nop1s;

				elsif skip = '1' then

				elsif irq = '1' then
					state <= nop2s;
					push <= '1';
					if extirq = '1' then
						vec2 <= '1';
					else
						vec4 <= '1';
					end if;
				end if;

			else

			 	if rjmpm = '1' or rcallm = '1' or retm = '1' or retim = '1' then
					state <= nop2s;
				elsif cbisbim = '1' then
					state <= cbisbis;
				elsif sbicsm = '1' then
					state <= sbicss;
				elsif ldm = '1' or ld_incm = '1' or ld_decm = '1' then
					state <= lds;
				elsif stm = '1' or st_incm = '1' or st_decm = '1' then
					state <= sts;
				elsif sleepm = '1' then
					state <= sleeps;
			 	end if;

				-- PC signals
		 		jmp  <= rjmpm or rcallm; -- encoded
		 		push <= rcallm;
		 		pull <= retm or retim; 

				-- PC and IR signals
				en <= not (cbisbim or sbicsm 
						or stm or st_incm or st_decm or 
						ldm or ld_incm or ld_decm); 

				-- General Purpose Register File signals
		 		wr_reg <= addm or adcm or incm 
						or subm or subim or sbcm or sbcim or decm or negm 
						or andm or andim or orm or orim or eorm or comm 
						or lsrm or rorm or asrm 
						or ldim or movm or swapm
						or inm;			
				inc_zp <= ld_incm or st_incm;
				dec_zp <= ld_decm or st_decm;

				-- ALU signals
		 		add <= addm or adcm or incm;
		 		subcp <= subm or subim or sbcm or sbcim or decm or negm 
						or cpm or cpim or cpcm;
		 		logic <= andm or andim or orm or orim or eorm or comm;
		 		right <= lsrm or rorm or asrm;	 	
		 		dir <= ldim or movm or swapm;
		 		bld <= bldm;
 		 		pass_a <= outm or stm or st_incm or st_decm;
				cpse <= cpsem;
		 		skiptest <= sbrcsm;


	
				-- SR signals
 		 		bclr <= bclrm;
		 		bset <= bsetm;
				set_i <= retim;		

				sren(0) <= addm or adcm 
					 or subm or subim or sbcm or sbcim or cpm or cpcm or cpim or negm
					 or comm
					 or lsrm or rorm or asrm; 

				for i in 1 to 4 loop
					sren(i) <= addm or adcm or incm
					 or subm or subim or sbcm or sbcim or cpm or cpcm or cpim or decm or negm
					 or andm or andim or orm or orim or eorm or comm
					 or lsrm or rorm or asrm;
				end loop;

				sren(5) <= addm or adcm 
					 or subm or subim or sbcm or sbcim or cpm or cpcm or cpim or negm;
		
				sren(6) <= bstm;		

				-- Data RAM signals
				ld_mar <= ldm or ld_incm or ld_decm or stm or st_incm or st_decm;
				ld_mbr <= stm or st_incm or st_decm;	
			
				-- I/O decoder signals
		 		wr_io <= outm;
		 		rd_io <= inm or sbicsm or cbisbim;
				if inm = '1' or outm = '1' then
					ioaddr <= conv_integer(ir(10 downto 9) & ir(3 downto 0));
				else
					ioaddr <= conv_integer('0' & ir(7 downto 3));
				end if;


				-- Branch Evaluation Unit signal
				branchtest <= brbcsm;


				-- Fetch I/O, generate C2A
				get_io <= cbisbim or sbicsm;

			end if;		

		when nop2s =>
			state <= nop1s;

		when nop1s =>                                                                              
			state <= exes;

		when cbisbis =>
			state <= exes;
			cbisbi <= '1'; 
			wr_io <= '1';
		
		when sbicss =>
			state <= exes;
			skiptest <= '1';

		when lds =>
			state <= exes;
			wr_reg <= '1';
			rd_ram <= '1';

		when sts =>
			state <= exes;
			wr_ram_fast <= '1';

		when sleeps =>
			en <= '0';
			if irq = '1' then
				en <= '1';
				state <= nop2s;
				push <= '1';
				if extirq = '1' then
					vec2 <= '1';
				else
					vec4 <= '1';
				end if;
			end if;

	end case;
	
end if;
end process;

-- Generate Delayed WR_RAM signal to avoid writing to wrong address
process(state, wr_ram_fast)
begin
	if state = exes then
		wr_ram <= wr_ram_fast;
	else
		wr_ram <= '0';
	end if;
end process;


-- Branch Evaluation Unit
process(branchtest, sr, ibr) 
begin
	if branchtest = '1' and (sr(conv_integer(ibr(2 downto 0))) = not ibr(10)) then
		branch <= '1';
	else
		branch <= '0';
	end if;
end process;


-- IO address decoder
iodec : v_iodecoder
	port map (ioaddr, rd_io, wr_io, rd_sreg, wr_sreg, rd_gimsk, wr_gimsk, rd_timsk, wr_timsk, rd_tifr, wr_tifr, rd_mcucr, wr_mcucr, rd_tccr0, wr_tccr0, rd_tcnt0, wr_tcnt0, rd_portb, wr_portb, rd_ddrb, wr_ddrb, rd_pinb, rd_portc, wr_portc, rd_ddrc, wr_ddrc, rd_pinc, rd_portd, wr_portd, rd_ddrd, wr_ddrd, rd_pind);


-- Intruction Buffer Register (IBR) to signals ------------------
dest <= conv_integer(ibr(7 downto 4));
srsel <= conv_integer(ibr(6 downto 4));
set <= ibr(9);
bitsel <= conv_integer(ibr(2 downto 0));
offset <= 	ibr(8 downto 0) when jmp = '1' else
			ibr(9) & ibr(9) & ibr(9 downto 3);


-- Generate Fetch Stage Signals : ASEL and SEL
imm <= subim or sbcim or cpim or andim or orim or ldim;
one <= incm or decm;
neg <= negm;

asel <= 1 when neg = '1' and get_io = '0' else
		0;
bsel <= 1 when neg = '1' else
		2 when imm = '1' else
		3 when one = '1' else
		0;


-- Decode Control Signal
addoffset <= branch or jmp; -- PC
clr_i <= vec2 or vec4; -- PC
clr_intf <= vec2; -- External Interrupt
clr_tov0 <= vec4; -- Timer

end controlunit;


