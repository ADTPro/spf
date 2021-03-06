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

;---------------------------------------------------------
; READING/WRITING
;
; Read or write from zero to 40 ($28) blocks
;
; Input:
;   DIFF: Count of blocks
;   UNITNBR: unit number
;   BLKLO: starting block (lo)
;   BLKHI: starting block (hi)
;
; Output:
;   BLKLO: starting block (lo)
;   BLKHI: starting block (hi)
;---------------------------------------------------------
READING:
	lda #PMSG07
	sta SR_WR_C
	lda #OS_READBLOCK
	sta RWDIR+1
	lda #$05
	sta D_RW_PARMS
	lda #CHR_R
	sta RWCHR
	lda #CHR_BLK
	sta RWCHROK
	jmp RW_COMN

WRITING:
	lda #PMSG08
	sta SR_WR_C
	lda #OS_WRITEBLOCK
	sta RWDIR+1
	lda #$04
	sta D_RW_PARMS
	lda #CHR_W
	sta RWCHR
	lda #CHR_SP
	sta RWCHROK

RW_COMN:
	lda UNITNBR
	sta D_RW_DEV_NUM
	lda #H_BUF	; Column - r/w/s/r
	jsr HTAB
	lda #V_MSG	; Message row
	jsr TABV
	ldy SR_WR_C
	jsr WRITEMSG

	lda #$00	; Reposition cursor to beginning of
	jsr HTAB	; buffer row
	lda #V_BUF
	jsr TABV

	jsr RWBLOX

	rts

;------------------------------------
; RWBLOX
;
; Read or write from zero to 40 ($28) blocks
; starting from BIGBUF
;
; Input:
;   UNITNBR: unit number
;   DIFF: block count
;   BLKLO: starting block (lo)
;   BLKHI: starting block (hi)
;
; Output:
;   BLKLO: ending block (lo)
;   BLKHI: ending block (hi)
;------------------------------------
RABORT:	jmp BABORT

RWBLOX:
	stx SLOWX
	sty SLOWY

	lda DIFF
	sta BCOUNT	; Get a local copy of block count to mess with

	lda #$00
	sta D_RW_BUFFER_PTR+1
	sta D_RW_BYTE_COUNT
	sta BIGBUF_ADDR_LO	; Point to the start of the big buffer
	LDA_BIGBUF_ADDR_HI	; Get the memory segment pointer
	sta BIGBUF_ADDR_HI

	lda #BLKPTR	; Point to the start of the big buffer
	sta D_RW_BUFFER_PTR

	lda BCOUNT		; Get the block count
	cmp #$09
	bmi :+			; if BCOUNT is <= 8, use it
	lda #$08		; If BCOUNT is > 8, then use 8
:	sta ITCOUNT		; How many blocks to count this iteration
	asl			; Multiply by 2 - gives us the MSB of bytes to request (512 * ITCOUNT)
	sta D_RW_BYTE_COUNT+1

RWCALL:
	lda BLKLO
	sta D_RW_BLOCK		; The starting block number
	lda BLKHI
	sta D_RW_BLOCK+1

	lda $C000
	cmp #CHR_ESC	; ESCAPE = ABORT

	beq RABORT
	LDA_CH
	sta COL_SAV
	lda RWCHR
	jsr COUT

	ldy #V_MSG	; start printing at first number spot
	ldx #H_NUM1
	jsr GOTOXY

	clc
	lda BLKLO	; Increment the 16-bit block number
	adc #$01
	sta NUM
	lda BLKHI
	adc #$00
	tax
	lda NUM
	ldy #CHR_0
	jsr PRD		; Print block number in decimal

RWDIR:	CALLOS OS_READBLOCK, D_RW_PARMS
	bne RWBAD
	lda RWCHROK
	sta RWRESULT	; Remember the character we're going to use for this I/O result
	jmp RWOK
RWBAD:
	cmp #DISKSK	; If we get a "disk switched" error, retry
	beq RWDIR
	lda #$01
	sta ECOUNT
	lda #CHR_X
	sta RWRESULT	; Remember the character we're going to use for this I/O result
RWOK:
	clc
	lda BLKLO
	adc ITCOUNT	; Increment the total blocks by this iteration's count
	sta BLKLO
	bcc :+
	inc BLKHI	; Send the block count back out via updated BLKLO/HI
:
	lda COL_SAV	; Reposition cursor to previous
	jsr HTAB	; buffer row
	lda #V_BUF	; Start printing the result of this I/O action
	jsr TABV

	ldx #$08
@loop:
	lda RWRESULT
	cmp #CHR_BLK
	bne :+
	jsr SET_INVERSE
	lda RWRESULT
:	jsr COUT
	dex
	cpx #$00
	bne @loop
	jsr SET_NORMAL

	sec
	lda BCOUNT
	sbc ITCOUNT	; Subtract ITCOUNT from BCOUNT
	sta BCOUNT
	beq :+		; We're done
	clc		; fixup the data pointer
	lda BIGBUF_ADDR_HI
	adc #$10	; Bump up 8 blocks worth of memory
	sta BIGBUF_ADDR_HI
	jmp RWCALL	; Go back for another iteration
	
:
	ldy #V_MSG	; start printing at first number spot
	ldx #H_NUM1
	jsr GOTOXY
	lda BLKLO
	ldx BLKHI
	ldy #CHR_0
	jsr PRD		; Print the final block tally decimal

	ldy SLOWY
	ldx SLOWX

	rts

DUMP_CALL:
	jsr CROUT
	lda #<D_RW_PARMS
	sta UTILPTR
	lda #>D_RW_PARMS
	sta UTILPTR+1
	lda #<D_RW_END
	sta UTILPTR2
	lda #>D_RW_END
	sta UTILPTR2+1
	; Dump memory to console starting from UTILPTR to UTILPTR2
	jsr DUMPMEM
	jsr CROUT

	lda #$26
	sta UTILPTR
	lda #$00
	sta UTILPTR+1
	lda #$28
	sta UTILPTR2
	lda #$00
	sta UTILPTR2+1

	; Dump memory to console starting from UTILPTR to UTILPTR2
	jsr DUMPMEM

	jsr CROUT

	lda #$26
	sta UTILPTR
	lda #$16
	sta UTILPTR+1
	lda #$28
	sta UTILPTR2
	lda #$16
	sta UTILPTR2+1

	; Dump memory to console starting from UTILPTR to UTILPTR2
	
	jsr DUMPMEM

	jsr CROUT

	lda #$fd
	sta UTILPTR
	lda #$01
	sta UTILPTR+1
	lda #$fe
	sta UTILPTR2
	lda #$01
	sta UTILPTR2+1

	; Dump memory to console starting from UTILPTR to UTILPTR2
	
	jsr DUMPMEM

	rts

RWCHR:	.byte CHR_R	; Character to notify what we're doing
RWCHROK:	.byte CHR_BLK	; Character to write when things are OK
RWRESULT:	.byte CHR_BLK	; Result of reading/writing
BCOUNT:	.byte $00
ITCOUNT:	.byte $00