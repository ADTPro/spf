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

FileOpenFail:			; Nearby branch point
	sec
	rts

FileOpenNew:
				; Get rid of the prior version of the file, if it was there
	CALLOS OS_DESTROY, FILE_RM
				; Create the new version of the file
	CALLOS OS_CREATE, FILE_CR
	CALLOS_CHECK_POS	; Branch forward on success
	jmp FileOpenFail
				; Open the newly created file
:
FileOpen:
	CALLOS OS_OPEN, FILE_OP
	CALLOS_CHECK_POS	; Branch forward on success
	jmp FileOpenFail
:	lda FILE_OPN		; copy file number for reading and closing
	sta FILE_RDN
	sta FILE_WRN
	sta FILE_CLN

FileOpenSuccess:
	clc
	rts

;
; FileWrite: write out successive 16k buffers until end of file
; Entry conditions: 
;   - FileSizeInChunks set to number of 16k chunks to write
;   - FILE_WR set with file number
;   - File already open
; Returns: carry set on failure 
;
FileWrite:
	lda FileSizeInChunks
	ora FileSizeInChunks+1	; Check for zero at top of loop
	bne FileWrite1
	jmp FileWriteQuit
FileWrite1:
	CALLOS OS_WRITEFILE, FILE_WR	; Write 16k
	CALLOS_CHECK_POS	; Branch forward on success
	jmp FileWriteFail
:	lda $C000		; Let the user interrupt
	cmp #CHR_ESC		; Escape = abort
	beq FileWriteFail1
	dex			; Manage the spinner
	bpl @SkipSpin
	ldx #$03
@SkipSpin:
	lda Spinner,X
	sta $400
	dec FileSizeInChunks	; Decrement the 16-bit counter
	lda FileSizeInChunks
	cmp #$ff
	bne FileWrite
	dec FileSizeInChunks+1
	jmp FileWrite

FileWriteQuit:
	lda #$a0
	sta $400	; Clear out spinner
	CALLOS OS_CLOSE, FILE_CL
	clc
	rts

FileWriteFail1:		; Escape hit
	lda #$01
	sta ESCAPE_REQ
FileWriteFail:		; If we fail to write a full file, close and delete it
	lda #$a0
	sta $400	; Clear out spinner
	CALLOS OS_CLOSE, FILE_CL
	CALLOS OS_DESTROY, FILE_RM
	sec
	rts

;
; FileRead: read in successive 16k buffers until end of file
; Entry conditions: 
;   - FileSizeInChunks set to number of 16k chunks to write
;   - FILE_RD set with file number
;   - File already open
; Returns: carry set on failure 
;
FileReadPrep:
	ldx #$03
	lda Spinner,X
	sta $400
FileRead:
	lda FileSizeInChunks
	ora FileSizeInChunks+1	; Check for zero at top of loop
	bne FileRead1
	jmp FileReadQuit
FileRead1:
	CALLOS OS_READFILE, FILE_RD	; Read 16k
	CALLOS_CHECK_POS	; Branch forward on success
	jmp FileReadFail
:	lda $C000		; Let the user interrupt
	cmp #CHR_ESC		; Escape = abort
	beq FileReadFail1
	dex			; Manage the spinner
	bpl @RSkipSpin
	ldx #$03
@RSkipSpin:
	lda Spinner,X
	sta $400
	dec FileSizeInChunks	; Decrement the 16-bit counter
	lda FileSizeInChunks
	cmp #$ff
	bne FileRead
	dec FileSizeInChunks+1
	jmp FileRead

FileReadQuit:
	lda #$a0
	sta $400	; Clear out spinner
	CALLOS OS_CLOSE, FILE_CL
	clc
	rts

FileReadFail1:		; Escape hit
	lda #$01
	sta ESCAPE_REQ
FileReadFail:
	lda #$a0
	sta $400	; Clear out spinner
	CALLOS OS_CLOSE, FILE_CL
	sec
	rts

FileSizeInChunks:
	.addr 0			; Number of 16k chunks to read/write  

Filename_Len	= $09			; All filenames are assumed to be the same length
Filename_512K:	.asciiz "/FILE512K"	; 32 hunks of 16k
Filename_1M:	.asciiz "/FILE001M"	; 64 hunks of 16k
Filename_2M:	.asciiz "/FILE002M"	; 128 hunks of 16k
Filename_4M:	.asciiz "/FILE004M"	; 256 hunks of 16k
Spinner:	ascz "/|\-"