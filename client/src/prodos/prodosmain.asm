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

	.include "prodos/interp.asm"			; Interpreter header
	.include "prodos/prodosmacros.i"		; OS macros
	.include "prodos/prodosconst.i"			; OS equates, characters, etc.
	.include "diskii.asm"				; Contains positionally dependent format code

;---------------------------------------------------------
; Pull in all the rest of the code
;---------------------------------------------------------
	.include "main.asm"
	.include "prodos/prodosvars.asm"		; Variables
	.include "prodos/prodosmessages.asm"	; Messages
	.include "prodos/conio.asm"		; Console I/O
	.include "print.asm"
	.include "prodos/online.asm"
	.include "pickvol.asm"
	.include "input.asm"
	.include "prodos/format.asm"		; Note: includes FORMAT segment
	.include "prodos/lowlevel.asm"
	.include "timetest.asm"
	.include "prodos/gettime.asm"
	.include "fileops.asm"

	.segment "DATA"
	