;
; SPF - Stress ProDOS Filesystem
; Copyright (C) 2013 by David Schmidt
; david__schmidt at users.sourceforge.net
;
; This program is free software; you can redistribute it and/or modify it 
; under the terms of the GNU General Public License as published by the 
; Free Software Foundation; either version 2 of the License, or (at your 
; option) any later version.
;
; This program is distributed in the hope that it will be useful, but 
; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
; or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License 
; for more details.
;
; You should have received a copy of the GNU General Public License along 
; with this program; if not, write to the Free Software Foundation, Inc., 
; 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
;

InitTime:
	sec
	jsr $FE1F	; CheckForGS
	bcc FoundClockGS
	jsr CheckForNoSlotClock
	bcc FoundClockNoSlot
	jsr CheckForSlottedClocks
	rts

FoundClockGS:
;---------------------------------------------------------
; Patch the entry point of GetTIme to the IIgs version
;---------------------------------------------------------
	lda #<GetTimeGS
	sta GetTime+1
	lda #>GetTimeGS
	sta GetTime+2
	rts

FoundClockNoSlot:
;---------------------------------------------------------
; Patch the entry point of GetTIme to the NoSlotClock version
;---------------------------------------------------------
	lda #<GetTimeNSC
	sta GetTime+1
	lda #>GetTimeNSC
	sta GetTime+2
	rts

GetTime:
	jsr $0000
	rts


GetTimeGS:
;---------------------------------------------------------
; Get the current time on the GS
;---------------------------------------------------------
.P816
	clc
	.byte $FB	; xce
	rep #$30
.A16
.I16
	pha
	pha
	pha
	pha
	ldx #$0D03
	jsl $E10000
	sep #$30
.I8
	ldx #7
GTGSLoop:
	pla
	sta GSTime,X
	dex
	bpl GTGSLoop
	sec
	.byte $FB	; xce
.A8
	lda GSTime+5	; Hours
	sta TimeNow
	lda GSTime+6	; Minutes
	sta TimeNow+1
	lda GSTime+7	; Seconds
	sta TimeNow+2
	lda #$00	; Hundredths (not available on GS)
	sta TimeNow+3
	rts
.P02

GSTime:
	.res 8

;---------------------------------------------------------
; BASIC test program for the GS time-getting algorithm
;---------------------------------------------------------

;10 X = 768:Z = 803
;20 READ Y: IF Y >  - 1 THEN  POKE X,Y:X = X + 1: GOTO 20
;30 DATA 56,32,31,254,144,1,96,251,194,48,72,72,72,72
;40 DATA 162,3,13,34,0,0,225,226,48,162,7,104,157,35,3
;50 DATA 202,16,249,56,251,96,-1
;60 CALL 768
;70 WD =  PEEK (Z): REM Weekday (1=Sun...7=Sat)
;80 MO =  PEEK (Z+2): REM Month (0=Jan...11=Dec)
;90 DA =  PEEK (Z+3): REM Day (0...30)
;100 YR =  PEEK (Z+4): REM Year-1900
;110 HR =  PEEK (Z+5): REM Hour (0...23)
;120 MN =  PEEK (Z+6): REM Minute (0...59)
;130 SC =  PEEK (Z+7): REM Second (0...59)
;140 PRINT "Hour: ";HR;" Minute: ";MN;" Second: ";SC

GetTimeNSC:
	jsr NSCEntry
	lda L0307	; Hours
	sta TimeNow
	lda L0308	; Minutes
	sta TimeNow+1
	lda L0309	; Seconds
	sta TimeNow+2
	lda L030A	; Hundredths
	sta TimeNow+3
	rts

CheckForNoSlotClock:
	jsr PrepNoSlotClock	; Prepare the driver
	jsr NSCEntry		; Call it to get the time
	lda L0304		; Signature will be non-zero if NSC exists
	clc
	bne :+
	sec
:	rts

PrepNoSlotClock:
;---------------------------------------------------------
; Look for a NoSlotClock
;---------------------------------------------------------

L3A3A	= $3A3A
LDA9A	= $DA9A
LDD6C	= $DD6C
LDEBE	= $DEBE
LDFE3	= $DFE3
LE3E9	= $E3E9

L0260:	lda #$00
	sta L02DE
	lda #$03
L0267:  ora #$C0
	sta L031F
L026C:  sta L0322
	sta L0331
	sta L033F
	lda #$03
	sta L02DF
	bne L0292
	brk
	brk
	brk
L027F:  brk
L0280:  brk
	brk
	.byte $2F
L0283:  brk
	brk
	.byte $2F
	brk
	brk
	jsr $0000
	.byte $3A
	brk
	brk
	.byte $3A
	brk
	brk
	.byte $8D
L0292:  jsr NSCEntry
	ldx #$07
L0297:  lda L0303,x
	cmp L02E0,x
	bcc L02AE
	cmp L02E8,x
	bcs L02AE
	dex
	bpl L0297
	dec L02DF
	bne L0292
	clc
	rts
L02AE:  inc L02DE
	lda L02DE
	cmp #$08
	bcc L0267
	bne L02D7
	lda #$C0
	ldy #$15
	sta L031B
	sty L031A
	ldy #$07
	sta L031F
	sty L031E
	dey
	sta L036F
	sty L036E
	lda #$C8
	bne L026C
L02D7:  lda #$4C
	sta L0316
	sec
	rts
L02DE:  brk
L02DF:  brk
L02E0:  brk
	.byte $01, $01, $01
	brk
	brk
	brk
	brk
