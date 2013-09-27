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

TimeTestDone1:
	clc
	rts

TimeTestFail:
	lda #$14
	jsr TABV
	ldy #PMSGNoClock
	jsr WRITEMSGLEFT
	jmp TimeTestPromptDone

TimeTest:
	clc
	jsr InitTime
	bcs TimeTestFail
	ldy #PMSG05a	; Time title line
	jsr PICKVOL	; A now has index into DEVICES table; UNITNBR holds chosen unit
	bmi TimeTestDone1
	jsr GETVOLNAME	; TEST_FILE_NAME now holds the volume prefix and VOLNAMELEN is set
	ldx #$00
	ldy #$0b
	jsr GOTOXY
; 512K
	ldx VOLNAMELEN	; X now has the length of the test file name's prefix (volume)
	inx
	ldy #$00
:	lda Filename_512K,Y
	sta TEST_FILE_NAME,X
	inx
	iny
	cpy #$09
	bne :-
	dex
	stx TEST_FILE_NAME
	jsr FileOpen
	bcc :+
	jmp TimeTestDone1
:	lda #32
	sta FileSizeInChunks
	lda #$00
	sta FileSizeInChunks+1
	jsr GetTime	; Start timer
	jsr MoveTime
	jsr FileWrite
	php
	jsr GetTime	; End timer
	plp
	bcc TT1M
			; Done; jump to reading code
	jmp TimeTestPromptDone

; 1M
TT1M:
			; Print prior results
	jsr PrintTimeDifference
	ldx VOLNAMELEN	; X now has the length of the test file name's prefix (volume)
	inx
	ldy #$00
:	lda Filename_1M,Y
	sta TEST_FILE_NAME,X
	inx
	iny
	cpy #$09
	bne :-
	dex
	stx TEST_FILE_NAME
	jsr FileOpen
	bcc :+
	jmp TimeTestDone1
:	lda #64
	sta FileSizeInChunks
	lda #$00
	sta FileSizeInChunks+1
	jsr GetTime	; Start timer
	jsr MoveTime
	jsr FileWrite
	php
	jsr GetTime	; End timer
	plp
	bcc TT2M
			; Done; jump to reading code
	jmp TimeTestPromptDone

; 2M
TT2M:
			; Print prior results
	jsr PrintTimeDifference
	ldx VOLNAMELEN	; X now has the length of the test file name's prefix (volume)
	inx
	ldy #$00
:	lda Filename_2M,Y
	sta TEST_FILE_NAME,X
	inx
	iny
	cpy #$09
	bne :-
	dex
	stx TEST_FILE_NAME
	jsr FileOpen
	bcc :+
	jmp TimeTestDone1
:	lda #128
	sta FileSizeInChunks
	lda #$00
	sta FileSizeInChunks+1
	jsr GetTime	; Start timer
	jsr MoveTime
	jsr FileWrite
	php
	jsr GetTime	; End timer
	plp
	bcc TT4M
			; Done; jump to reading code
	jmp TimeTestPromptDone

; 4M
TT4M:
			; Print prior results
	jsr PrintTimeDifference
	ldx VOLNAMELEN	; X now has the length of the test file name's prefix (volume)
	inx
	ldy #$00
:	lda Filename_4M,Y
	sta TEST_FILE_NAME,X
	inx
	iny
	cpy #$09
	bne :-
	dex
	stx TEST_FILE_NAME
	jsr FileOpen
	bcc :+
	jmp TimeTestDone1
:	lda #0
	sta FileSizeInChunks
	lda #$01	; 256
	sta FileSizeInChunks+1
	jsr GetTime	; Start timer
	jsr MoveTime
	jsr FileWrite
	php
	jsr GetTime	; End timer
	plp
	bcc TT8M
			; Done; jump to reading code
	jmp TimeTestPromptDone

; 8M
TT8M:
			; Print prior results
	jsr PrintTimeDifference
	ldx VOLNAMELEN	; X now has the length of the test file name's prefix (volume)
	inx
	ldy #$00
:	lda Filename_8M,Y
	sta TEST_FILE_NAME,X
	inx
	iny
	cpy #$09
	bne :-
	dex
	stx TEST_FILE_NAME
	jsr FileOpen
	bcc :+
	jmp TimeTestDone1
:	lda #0
	sta FileSizeInChunks
	lda #$02	; 512
	sta FileSizeInChunks+1
	jsr GetTime	; Start timer
	jsr MoveTime
	jsr FileWrite
	php
	jsr GetTime	; End timer
	plp
	bcc TT16M
			; Done; jump to reading code
	jmp TimeTestPromptDone

; 16M
TT16M:
			; Print prior results
	jsr PrintTimeDifference
	ldx VOLNAMELEN	; X now has the length of the test file name's prefix (volume)
	inx
	ldy #$00
:	lda Filename_16M,Y
	sta TEST_FILE_NAME,X
	inx
	iny
	cpy #$09
	bne :-
	dex
	stx TEST_FILE_NAME
	jsr FileOpen
	bcc :+
	jmp TimeTestDone1
:	lda #$00
	sta FileSizeInChunks
	lda #$04	; 1024
	sta FileSizeInChunks+1
	jsr GetTime	; Start timer
	jsr MoveTime
	jsr FileWrite
	php
	jsr GetTime	; End timer
	plp
	bcs TimeTestPromptDone
			; Only report on successful test
	jsr PrintTimeDifference


; All done - print a final message
TimeTestPromptDone:
	lda #$15
	jsr TABV
	ldy #PMSG16
	jsr WRITEMSGLEFT
	bit $C010
	jsr RDKEY
	rts

;
; MoveTime - moves the time from the clock loading area to another holding place.
;
MoveTime:
	ldx #$03
:	lda TimeNow,X
	sta Time2,X
	dex
	bpl :-
	rts

;
; 
;
PrintTimeDifference:
	jsr CROUT
			; Calculate seconds
	sec
	lda TimeNow+2
	sbc Time2+2
	bcs :+
	adc #60
	dec TimeNow+1 
:	sta Elapsed+2
			; Calculate minutes
	sec
	lda TimeNow+1
	sbc Time2+1
	bcs :+
	adc #60
	dec TimeNow
:	sta Elapsed+1
			; Calculate hours
	sec
	lda TimeNow
	sbc Time2
	bcs :+
	adc #24
:	sta Elapsed
			; Print them back out, in reverse order
	jsr ToDecimal
	lda Elapsed+1
	jsr ToDecimal
	lda Elapsed+2
	jsr ToDecimal
	rts

TimeNow:
	.res 4,0	; Filled in by gettime.asm: Hours, Minutes, Seconds, Hundredths	
Time2:	.res 4,0
Elapsed:
	.res 4
