.include "riscmcu.inc"

.def	temp = r16
.def	times = r17
.def	num = r18
.def	stack = r19
.def	counter = r20
.def	life = r22
.def	level = r23
.def	temp2 = r24

.cseg
	rjmp	reset
	reti
	reti

reset:
	ldi	counter,5

	ser	temp
	out	ddrb,temp	; Port B direction as OUTPUT
	out	ddrd,temp	; Port D direction as OUTPUT
	out	portc,temp
	out	portd,temp
	
	ldi	temp,1
	out	tccr0,temp	; set clock as timer clock source
	ldi	temp,$0F	 
	out	ddrc,temp	; PinC[3..0] output, [7..4] input

start:
	ldi	life,3
	ldi	level,1
	clt			; T = 0, start with correct

	rcall	getinput	; hit any key to start the game
	rcall	showlife
	out	portB,level	; output level to display
	rcall	holding		; release? 

nextlevel:
	rcall	delay		; wait a while before the game is started
	rcall	showled		; show the LEDs and save it in buffer
nlife:	rcall	check		; get input and check
	brts	wrong
	rcall	greenled
	inc	level		; when win, level <- level + 1
	out	portB,level	; output level to display
	rjmp	nextlevel
wrong:	rcall	redled
	rcall	delay
	dec	life
	rcall	showlife
	out	portb,level
	rcall	delay
	cpi	life,0
	breq	start
	rcall	playback
	clt
	rjmp	nlife


;*******************************************
; show life
showlife:
	mov	temp,life
	sbr	temp,$f0
	out	portb,temp
	rcall	delay
	rcall	delay
	ret

;*******************************************
; on red leds

redled:
	clr	temp
	out	portc,temp
	rcall	delay
	ser	temp
	out	portc,temp
	ret

;*******************************************
; on green led

greenled:
	cbi	portd,7	
	rcall	delay
	sbi	portd,7
	ret


;*******************************************
; play back the last sequence when wrong

playback:
	rcall	init
w10:	ld	temp,Z+
	out	portC,temp
	rcall	delay
	ser	temp		; OFF
	out	portC,temp	
	ldi	counter,1
	rcall	delay
	dec	times
	brne	w10
	ret
	
;*******************************************
; Show sequence of LEDs (base on times), save in buffer

showled:
	rcall	init
snext:	rcall	random		; return in NUM
	st	Z+,num
	out	portC,num	; display the LED
	rcall	delay
	ser	temp		; OFF
	out	portC,temp	
	ldi	counter,1
	rcall	delay
	dec	times
	brne	snext
	ret


;*******************************************
; wait for input and check
; return T = 0 when corrert, T = 1 when wrong

check:
	rcall	init	
nextkey:
	rcall	holding
	sei
	rcall	getinput	; return in NUM
	cli
	ld	temp,Z+
	cpse	num,temp
	set			; Set T flag if one key is wrong
	rcall	holding
	rcall	sdelay
	dec	times
	brne	nextkey
	ret

;*******************************************
; still holding the key ?

holding:
	in	temp,pinc
	cbr	temp,$0F
	cpi	temp,$F0
	brne	holding
	ret

;*******************************************
; getinput

getinput:
g15:	in	num,pinc
	cbr	num,$0F	; clear lower nibble
	cpi	num,$F0
	breq	g15
	rcall	sdelay
	in	temp,pinc
	cbr	temp,$0F
	cp	temp,num
	brne	g15
	swap	num
	ret
	
;*******************************************
; 1. Load level to times
; 2. ZP point to start of buffer

init:	mov	times,level	; times <- level
	ldi	ZP,buffer	; ZP <- buffer
	ret
	
;*******************************************
; Generate Random Num, return in NUM

random:
	in	num,tcnt0
ran:	cpi	num,4
	brlo	rnext
	subi	num,4	
	rjmp	ran
rnext:	cpi	num,0
	brne	r10
	ldi	num,0b1110
	rjmp	rend
r10:	cpi	num,1
	brne	r20
	ldi	num,0b1101
	rjmp	rend
r20:	cpi	num,2
	brne	r30
	ldi	num,0b1011
	rjmp	rend
r30:	ldi	num,0b0111
rend:	in	temp,tcnt0
	ror	temp
	ror	temp
	out	tcnt0,temp
	ret

;*******************************************	
delay:
	mov	stack,ZP
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
	ldi	counter,5
	mov	ZP,stack
	ret

sdelay:
	clr	temp
sd5:	dec	temp
	brne	sd5
	ret
;*******************************************
.dseg
count:	.byte	2
buffer:	.byte	20