.include "riscmcu.inc"

.def 	key = r16
.def	temp = r17
.def	B = r18
.def	C = r19
.def	addsub = r24
.def	counter = r25
.def	tcount = r26
.def	led = r27

.cseg
	rjmp	reset
	rjmp	extint
	rjmp	timer

extint:
	clr	B
	clr	C
	clr	addsub
	out	portb,c
	reti

timer:
	in	temp,sreg
	inc	tcount
	cpi	tcount,24
	brne	tback
	clr	tcount
	cpi	led,0b10000
	brne	t4
	ldi	led,0b0001	
t4:	com	led
	out	portc,led
	com	led
	lsl	led
	out	sreg,temp
tback:	reti			


reset:

	clr	B
	clr	C
	clr	addsub
	ldi	counter,3
	ldi	led,0b0001

	ldi	temp,0b11110000
	out	ddrd,temp
	ser	temp
	out	ddrb,temp	; PORT B as output
	out	ddrc,temp	; PORT C as output
	out	portc,temp	; PORT C leds OFF
	out	portd,temp	; PORT D output HI
	out	gimsk,temp	; Enable external interrupt
	out	timsk,temp	; Enable Timer interrupt
	ldi	temp,5
	out	tccr0,temp	; timer clock source = divide by 1024

	rcall	ldtable
	sei

;*************************************************
; Detect Keys

rescan: rcall	sdelay
	
	sbi	portd,6
	cbi	portd,4
	ldi	zp,table
	in	key,pind
	cbr	key,$F0
	cpi	key,$0F
	brne	press

	sbi	portd,4
	cbi	portd,5
	ldi	zp,table+1
	in	key,pind
	cbr	key,$F0
	cpi	key,$0F
	brne	press

	sbi	portd,5
	cbi	portd,6
	ldi	zp,table+2
	in	key,pind
	cbr	key,$F0
	cpi	key,$0F
	brne	press

	rjmp	rescan

press:
	rcall	sdelay
	in	temp,pind
	cbr	temp,$F0
	cpse	key,temp
	rjmp	rescan
	sbrs	key,1
	subi	zp,-3
	sbrs	key,2
	subi	zp,-6
	sbrs	key,3	
	subi	zp,-9
	ld	key,Z

;*************************************************
; Operation

	cpi	key,$A
	breq	addkey
	cpi	key,$B
	breq	subkey
	
	swap	B
	cbr	B,$0f
	add	B,key
	out	portb,B

	rjmp	holding

addkey:
	cbr	addsub,$01
	rjmp	arith

subkey:
	sbr	addsub,$01

arith:
	swap	addsub
	sbrc	addsub,0
	rjmp	subf
	rcall	BCDadd
	out	portb,C
	rcall	overflow
	clr	B
	rjmp	holding

subf:
	rcall	BCDsub
	out	portb,C
	rcall	overflow
	clr	B
	rjmp	holding

;*************************************************
; Key press released ?

holding:
	rcall	sdelay
	in	key,pind
	cbr	key,$F0
	ldi	temp,$0F
	cpse	key,temp
	rjmp	holding
	rjmp	rescan

;*************************************************
; overflow ?

overflow:
	sbrs	b,0
	ret
	cli
	sbi	ddrd,7
	cbi	portd,7
	rcall	delay
	sbi	portd,7
	cbi	ddrd,7
	sei
	ret

;*************************************************
; Short Delay

sdelay:
	clr	temp
s10:	dec	temp
	brne	s10
	ret

;*************************************************
; Load Table

ldtable:
	ldi	ZP,table
	ldi	temp,1
	st	Z+,temp
	ldi	temp,2
	st	Z+,temp
	ldi	temp,3
	st	Z+,temp
	ldi	temp,4
	st	Z+,temp
	ldi	temp,5
	st	Z+,temp
	ldi	temp,6
	st	Z+,temp
	ldi	temp,7
	st	Z+,temp
	ldi	temp,8
	st	Z+,temp
	ldi	temp,9
	st	Z+,temp
	ldi	temp,$B
	st	Z+,temp
	ldi	temp,0
	st	Z+,temp
	ldi	temp,$A
	st	Z+,temp
	ret

;*******************************************	
delay:
del:	ldi	ZP,count
	ld	temp,Z
	dec	temp
	st	Z,temp
	brne	del
	ldi	ZP,count+1
	ld	temp,Z
	dec	temp
	st	Z,temp
	brne	del
	dec	counter
	brne	del
	ldi	counter,3
	ret

;***** Subroutine Register Variables

.def	BCD1	=r19		;BCD input value #1
.def	BCD2	=r18		;BCD input value #2
.def	tmpadd	=r16		;temporary register

;***** Code

BCDadd:
	ldi	tmpadd,6	;value to be added later
	add	BCD1,BCD2	;add the numbers binary
	clr	BCD2		;clear BCD carry
	brcc	add_0		;if carry not clear
	ldi	BCD2,1		;    set BCD carry
add_0:	brhs	add_1		;if half carry not set
	add	BCD1,tmpadd	;    add 6 to LSD
	brhs	add_2		;    if half carry not set (LSD <= 9)
	subi	BCD1,6		;        restore value
	rjmp	add_2		;else
add_1:	add	BCD1,tmpadd	;    add 6 to LSD
add_2:	swap	tmpadd
	add	BCD1,tmpadd	;add 6 to MSD
	brcs	add_4		;if carry not set (MSD <= 9)
	sbrs	BCD2,0		;    if previous carry not set
	subi	BCD1,$60	;	restore value 
add_3:	ret			;else
add_4:	ldi	BCD2,1		;    set BCD carry
	ret


;***** Subroutine Register Variables

.def	BCDa	=r19		;BCD input value #1
.def	BCDb	=r18		;BCD input value #2

;***** Code

BCDsub:
	sub	BCDa,BCDb	;subtract the numbers binary
	clr	BCDb
	brcc	sub_0		;if carry not clear
	ldi	BCDb,1		;    store carry in BCDB1, bit 0
sub_0:	brhc	sub_1		;if half carry not clear
	subi	BCDa,$06	;    LSD = LSD - 6
sub_1:	sbrs	BCDb,0		;if previous carry not set
	ret			;    return
	subi	BCDa,$60	;subtract 6 from MSD
	ldi	BCDb,1		;set underflow carry
	brcc	sub_2		;if carry not clear
	ldi	BCDb,1		;    clear underflow carry	
sub_2:	ret			



	
.dseg
table:	.byte	12
count:	.byte	2