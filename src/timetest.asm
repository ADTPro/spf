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
	jsr SetupTTScreen

; Write - 512K
	ldx VOLNAMELEN	; X now has the length of the test file name's prefix (volume)
	inx
	ldy #$00
:	lda Filename_512K,Y
	sta TEST_FILE_NAME,X
	inx
	iny
	cpy #Filename_Len
	bne :-
	dex
	stx TEST_FILE_NAME
	jsr FileOpenNew
	bcc :+
	jmp TimeTestPromptDone
:	lda #32		; 32 chunks = 512K
	sta FileSizeInChunks
	lda #$00
	sta FileSizeInChunks+1
	jsr GetTime	; Start timer
	jsr MoveTime
	jsr FileWrite
	php
	jsr GetTime	; End timer
	plp
	bcc TT1MW
			; Done; jump to reading code
	jmp WritingPhaseDone

; 1M
TT1MW:
			; Print prior results
	lda #$00	; Prior timing was for 512k ($0200)
	sta <dividend
	lda #$02
	sta <dividend+1
	ldx #$06
	ldy #$06
	jsr GOTOXY
	jsr PrintTimeDifference
	ldx VOLNAMELEN	; X now has the length of the test file name's prefix (volume)
	inx
	ldy #$00
:	lda Filename_1M,Y
	sta TEST_FILE_NAME,X
	inx
	iny
	cpy #Filename_Len
	bne :-
	dex
	stx TEST_FILE_NAME
	jsr FileOpenNew
	bcc :+
	jmp TimeTestPromptDone
:	lda #64		; 64 chunks = 1M
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
	jmp WritingPhaseDone

; 2M
TT2M:
			; Print prior results
	lda #$00	; Prior timing was for 1M ($0400K)
	sta <dividend
	lda #$04
	sta <dividend+1
	ldx #$06
	ldy #$07
	jsr GOTOXY
	jsr PrintTimeDifference
	ldx VOLNAMELEN	; X now has the length of the test file name's prefix (volume)
	inx
	ldy #$00
:	lda Filename_2M,Y
	sta TEST_FILE_NAME,X
	inx
	iny
	cpy #Filename_Len
	bne :-
	dex
	stx TEST_FILE_NAME
	jsr FileOpenNew
	bcc :+
	jmp TimeTestPromptDone
:	lda #128	; 128 chunks = 2M
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
	jmp WritingPhaseDone

; 4M
TT4M:
			; Print prior results
	lda #$00	; Prior timing was for 2M ($0800K)
	sta <dividend
	lda #$08
	sta <dividend+1
	ldx #$06
	ldy #$08
	jsr GOTOXY
	jsr PrintTimeDifference
	ldx VOLNAMELEN	; X now has the length of the test file name's prefix (volume)
	inx
	ldy #$00
:	lda Filename_4M,Y
	sta TEST_FILE_NAME,X
	inx
	iny
	cpy #Filename_Len
	bne :-
	dex
	stx TEST_FILE_NAME
	jsr FileOpenNew
	bcc :+
	jmp TimeTestPromptDone
:	lda #0
	sta FileSizeInChunks
	lda #$01	; 256 chunks = 4M
	sta FileSizeInChunks+1
	jsr GetTime	; Start timer
	jsr MoveTime
	jsr FileWrite
	php
	jsr GetTime	; End timer
	plp
	bcs WritingPhaseDone
			; Only report on successful test
	lda #$00	; Prior timing was for 4M ($1000K)
	sta <dividend
	lda #$10
	sta <dividend+1
	ldx #$06
	ldy #$09
	jsr GOTOXY
	jsr PrintTimeDifference

WritingPhaseDone:
	lda ESCAPE_REQ		; Check if we got here because of escape; if so, we're all done.
	beq ReadingPhaseBegin	; Zero means no escape.
	lda #$00
	sta ESCAPE_REQ
	jmp TimeTestPromptDone

ReadingPhaseBegin:	
; Read - 512K
	ldx VOLNAMELEN	; X now has the length of the test file name's prefix (volume)
	inx
	ldy #$00
