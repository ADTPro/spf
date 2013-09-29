;
; SPF - Stress ProDOS Filesystem
; Copyright (C) 2011 - 2013 by David Schmidt
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

	.include "sos/interp.asm"	; Interpreter header
	.include "sos/sosmacros.i"	; OS macros
	.include "sos/sosconst.i"	; OS equates, characters, etc.
	.include "sos/sosvars.asm"
	.include "sos/sosmessages.asm"	; Messages

	.include "main.asm"

;---------------------------------------------------------
; Pull in all the rest of the code
;---------------------------------------------------------
	.include "sos/conio.asm"	; Console I/O
	.include "print.asm"
	.include "sos/online.asm"
	.include "pickvol.asm"
	.include "input.asm"
	.include "sos/format.asm"			; Note: includes FORMAT segment
	.include "sos/lowlevel.asm"
	.include "timetest.asm"
	.include "sos/gettime.asm"
	.include "sos/fileops.asm"

; Stubs from Disk II-related stuff that SOS does not need
ReceiveNib:
GO_TRACK0:
INIT_DISKII:
sendnib:
motoroff:
	rts

; Stubs:
ROM:
;BSAVE:
CH:
CV:
INVFLG:
DevAdr:
DevList:
DevCnt:
PEND:
TBL_ONLINE:
UNIT:
DEVLST:
DEVICE:
KEYBUFF:
ZDEVCNT:
DEVCNT:
	.segment "DATA"
