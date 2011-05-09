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

entrypoint:

;---------------------------------------------------------
; Start us up
;---------------------------------------------------------
	sei
	cld

	tsx		; Get a handle to the stackptr
	stx top_stack	; Save it for full pops during aborts

	jsr INIT_SCREEN	; Sets up the screen for behaviors we expect
	jsr HOME	; Clear screen
	jmp MAINL	; And off we go!

;---------------------------------------------------------
; Main loop
;---------------------------------------------------------
MAINLUP:
	jsr HOME	; Clear screen

MAINL:
RESETIO:
	jsr MainScreen

;---------------------------------------------------------
; KBDLUP
;
; Keyboard handler, dispatcher
;---------------------------------------------------------
KBDLUP:
	jsr RDKEY	; GET ANSWER
	CONDITION_KEYPRESS	; Convert to upper case, etc.  OS dependent.

KLOWLEVEL:
	cmp #CHR_L	; Low Level?
	bne :+		; Nope
	jsr LowLevel
	jmp MAINLUP
:
KABOUT:	cmp #$9F	; ABOUT MESSAGE? ("?" KEY)
	bne :+		; Nope
	lda #$03
        ldx #$18
	ldy #$10
	jsr INVERSE
	lda #$15
	jsr TABV
	ldy #PMSG17	; "About" message
	jsr WRITEMSGLEFT
	jsr RDKEY
	jmp MAINLUP	; Clear and start over
:
KVOLUMS:
	cmp #CHR_V	; Volumes online?
	bne :+		; Nope
	ldy #PMNULL	; No title line
	jsr PICKVOL	; Pick a volume - A has index into DEVICES table
	jmp MAINLUP
:
KFORMAT:
	cmp #CHR_F	; Format?
	bne :+		; Nope
	jsr FormatEntry	; Run formatter
	jmp MAINLUP
:
KQUIT:
	cmp #CHR_Q	; Quit?
	bne FORWARD	; No, it was an unknown key
	cli
	jmp QUIT	; Head into ProDOS oblivion

FORWARD:
	jmp MAINL


;---------------------------------------------------------
; MainScreen - Show the main screen
;---------------------------------------------------------
MainScreen:
	jsr SHOWLOGO
	ldx #$07
	ldy #$0e
	jsr GOTOXY
	ldy #PMSG02	; Prompt line 1
	jsr WRITEMSG
	ldy #PMSG03	; Prompt line 2
	jsr WRITEMSG
	rts

;---------------------------------------------------------
; ABORT - STOP EVERYTHING (CALL BABORT TO BEEP ALSO)
;---------------------------------------------------------
BABORT:	jsr AWBEEP	; Beep!
ABORT:	ldx top_stack	; Pop goes the stackptr
	txs
	jsr motoroff	; Turn potentially active drive off
	bit $C010	; Strobe the keyboard
	jmp MAINLUP	; ... and restart

;---------------------------------------------------------
; AWBEEP - CUTE TWO-TONE BEEP (USES AXY)
;---------------------------------------------------------
AWBEEP:
	GO_SLOW		; Slow SOS down for this
	ldx #$0d	; Tone isn't quite the same as
	jsr BEEP1	; Apple Writer ][, but at least
	ldx #$0f	; it's the same on all CPU speeds.
BEEP1:	ldy #$85
BEEP2:	txa
BEEP3:	jsr DELAY
	bit $C030	; WHAP SPEAKER
	dey
	bne BEEP2
	GO_FAST		; Speed SOS back up
NOBEEP:	rts