:	lda Filename_512K,Y
	sta TEST_FILE_NAME,X
	inx
	iny
	cpy #Filename_Len
	bne :-
	dex
	stx TEST_FILE_NAME
	jsr FileOpen
	bcc :+
	jmp TimeTestPromptDone
:	lda #32
	sta FileSizeInChunks
	lda #$00
	sta FileSizeInChunks+1
	jsr GetTime	; Start timer
	jsr MoveTime
	jsr FileRead
	php
	jsr GetTime	; End timer
	plp
	bcc TT1MR
			; Done done done
	jmp ReadingPhaseDone

; Read - 1M
TT1MR:
			; Print prior results
	lda #$00	; Prior timing was for 512k ($0200)
	sta <dividend
	lda #$02
	sta <dividend+1
	ldx #$12
	ldy #$06
	jsr GOTOXY
	jsr PrintTimeDifference
	ldx VOLNAMELEN	; X now has the length of the test file name's prefix (volume)
	inx
	ldy #$00
:	lda Filename_1M,Y
	sta TEST_FILE_NAME,X
	inx
	iny
	cpy #Filename_Len
	bne :-
	dex
	stx TEST_FILE_NAME
	jsr FileOpen
	bcc :+
	jmp TimeTestPromptDone
:	lda #64
	sta FileSizeInChunks
	lda #$00
	sta FileSizeInChunks+1
	jsr GetTime	; Start timer
	jsr MoveTime
	jsr FileRead
	php
	jsr GetTime	; End timer
	plp
	bcc TT2MR
			; Done done done
	jmp ReadingPhaseDone

TT2MR:
			; Print prior results
	lda #$00	; Prior timing was for 1M ($0400)
	sta <dividend
	lda #$04
	sta <dividend+1
	ldx #$12
	ldy #$07
	jsr GOTOXY
	jsr PrintTimeDifference
	ldx VOLNAMELEN	; X now has the length of the test file name's prefix (volume)
	inx
	ldy #$00
:	lda Filename_2M,Y
	sta TEST_FILE_NAME,X
	inx
	iny
	cpy #Filename_Len
	bne :-
	dex
	stx TEST_FILE_NAME
	jsr FileOpen
	bcc :+
	jmp TimeTestPromptDone
:	lda #128
	sta FileSizeInChunks
	lda #$00
	sta FileSizeInChunks+1
	jsr GetTime	; Start timer
	jsr MoveTime
	jsr FileRead
	php
	jsr GetTime	; End timer
	plp
	bcc TT4MR
			; Done done done
	jmp ReadingPhaseDone

TT4MR:
			; Print prior results
	lda #$00	; Prior timing was for 2M ($0800)
	sta <dividend
	lda #$08
	sta <dividend+1
	ldx #$12
	ldy #$08
	jsr GOTOXY
	jsr PrintTimeDifference
	ldx VOLNAMELEN	; X now has the length of the test file name's prefix (volume)
	inx
	ldy #$00
:	lda Filename_4M,Y
	sta TEST_FILE_NAME,X
	inx
	iny
	cpy #Filename_Len
	bne :-
	dex
	stx TEST_FILE_NAME
	jsr FileOpen
	bcc :+
	jmp TimeTestPromptDone
:	lda #0
	sta FileSizeInChunks
	lda #$01
	sta FileSizeInChunks+1
	jsr GetTime	; Start timer
	jsr MoveTime
	jsr FileRead
	php
	jsr GetTime	; End timer
	plp
	bcs ReadingPhaseDone
			; Only report on successful test
	lda #$00	; Prior timing was for 4M ($1000K)
	sta <dividend
	lda #$10
	sta <dividend+1
	ldx #$12
	ldy #$09
	jsr GOTOXY
	jsr PrintTimeDifference
	jmp ReadBlockPhaseBegin

ReadingPhaseDone:
	lda ESCAPE_REQ		; Check if we got here because of escape; if so, we're all done.
	beq ReadBlockPhaseBegin	; Zero means no escape.
	lda #$00
	sta ESCAPE_REQ
	jmp TimeTestPromptDone

