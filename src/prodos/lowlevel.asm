;
; SPF - Stress ProDOS Filesystem
; Copyright (C) 2011 by David Schmidt
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

LowLevelDone1:
	rts

LowLevel:
	lda #<EvenBlock
	ldy #>EvenBlock
	sta BLKPTR
	sty BLKPTR+1

	ldy #PMSG05	; Format title line
	jsr PICKVOL	; A now has index into DEVICES table; UNITNBR holds chosen unit
	bmi LowLevelDone1

	ldy #PMSG07
	jsr WRITEMSGLEFT
	jsr YNLOOP
	beq LowLevel
	ldy #PMFEX
	jsr WRITEMSGLEFT
	jsr YNLOOP
	beq LowLevel
	sta DevIndex	; Hang on to that DEVICES index
	ldy #PMNULL
	jsr WRITEMSG
	lda UNITNBR
	sta Slot
	tax
	lda NUMBLKS
	sta VolBlks
	lda NUMBLKS+1
	sta VolBlks+1
	lda #$00
	sta VolBlks+2

;**********************************
;*                                *
;* Write blocks to disk           *
;*                                *
;**********************************
LowWrite:
	lda #$00
	sta CompletedRuns
	sta CompletedRuns+1

	ldx #$0		; Column
	ldy #V_MSG-2	; Row
	jsr GOTOXY
	ldy #PMSG30
	jsr WRITEMSGLEFT

	; Print VolBlks on the screen
LowWriteStart:
	; Swap the buffer we're comparing to
	lda CompletedRuns
	and #$01
	bne @WritePointAtOdd
	lda #<EvenBlock		; Set MLIbuf to EvenBlock
	ldy #>EvenBlock
	sta MLIbuf
	sty MLIbuf+1
	jmp @LowWritePrint
@WritePointAtOdd:
	lda #<OddBlock
	ldy #>OddBlock
	sta MLIbuf
	sty MLIbuf+1

@LowWritePrint:
	ldx #$0		; Column
	ldy #V_MSG	; Row
	jsr GOTOXY
	ldy #PMSG09
	jsr WRITEMSG
	lda #CHR_SP
	jsr COUT	; Space over one character

	lda VolBlks
	ldx VolBlks+1
	ldy #CHR_0
	jsr PRD

	lda #OS_WRITEBLOCK	; Set Opcode to WRITE
	sta LowMLI+OS_CALL_OFFSET
	lda #$00		; Set MLIBlk to 0
	sta MLIBlk
	sta MLIBlk+1
	ldx #$00
LowWriteNext:
	CALLOS OS_WRITEBLOCK, Parms	; Write block to target disk
	bcc :+
	jsr LowError

:	inx
	stx MLIBlk
	bne @Skip100Boundary
	inc MLIBlk+1

; Check for escape keystroke at $100 boundaries
	lda $C000
	cmp #CHR_ESC	; ESCAPE = ABORT
	beq LowLevelPromptDone

	; Print MLIblk on the screen
	lda #V_MSG	; start printing at first number spot
	jsr TABV
	lda #H_BLK-1
	jsr HTAB
	lda MLIBlk
	ldx MLIBlk+1
	ldy #CHR_0
	jsr PRD			; Print block number in decimal
@Skip100Boundary:
	ldx MLIBlk
	cpx VolBlks
	bne LowWriteNext
	lda MLIBlk+1
	cmp VolBlks+1
	bne LowWriteNext

; Check for escape keystroke at run completions
	lda $C000
	cmp #CHR_ESC	; ESCAPE = ABORT
	bne LowReadStart

; All done - print a final message
LowLevelPromptDone:
	lda #$15
	jsr TABV
	ldy #PMSG16
	jsr WRITEMSGLEFT
	bit $C010
	jsr RDKEY
	rts

;**********************************
;*                                *
;* Read blocks from disk          *
;*                                *
;**********************************
LowReadStart:
	ldx #$0		; Column
	ldy #V_MSG	; Row
	jsr GOTOXY
	ldy #PMSG09
	jsr WRITEMSG
	lda #$00
	jsr HTAB
	ldy #PMSG08
	jsr WRITEMSG
	lda #$17
	jsr HTAB
	lda VolBlks
	ldx VolBlks+1
	ldy #CHR_0
	jsr PRD

