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

entity v_riscmcu is
	port (
		clock : in STD_LOGIC;
		reset : in STD_LOGIC;
		pinb : inout STD_LOGIC_VECTOR(7 downto 0);
		pinc : inout STD_LOGIC_VECTOR(7 downto 0);
		pind : inout STD_LOGIC_VECTOR(7 downto 0)
	);
end v_riscmcu;

architecture riscmcu of v_riscmcu is

signal ext_irq_pin, ext_timer_clk_pin : std_logic;

signal clk, clrn, div2, div4, div8, div16 : std_logic;
signal sr, reg_rd, reg_rr, c, addrbus: std_logic_vector(7 downto 0);

signal pc, offset : std_logic_vector(8 downto 0);
signal instruction, ir : std_logic_vector(15 downto 0);

signal skip, en, wr_reg : std_logic;
signal sren : std_logic_vector (6 downto 0);
signal c2a, c2b, add, subcp, logic, right, dir, pass_a : std_logic;
signal wcarry : std_logic;
signal logicsel : integer range 0 to 3;
signal rightsel : integer range 0 to 2;
signal dirsel : integer range 0 to 1;
signal addoffset, push, pull, cpse, skiptest : std_logic;
signal bclr,bset, bld, cbisbi : std_logic;
signal dest, rr, rd : integer range 0 to 15;
signal srsel : integer range 0 to 7;
signal imm_value : std_logic_vector(7 downto 0);

signal tosr : std_logic_vector (6 downto 0);

signal vec2, vec4, clr_i, set_i, clr_tov0, clr_intf, timerirq, extirq : std_logic;

signal rd_sreg,wr_sreg,rd_gimsk,wr_gimsk,rd_timsk, wr_timsk, rd_tifr,wr_tifr : std_logic;
signal rd_mcucr,wr_mcucr, rd_tccr0, wr_tccr0, rd_tcnt0,wr_tcnt0 : std_logic;
signal rd_portb,wr_portb,rd_ddrb,wr_ddrb,rd_pinb : std_logic;
signal rd_portc,wr_portc,rd_ddrc,wr_ddrc,rd_pinc : std_logic;
signal rd_portd,wr_portd,rd_ddrd,wr_ddrd,rd_pind : std_logic;

signal t_flag, c_flag : std_logic;

signal vcc, gnd : std_logic;

signal rd_ram, wr_ram, ld_mar, ld_mbr, inc_zp, dec_zp :std_logic;

signal bitsel : integer range 0 to 7;
signal set : std_logic;