ReadBlockPhaseBegin:
	lda NUMBLKS
	sta FileSizeInChunks
	lda NUMBLKS+1
	sta FileSizeInChunks+1
	lda UNITNBR
	sta READ_BLK_UNIT
	jsr GetTime	; Start timer
	jsr MoveTime
	jsr BlockRead
	php
	jsr GetTime	; End timer
	plp
	bcs TimeTestPromptDone
	lda NUMBLKS
	sta <dividend
	lda NUMBLKS+1
	sta <dividend+1
	; Need to divide the dividend by 2... since we currently hold blocks, which are 512 bytes and not 1K.
	lda <dividend+1	; Load the MSB
        asl a		; Copy the sign bit into C
        ror <dividend+1	; And back into the MSB
        ror <dividend	; Rotate the LSB as normal
	ldx #$1f
	ldy #$06
	jsr GOTOXY
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
	lda #$00
	sta Elapsed+1
			; Calculate seconds
	sec
	lda TimeNow+2
	sbc Time2+2
	bcs :+
	adc #60
	dec TimeNow+1 
:	sta Elapsed
			; Calculate minutes
	sec
	lda TimeNow+1
	sbc Time2+1
	bcs :+
	adc #60
	dec TimeNow
:	tax		; X now holds number of minutes
	beq @done
@more:	clc		; Multiply minutes by 60
	lda Elapsed
	adc #60		; Add 60 seconds for each minute
	sta Elapsed
	bcc @next
	inc Elapsed+1
@next:	dex
	bne @more
@done:
	lda Elapsed
	sta <divisor
	lda Elapsed+1
	sta <divisor+1
	jsr divide

	lda #CHR_SP
	jsr COUT1

	lda <BLKPTR	; dividend
	ldx <BLKPTR+1	; dividend+1
	ldy #CHR_SP
	jsr PRD
			; result = dividend
	rts


;
; 16-bit Divide from http://codebase64.org/doku.php?id=base:6502_6510_maths
;
dividend = BLKPTR ; numerator
divisor = UTILPTR ; denominator
remainder = CRC
result = dividend ;save memory by reusing divident to store the result

divide:	lda #0	        ;preset remainder to 0
	sta remainder
	sta remainder+1
	ldx #16	        ;repeat for each bit: ...

divloop:
	asl dividend	;dividend lb & hb*2, msb -> Carry
	rol dividend+1	
	rol remainder	;remainder lb & hb * 2 + msb from carry
	rol remainder+1
	lda remainder
	sec
	sbc divisor	;substract divisor to see if it fits in
	tay	        ;lb result -> Y, for we may need it later
	lda remainder+1
	sbc divisor+1
	bcc @skip	;if carry=0 then divisor didn't fit in yet

	sta remainder+1	;else save substraction result as new remainder,
	sty remainder	
	inc result	;and INCrement result cause divisor fit in 1 times

@skip:	dex
	bne divloop	
	rts

SetupTTScreen:
	jsr HOME
	ldx #$09
	ldy #$00
	jsr GOTOXY
	ldy #PMTimeTitle	; BENCHMARK TEST RESULTS
	jsr WRITEMSG
	lda #$02
	jsr TABV
	ldy #PMTimeHeader	; FILE WRITE    FILE READ    BLOCK READ
	jsr WRITEMSGLEFT
	lda #$04
	jsr TABV
	ldy #PMTimeHeader2	;  SIZE KB/S         KB/S          KB/S
	jsr WRITEMSGLEFT
	lda #$05
	jsr TABV
	ldy #PMTimeHeader3	; ----- ----         ----          ----
	jsr WRITEMSGLEFT
	jsr CROUT
	ldy #PMTimeHeader4	;  512K
	jsr WRITEMSG
	jsr CROUT
	ldy #PMTimeHeader5	; 1024K
	jsr WRITEMSG
	jsr CROUT
	ldy #PMTimeHeader6	; etc.
	jsr WRITEMSG
	jsr CROUT
	ldy #PMTimeHeader7
	jsr WRITEMSG
	jsr CROUT

	ldy #PMSG30		; Testing in progress; esc to stop.
	jsr WRITEMSGAREA	
	rts

TimeNow:
	.res 4,0	; Filled in by gettime.asm: Hours, Minutes, Seconds, Hundredths	
Time2:	.res 4,0
Elapsed:
	.res 2		; Total elapsed seconds