L02E8:  .byte $64, $0d, $20, $38, $98,$3c, $3c, $64
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	brk
	clc
	.byte $90
L0302:	.byte $09
L0303:  brk
L0304:	brk
	brk
	brk
L0307:	brk
L0308:	brk
L0309:	brk
L030A:	brk
NSCEntry:
	sec
L030C:	php
	sei
	lda #$00
	sta L0304
;	sta L0280
L0316:	lda L03A3
	.byte $AD
L031A:	.byte $FF
L031B:	.byte $CF
	pha
	.byte $8D
L031E:	brk
L031F:  .byte $C3
	.byte $AD
	.byte $04
L0322:	.byte $C3
	ldx #$08
L0325:	lda L03BF,x
	sec
	ror a
L032A:	pha
	lda #$00
	rol a
	tay
	.byte $B9
	brk
L0331:	.byte $C3
	pla
	lsr a
	bne L032A
	dex
	bne L0325
	ldx #$08
L033B:	ldy #$08
L033D:	.byte $AD
	.byte $04
L033F:	.byte $C3
	ror a
	ror $42
	dey
	bne L033D
	lda $42
	sta L027F,x
	lsr a
	lsr a
	lsr a
	lsr a
	tay
	lda $42
	cpy #$00
	beq L035E
	and #$0F
	clc
L0359:	adc #$0A
	dey
	bne L0359
L035E:	sta L0302,x
	dex
	bne L033B
	pla
	bmi L0370
	.byte $8D
L036E:	.byte $FF
L036F:	.byte $CF
L0370:	ldy #$11
	ldx #$06
L03A3:	plp
	bcs L03BF
	jsr LDEBE
	jsr LDFE3
	jsr LDD6C
	sta $85
	sty $86
	lda #$80
	ldy #$02
	ldx #$8D
	jsr LE3E9
	jsr LDA9A
L03BF:	rts
	.byte $5C
	.byte $A3
	.byte $3A
	cmp $5C
	.byte $A3
	.byte $3A
L03C7:	cmp $2F
	.byte $2F
	jsr L3A3A
	.byte $8D, $00, $00

CheckForSlottedClocks:
;---------------------------------------------------------
; Look for clocks via signature in firmware
;---------------------------------------------------------
	sec
; Finding a Thunderclock: first 3 bytes of firmware are $10, $F0, $50.
; Need to iterate through slots and see.
FindClockSlot:
	lda #$00
	tay
	sta UTILPTR
	sta ClockSlot
	ldx #$07 ; Slot number
FindClockSlotLoop:
	clc
	txa
	adc #$c0
	sta UTILPTR+1
	ldy #$00		; Lookup offset
	lda (UTILPTR),y
	cmp #$10		; Is $Cn00 == $10?
	bne NotThunder
	iny			; Lookup offset
	lda (UTILPTR),y
	cmp #$f0		; Is $Cn01 == $f0?
	bne NotThunder
	iny			; Lookup offset
	lda (UTILPTR),y
	cmp #$50		; Is $Cn02 == $50?
	bne NotThunder
; Ok, we have a set of signature bytes for a Thunderclock.
	stx ClockSlot
	jsr PrepThunderclock
	jmp FindClockSlotDone
NotThunder:
FindClockSlotNext:
	dex
	bne FindClockSlotLoop
; All done now, return with carry clear if we found a clock
FindClockSlotDone:
	sec
	lda ClockSlot
	beq :+
	clc
:	rts
ClockSlot:	.byte 0

PrepThunderclock:
	rts


GetTimeThunderclock:
;---------------------------------------------------------
; Get the current time from a Thunderclock - and convert from BCD
;---------------------------------------------------------
	lda ClockSlot
	asl a
	asl a
	asl a
	asl a
	tay
	lda #$18
	jsr L701B
	lda #$08
	jsr L701B
	ldx #$0A
L7011:	jsr L7033
	sta L7069,x
	dex
	bne L7011
	clc
	lda TKH1
	ldx #$0a
:	adc TKH2
	dex
	bne :-
	lda TKH2	; Hours
	sta TimeNow
	clc
	lda TKM1
	ldx #$0a
:	adc TKM2
	dex
	bne :-
	lda TKM2	; Minutes
	sta TimeNow+1	
	clc
	lda TKS1
	ldx #$0a
:	adc TKS2
	dex
	bne :-
	lda TKS2	; Seconds
	sta TimeNow+2
	lda #$00	; Hundredths (not available on Thunderclock)
	sta TimeNow+3
	rts
L701B:	sta $C080,y
	ora #$04
	sta $C080,y
	jsr L702B
	eor #$04
	sta $C080,y
L702B:	jsr L702E
L702E:	pha
	pha
	pla
	pla
	rts
L7033:	pha
	lda #$04
	sta L7068
	lda #$00
	sta L7069
L703E:	lda $C080,y
	asl a
	ror L7069
	pla
	pha
	and #$01
	sta $C080,y
	ora #$02
	sta $C080,y
	eor #$02
	sta $C080,y
	pla
	ror a
	pha
	dec L7068
	bne L703E
	pla
	lda L7069
	clc
	ror a
	ror a
	ror a
	ror a
	rts
L7068:	brk
L7069:	brk
	brk
	brk
	brk
	brk
TKH1:	brk
TKH2:	brk
TKM1:	brk
TKM2:	brk
TKS1:	brk
TKS2:	brk
