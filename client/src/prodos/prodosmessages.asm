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

.include "messages.asm"

	MSG10: .byte	$20,$20,$20,$A0,$A0,$20,$20,$20,$A0,$A0,$20,$A0,$A0,$A0,$20,$8D
	MSG10_END =*
	MSG11: .byte	$20,$A0,$A0,$20,$A0,$20,$A0,$A0,$20,$A0,$A0,$20,$A0,$20,$8D
	MSG11_END =*
	MSG12: .byte	$20,$A0,$A0,$20,$A0,$20,$A0,$A0,$20,$A0,$A0,$A0,$20,$8D
	MSG12_END =*
	MSG20:	asc "SLOT  DRIVE  VOLUME NAME      BLOCKS"
	MSG20_END =*
	MSG21:	asc "----  -----  ---------------  ------"
	MSG21_END =*
	MSG26: asc	"COMMS DEVICE"
	MSG26_END =*
	MSG27: asc	"BAUD RATE"
	MSG27_END =*
	