signal asel : integer range 0 to 1;
signal bsel : integer range 0 to 3;

	-- Frequency Divider - Divide clock by 2(div2), 4(div4), 8(div8) and 16(div16)
	component v_freqdiv
	port (	clock : in std_logic;
		div2, div4, div8, div16 : buffer std_logic
	);
	end component;

	-- Program Counter (9 bit wide)
	component v_pc
	port (	offset : in std_logic_vector(8 downto 0);
		en, addoffset, push, pull, vec2, vec4 : in std_logic;
		clk, clrn : in std_logic;
		pc : buffer std_logic_vector(8 downto 0)
	);
	end component;

	-- Program ROM (512 words)
	component v_rom
	port (	pc : in std_logic_vector(8 downto 0);
		instruction : out std_logic_vector(15 downto 0)
	);
	end component;

	-- Instruction Register (16 bit wide)
	component v_ir
	port (	instruction : in std_logic_vector(15 downto 0);
		en, clk, clrn : in std_logic;
		ir : buffer std_logic_vector(15 downto 0);
		imm_value : out std_logic_vector(7 downto 0);
		rd, rr : out integer range 0 to 15
	);
	end component;

	-- Control Unit (with IO address decoder module inside)
	component v_controlunit
	port (	ir	: in std_logic_vector(15 downto 0);
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
	end component;

	-- General Purpose Register (16 x 8bit)
	component v_gpr
	port (	c : in std_logic_vector(7 downto 0);		
		wr_reg, inc_zp, dec_zp : in std_logic;
		rd, rr, dest : in integer range 0 to 15;
		clk, clrn : in std_logic;
		reg_rd, reg_rr, addrbus : out std_logic_vector(7 downto 0)
	);
	end component;

	-- ALU
	component v_alu
	port (	reg_rd, reg_rr, imm_value : in std_logic_vector(7 downto 0);
		c2a, c2b : in std_logic;
		asel : in integer range 0 to 1;
		bsel : in integer range 0 to 3;

		bitsel : in integer range 0 to 7;
		set : in std_logic;
		c_flag, t_flag : in std_logic;		
			
		add, subcp, logic, right, dir, bld, cbisbi, pass_a : in std_logic;
		cpse, skiptest : in std_logic;

		wcarry : in std_logic;
		logicsel : in integer range 0 to 3;
		rightsel : in integer range 0 to 2;
		dirsel : in integer range 0 to 1;

		clk, clrn : in std_logic;

		c : buffer std_logic_vector(7 downto 0);
		tosr : buffer std_logic_vector (6 downto 0);
		skip : out std_logic
	);
	end component;

	-- Status Register (8 bit wide, flags are ITHSVNZC)
	component v_sr
	port ( 	clk,clrn: in std_logic;
			sren,tosr : in std_logic_vector(6 downto 0);
			srsel : in integer range 0 to 7;
			clr_i,set_i,bset,bclr : in std_logic;
			rd_sreg, wr_sreg : in std_logic;
			c : inout std_logic_vector(7 downto 0);
			sr : inout std_logic_vector(7 downto 0)
	);
	end component;

	-- Data RAM (128 bytes)
	component v_ram
	port (	addrbus : in std_logic_vector(7 downto 0);
		rd_ram, wr_ram, ld_mar, ld_mbr : in std_logic;
		clk, clrn : in std_logic;
		c : inout std_logic_vector(7 downto 0)
	);
	end component;

	-- Standard 8-bit I/O Port module (all ports share this same module)
	component v_port
	port (	rd_port, wr_port, rd_ddr, wr_ddr, rd_pin : in std_logic;
		clk, clrn : in std_logic;
		c : inout std_logic_vector(7 downto 0);
		pin : inout std_logic_vector(7 downto 0)
	);
	end component;

	-- 8-bit Timer with overflow interrupt request, can drive by external clock source
	component v_timer
	port (	extpin, clr_tov0 : in std_logic;
		rd_timsk, wr_timsk, rd_tifr, wr_tifr : in std_logic;
		rd_tccr0, wr_tccr0, rd_tcnt0, wr_tcnt0 : in std_logic;
		clk, clrn : in std_logic;
		c : inout std_logic_vector(7 downto 0);
		timerirq : out std_logic
	);
	end component;

	-- External Interrupt
	component v_extint
	port (	clk, clrn, extpin, clr_intf : in std_logic;
		rd_mcucr, wr_mcucr, rd_gimsk, wr_gimsk : in std_logic;
		extirq	: out std_logic;
		c : inout std_logic_vector(7 downto 0)
	);
	end component;

begin
	--U_v_freqdiv: v_freqdiv
	--	port map (clock, div2, div4, div8, div16);

	U_v_pc: v_pc
		port map (offset, en, addoffset, push, pull, vec2, vec4, clk, clrn, pc);

	U_v_rom: v_rom
		port map (pc, instruction);

	U_v_ir: v_ir
		port map (instruction, en, clk, clrn, ir, imm_value, rd, rr);

	U_v_controlunit: v_controlunit
		port map (ir, sr, clk, clrn, skip, extirq, timerirq, en, wr_reg, rd_ram, wr_ram, ld_mar, ld_mbr, inc_zp, dec_zp, sren, c2a, c2b, asel, bsel, bitsel, set, add, subcp, logic, right, dir, pass_a, wcarry, logicsel, rightsel, dirsel, addoffset, push, pull, cpse, skiptest, bclr, bset, bld, cbisbi, vec2, vec4, dest, srsel, offset, clr_i, set_i, clr_intf, clr_tov0, rd_sreg, wr_sreg, rd_gimsk, wr_gimsk, rd_timsk, wr_timsk, rd_tifr, wr_tifr, rd_mcucr, wr_mcucr, rd_tccr0, wr_tccr0, rd_tcnt0, wr_tcnt0, rd_portb, wr_portb, rd_ddrb, wr_ddrb, rd_pinb, rd_portc, wr_portc, rd_ddrc, wr_ddrc, rd_pinc, rd_portd, wr_portd, rd_ddrd, wr_ddrd, rd_pind);

	U_v_gpr: v_gpr
		port map (c, wr_reg, inc_zp, dec_zp, rd, rr, dest, clk, clrn, reg_rd, reg_rr, addrbus);

	U_v_alu: v_alu
		port map (reg_rd, reg_rr, imm_value, c2a, c2b, asel, bsel, bitsel, set, c_flag, t_flag, add, subcp, logic, right, dir, bld, cbisbi, pass_a, cpse, skiptest, wcarry, logicsel, rightsel, dirsel, clk, clrn, c, tosr, skip);

	U_v_sr: v_sr
		port map (clk, clrn, sren, tosr, srsel, clr_i, set_i, bset, bclr, rd_sreg, wr_sreg, c, sr);

	U_v_ram: v_ram
		port map (addrbus, rd_ram, wr_ram, ld_mar, ld_mbr, clk, clrn, c);

	U_v_timer: v_timer
		port map (ext_timer_clk_pin, clr_tov0, rd_timsk, wr_timsk, rd_tifr, wr_tifr, rd_tccr0, wr_tccr0, rd_tcnt0, wr_tcnt0, clk, clrn, c, timerirq);

	U_v_extint: v_extint
		port map (clk, clrn, ext_irq_pin, clr_intf, rd_mcucr, wr_mcucr, rd_gimsk, wr_gimsk, extirq, c);

	-- The same module v_port is used by 3 I/O ports, just the signals are different
	U_v_portB: v_port
		port map (rd_portb, wr_portb, rd_ddrb, wr_ddrb, rd_pinb, clk, clrn, c, pinb);

	U_v_portC: v_port
		port map (rd_portc, wr_portc, rd_ddrc, wr_ddrc, rd_pinc, clk, clrn, c, pinc);

	U_v_portD: v_port
		port map (rd_portd, wr_portd, rd_ddrd, wr_ddrd, rd_pind, clk, clrn, c, pind);

	-- Global reset, it resets ALL flip-flops and registers to the initial state (normally gnd)
	clrn <= reset;
	
	vcc <= '1';
	gnd <= '0';
	t_flag <= sr(6);
	c_flag <= sr(0);
	
	-- These are the external interrupt request pin and external timer clock source pin
	-- They share pins with the I/O ports
	-- TIPS: You can use any of the 24 I/O pins, I use pind(7) for my applications
	ext_irq_pin <= pind(2);
	ext_timer_clk_pin <= pind(4);
	
	-- When I use the UP1 board, the on-board 25 MHz clock is too fast and
	-- I need to divide it by 4 so that the MCU can run
	-- For waveform simulation, it does not require division (clk <= clock)
	-- TIPS: To have division, uncomment v_freqdiv module instantation on top of the page and 
	--       assign clk with div2, div4, div8 or div16
	clk <= clock;

	
end riscmcu;


