; This program is for simulation purpose
; It demo how the MCU output 3, 2 and 1 to each port (Port B, Port C and Port D)
; There are 3 approaches used in accomplishing the above task

.include "riscmcu.inc"

.def	B = r16
.def	C = r17
.def	D = r18
.def	TEMP = r19



	rjmp	reset		; reset vector
	ret			; external interrupt vertor(not use)
	ret			; timer overflow interrupt vertor (not use)


reset:
	clr	TEMP		; r19 = 00
	com	TEMP		; r19 = FF
	out	DDRB,TEMP	; set all Port B pins as output
	out	DDRC,TEMP	; set all Port C pins as output
	out	DDRD,TEMP	; set all Port D pins as output



; Approach 1, output to Port B

	ldi	B,3		; r16 = 03
again1:	out	PORTB,B		; Port B now output 03
	dec	B		; r16 = r16 - 1
	cpi	B,0		; if r16 = 0,
	brne	again1		;   branch to again1
				


; Approach 2, output to Port C

	clr	TEMP		; r19 = 00
	inc	C		; r17 = 01
	inc	C		; r17 = 02
	inc	C		; r17 = 03
again2:	out	PORTC,C		; Port C now output 03
	subi	C,1		; r17 = r17 - 1
	cpse	C,TEMP		; if r17 != r19 (means if r17 != 0),
	rjmp	again2		;    branch to again2
				


; Approach 3, output to Port D

	clr	D		; r18 = 00
	subi	D,-3		; r18 = r18 - (-3) = 03
again3:	out	PORTD,D		; Port D now output 03
	dec	D		; r18 = r18 -1
	in	TEMP,SREG	; transfer the value of SR to R19
	sbrs	TEMP,1		; if bit 1 in R19 (the Z-flag) is set, skip the next instruction
	rjmp	again3		;    else branch to again3
				


end:	rjmp	end		; Branch Forever
	sei			; (Set I-Bit in SR) This 2 instructions won't execute 
	set			; (Set T-Bit in SR)   even they are fetched to the IR
	