LowReadMLI:
	lda #OS_READBLOCK	; Set Opcode to READ
	sta LowMLI+OS_CALL_OFFSET
	lda #$00		; Set MLIBlk to 0
	sta MLIBlk
	sta MLIBlk+1

	LDA_BIGBUF_ADDR_LO	; Point to the start of the big buffer
	sta MLIbuf
	LDA_BIGBUF_ADDR_HI
	sta MLIbuf+1

LowReadNext:
	lda #$01
	sta RWMode
LowMLI:	CALLOS OS_READBLOCK, Parms	; Read block from target disk
	bcc @NoError
	jsr LowError

	; Check for correct data	
@NoError:
	inc RWMode
	LDA_BIGBUF_ADDR_LO
	sta Buffer
	LDA_BIGBUF_ADDR_HI
	sta Buffer+1

	; Set up BLKPTR to point to desired block
	lda CompletedRuns
	and #$01
	bne @PointAtOdd
	lda #<EvenBlock
	ldy #>EvenBlock
	sta BLKPTR
	sty BLKPTR+1
	jmp @B4CheckBuffer
@PointAtOdd:
	lda #<OddBlock
	ldy #>OddBlock
	sta BLKPTR
	sty BLKPTR+1

@B4CheckBuffer:
	ldy #$00

@CheckBuffer:
	lda (Buffer),y
	cmp (BLKPTR),y
	beq @CorrectRead
	sty SLOWY
	jsr LowError
	ldy SLOWY
@CorrectRead:
	iny
	bne @CheckBuffer
	inc BLKPTR+1
	inc Buffer+1
	lda Buffer+1
	cmp #$68
	bne @CheckBuffer
	inc MLIBlk
	bne SkipLowReadPrinting
	inc MLIBlk+1

; Check for escape keystroke at $100 boundaries
	lda $C000
	cmp #CHR_ESC	; ESCAPE = ABORT
	beq LowReadPromptDone

	; Print MLIblk on the screen
	lda #V_MSG	; start printing at first number spot
	jsr TABV
	lda #H_BLK-1
	jsr HTAB
	lda MLIBlk
	ldx MLIBlk+1
	ldy #CHR_0
	jsr PRD			; Print block number in decimal
SkipLowReadPrinting:
	ldx MLIBlk
	cpx VolBlks
	bne LowReadNext
	lda MLIBlk+1
	cmp VolBlks+1
	beq @Completed
	jmp LowReadNext

@Completed:
	inc CompletedRuns
	bne :+
	inc CompletedRuns+1

; Check for escape keystroke at run completions
:	lda $C000
	cmp #CHR_ESC	; ESCAPE = ABORT
	beq LowReadPromptDone

	; Talk about how many runs have been made
	lda #V_MSG+2	; Tell 'em how many runs worked
	jsr TABV
	lda #0
	jsr HTAB
	lda CompletedRuns
	ldx CompletedRuns+1
	ldy #CHR_0
	jsr PRD			; Print block number in decimal
	ldy #PMSG28
	jsr WRITEMSG

	jmp LowWriteStart

; All done - print a final message
LowReadPromptDone:
	jmp LowLevelPromptDone 

LowError:
	sta LastLowError
	stx SLOWX
	lda #V_MSG+1
	jsr TABV
	lda #$00
	jsr HTAB
	ldy #PMSG28a		; Writing
	jsr WRITEMSG
	lda #$00
	jsr HTAB
	lda RWMode
	beq @PrintBlock
	cmp #$02
	beq @Verifying
	ldy #PMSG28		; Reading
	jsr WRITEMSG
	jmp @PrintBlock
@Verifying:
	ldy #PMSG06		; Verifying
	jsr WRITEMSG
@PrintBlock:
	lda #$0e
	jsr HTAB
	lda MLIBlk
	ldx MLIBlk+1
	ldy #CHR_0
	jsr PRD			; Print block number in decimal
	lda #$24
	jsr HTAB
	lda LastLowError
	jsr PRBYTE
	ldx SLOWX
	rts

CompletedRuns:
	.byte $00, $00

LastLowError:
	.byte $00

RWMode:	.byte $00	; Writing = 0; Reading = 1; Verifying = 2

EvenBlock:
.align  256
; A block of 10101010/$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
	.byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa

OddBlock:
; A block of 01010101/$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55