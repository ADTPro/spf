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
	jsr GetTime

; All done - print a final message
TimeTestPromptDone:
	lda #$15
	jsr TABV
	ldy #PMSG16
	jsr WRITEMSGLEFT
	bit $C010
	jsr RDKEY
	rts

TimeNow:
	.res 4		; Filled in by gettime.asm: Hours, Minutes, Seconds, Hundredths	
Time2:	.res 4
Elapsed:
	.res 4
