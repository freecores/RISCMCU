
;***** I/O Register Definitions

.equ	SREG	=$3f
.equ	GIMSK	=$3b
.equ	TIMSK	=$39
.equ	TIFR	=$38
.equ	MCUCR	=$35
.equ	TCCR0	=$33
.equ	TCNT0	=$32

.equ	PORTB	=$18
.equ	DDRB	=$17
.equ	PINB	=$16
.equ	PORTC	=$15
.equ	DDRC	=$14
.equ	PINC	=$13
.equ	PORTD	=$12
.equ	DDRD	=$11
.equ	PIND	=$10


;***** Bit Definitions

.equ	INT0	=6

.equ	TOIE0	=1

.equ	TOV0	=1

.equ	ISC01	=1
.equ	ISC00	=0

.equ	CS02	=2
.equ	CS01	=1
.equ	CS00	=0

.def	ZP 	=r30

