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

;---------------------------------------------------------
; Console messages
;---------------------------------------------------------
	MSG01:	asc "%SPF_VERSION%"
	MSG01_END =*

	MSG02:	asc "(L)OW-LEVEL VOLUME CERTIFY (T)IME TEST"
		.byte CHR_RETURN,CHR_RETURN
	MSG02_END =*

	MSG03:	asc "     (V)OLUMES (F)ORMAT (?) (Q)UIT:"
	MSG03_END =*

	MSG04:	asc "(S)TANDARD OR (N)IBBLE?"
	MSG04_END =*

	MSG05:	asc " CHOOSE VOLUME FOR LL VERIFY"
	MSG05_END =*

	MSG06:	asc "VRFYING"
	MSG06_END =*

	MSG07:	asc "READY TO DESTROY UNIT? (Y/N):"
	MSG07_END =*

	MSG08:	asc "READING"
	MSG08_END =*

	MSG09:	asc "WRITING BLOCK 00000 OF"
	MSG09_END =*

	;MSG10 - defined locally
	;MSG11 - defined locally
	;MSG12 - defined locally

	MSG13:	asc "FILENAME: "
	MSG13_END =*

	MSG14:	asc "COMPLETE"
	MSG14_END =*

	MSG15:	asc " - WITH ERRORS"
	MSG15_END =*

	MSG16:	asc "PRESS A KEY TO CONTINUE..."
	MSG16_END =*

	MSG17:	asc "        STRESS PRODOS FILESYSTEM        "
		asc "            BY DAVID SCHMIDT"
	MSG17_END =*

	MSGSOU:	asc "   SELECT SOURCE VOLUME"
	MSGSOU_END =*

	MSGDST:	asc "SELECT DESTINATION VOLUME"
	MSGDST_END =*

	MSG19:	asc "VOLUMES CURRENTLY ON-LINE:"
	MSG19_END =*

	;MSG20 - defined locally
	;MSG21 - defined locally

	MSG22:	asc "CHANGE SELECTION WITH ARROW KEYS&RETURN "
	MSG22_END =*

	MSG23:	asc " (R) TO RE-SCAN DRIVES, ESC TO CANCEL"
	MSG23_END =*

	MSG23a:	asc "SELECT WITH RETURN, ESC CANCELS"
	MSG23a_END =*

	;MSG26 - defined locally
	;MSG27 - defined locally

	MSG28: asc " FULL DISK PASSES COMPLETE"
	MSG28_END =*

	MSG28a:	asc "WRITING BLOCK       HAD ERROR CODE:   "
	MSG28a_END =*

	MSG29:	asc "ANY KEY TO CONTINUE, ESC TO STOP: "
	MSG29_END =*

	MSG30:	asc "TESTING IN PROGRESS. ESC TO STOP."
	MSG30_END =*

	MNONAME:
		asc "<NO NAME>"
	MNONAME_END =*

	MIOERR:	asc "<I/O ERROR>"
	MIOERR_END =*

	MSG34:	asc "FILE EXISTS"
	MSG34_END =*

	MHFS:
		asc "<HFS>"
	MHFS_END =*

	MSG05a:	asc " CHOOSE VOLUME FOR TIME TEST"
	MSG05a_END =*

	MSGNoClock:
		asc "NO CLOCK FOUND."
	MSGNoClock_END =*

	MLOGO1:	.byte NRM_BLOCK,INV_BLOCK,INV_BLOCK,INV_BLOCK,NRM_BLOCK,INV_BLOCK,INV_BLOCK,INV_BLOCK,NRM_BLOCK,NRM_BLOCK,INV_BLOCK,INV_BLOCK,INV_BLOCK,INV_BLOCK,CHR_RETURN
	MLOGO1_END =*

	MLOGO2:	.byte INV_BLOCK,NRM_BLOCK,NRM_BLOCK,NRM_BLOCK,NRM_BLOCK,INV_BLOCK,NRM_BLOCK,NRM_BLOCK,INV_BLOCK,NRM_BLOCK,INV_BLOCK,CHR_RETURN
	MLOGO2_END =*

	MLOGO3:	.byte INV_BLOCK,INV_BLOCK,INV_BLOCK,INV_BLOCK,NRM_BLOCK,INV_BLOCK,INV_BLOCK,INV_BLOCK,NRM_BLOCK,NRM_BLOCK,INV_BLOCK,INV_BLOCK,INV_BLOCK,INV_BLOCK,CHR_RETURN
	MLOGO3_END =*

	MLOGO4:	.byte NRM_BLOCK,NRM_BLOCK,NRM_BLOCK,INV_BLOCK,NRM_BLOCK,INV_BLOCK,NRM_BLOCK,NRM_BLOCK,NRM_BLOCK,NRM_BLOCK,INV_BLOCK,CHR_RETURN
	MLOGO4_END =*

	MLOGO5:	.byte INV_BLOCK,INV_BLOCK,INV_BLOCK,NRM_BLOCK,NRM_BLOCK,INV_BLOCK,NRM_BLOCK,NRM_BLOCK,NRM_BLOCK,NRM_BLOCK,INV_BLOCK,CHR_RETURN
		asc	""
		.byte	CHR_RETURN
	MLOGO5_END =*

	MCDIR:	asc "DIRECTORY: "
	MCDIR_END =*

	MFEX:	asc "SERIOUSLY!  YOUR DATA WILL DIE! (Y/N):"
	MFEX_END =*

	MFORMAT:
		asc " CHOOSE VOLUME TO FORMAT"
	MFORMAT_END =*

	MANALYSIS:
		asc "HOST UNABLE TO ANALYZE TRACK."
	MANALYSIS_END =*

	MNOCREATE:
		asc "UNABLE TO CREATE CONFIG FILE."
	MNOCREATE_END =*

	; Messages from formatter routine
	MVolName:
		asc "VOLUME NAME: /"
	MBlank:	asc "BLANK          "	; Note - these two are really one continuous message.
	MVolName_END =*

	MTheOld:
		asc "READY TO FORMAT? (Y/N):"
	MTheOld_END =*

	MUnRecog:
		asc "UNRECOGNIZED ERROR = "
	MUnRecog_END =*

	MDead:	asc "CHECK DISK OR DRIVE DOOR!"
	MDead_END =*

	MProtect:
		asc "DISK IS WRITE PROTECTED!"
	MProtect_END =*

	MNoDisk:
		asc "NO DISK IN THE DRIVE!"
	MNoDisk_END =*
	
	MNuther:
		asc "FORMAT ANOTHER? (Y/N):"
	MNuther_END =*
	
	MUnitNone:
		asc "NO UNIT IN THAT SLOT AND DRIVE"
	MUnitNone_END =*

	MTimeTitle:
		asc "BENCHMARK TEST RESULTS"
	MTimeTitle_END =*

	MTimeHeader:
		asc "  FILE WRITE   FILE READ   BLOCK READ"
	MTimeHeader_END =*

	MTimeHeader2:
		asc " SIZE   KB/S        KB/S         KB/S"
	MTimeHeader2_END =*

	MTimeHeader3:
		asc "-----  -----       -----        -----"
	MTimeHeader3_END =*

	MTimeHeader4:
		asc " 512K"
	MTimeHeader4_END =*

	MTimeHeader5:
		asc "1024K"
	MTimeHeader5_END =*

	MTimeHeader6:
		asc "2048K"
	MTimeHeader6_END =*

	MTimeHeader7:
		asc "4096K"
	MTimeHeader7_END =*

	MNULL:	.byte $00
	MNULL_END =*
	



;---------------------------------------------------------
; Message pointer table
;---------------------------------------------------------

MSGTBL:
	.addr MSG01,MSG02,MSG03,MSG04,MSG05,MSG06,MSG07,MSG08
	.addr MSG09,MSG10,MSG11,MSG12,MSG13,MSG14,MSG15,MSG16
	.addr MSG17,MSGSOU,MSGDST,MSG19,MSG20,MSG21,MSG22,MSG23,MSG23a
	.addr MSG26,MSG27,MSG28,MSG28a,MSG29,MSG30,MNONAME,MIOERR
	.addr MSG34
	.addr MLOGO1,MLOGO2,MLOGO3,MLOGO4,MLOGO5,MCDIR,MFEX
	.addr MFORMAT, MANALYSIS, MNOCREATE
	.addr MVolName, MTheOld, MUnRecog, MDead
	.addr MProtect, MNoDisk, MNuther, MUnitNone
	.addr MHFS, MSG05a, MSGNoClock, MTimeTitle, MTimeHeader
	.addr MTimeHeader2, MTimeHeader3, MTimeHeader4, MTimeHeader5
	.addr MTimeHeader6, MTimeHeader7
	.addr MNULL

;---------------------------------------------------------
; Message length table
;---------------------------------------------------------

MSGLENTBL:
	.byte MSG01_END-MSG01
	.byte MSG02_END-MSG02
	.byte MSG03_END-MSG03
	.byte MSG04_END-MSG04
	.byte MSG05_END-MSG05
	.byte MSG06_END-MSG06
	.byte MSG07_END-MSG07
	.byte MSG08_END-MSG08
	.byte MSG09_END-MSG09
	.byte MSG10_END-MSG10
	.byte MSG11_END-MSG11
	.byte MSG12_END-MSG12
	.byte MSG13_END-MSG13
	.byte MSG14_END-MSG14
	.byte MSG15_END-MSG15
	.byte MSG16_END-MSG16
	.byte MSG17_END-MSG17
	.byte MSGSOU_END-MSGSOU
	.byte MSGDST_END-MSGDST
	.byte MSG19_END-MSG19
	.byte MSG20_END-MSG20
	.byte MSG21_END-MSG21
	.byte MSG22_END-MSG22
	.byte MSG23_END-MSG23
	.byte MSG23a_END-MSG23a
	.byte MSG26_END-MSG26
	.byte MSG27_END-MSG27
	.byte MSG28_END-MSG28
	.byte MSG28a_END-MSG28a
	.byte MSG29_END-MSG29
	.byte MSG30_END-MSG30
	.byte MNONAME_END-MNONAME
	.byte MIOERR_END-MIOERR
	.byte MSG34_END-MSG34
	.byte MLOGO1_END-MLOGO1
	.byte MLOGO2_END-MLOGO2
	.byte MLOGO3_END-MLOGO3
	.byte MLOGO4_END-MLOGO4
	.byte MLOGO5_END-MLOGO5
	.byte MCDIR_END-MCDIR
	.byte MFEX_END-MFEX
	.byte MFORMAT_END-MFORMAT
	.byte MANALYSIS_END-MANALYSIS
	.byte MNOCREATE_END-MNOCREATE
	.byte MVolName_END-MVolName
	.byte MTheOld_END-MTheOld
	.byte MUnRecog_END-MUnRecog
	.byte MDead_END-MDead
	.byte MProtect_END-MProtect
	.byte MNoDisk_END-MNoDisk
	.byte MNuther_END-MNuther
	.byte MUnitNone_END-MUnitNone
	.byte MHFS_END-MHFS
	.byte MSG05a_END-MSG05a
	.byte MSGNoClock_END-MSGNoClock
	.byte MTimeTitle_END-MTimeTitle
	.byte MTimeHeader_END-MTimeHeader
	.byte MTimeHeader2_END-MTimeHeader2
	.byte MTimeHeader3_END-MTimeHeader3
	.byte MTimeHeader4_END-MTimeHeader4
	.byte MTimeHeader5_END-MTimeHeader5
	.byte MTimeHeader6_END-MTimeHeader6
	.byte MTimeHeader7_END-MTimeHeader7
	.byte $00	; MNULL - null message has no length.

;---------------------------------------------------------
; Message equates
;---------------------------------------------------------

PMSG01		= $00
PMSG02		= PMSG01+2
PMSG03		= PMSG02+2
PMSG04		= PMSG03+2
PMSG05		= PMSG04+2
PMSG06		= PMSG05+2
PMSG07		= PMSG06+2
PMSG08		= PMSG07+2
PMSG09		= PMSG08+2
PMSG10		= PMSG09+2
PMSG11		= PMSG10+2
PMSG12		= PMSG11+2
PMSG13		= PMSG12+2
PMSG14		= PMSG13+2
PMSG15		= PMSG14+2
PMSG16		= PMSG15+2
PMSG17		= PMSG16+2
PMSGSOU		= PMSG17+2
PMSGDST		= PMSGSOU+2
PMSG19		= PMSGDST+2
PMSG20		= PMSG19+2
PMSG21		= PMSG20+2
PMSG22		= PMSG21+2
PMSG23		= PMSG22+2
PMSG23a		= PMSG23+2
PMSG26		= PMSG23a+2
PMSG27		= PMSG26+2
PMSG28		= PMSG27+2
PMSG28a		= PMSG28+2
PMSG29		= PMSG28a+2
PMSG30		= PMSG29+2
PMNONAME	= PMSG30+2
PMIOERR		= PMNONAME+2
PMSG34		= PMIOERR+2
PMLOGO1		= PMSG34+2
PMLOGO2		= PMLOGO1+2
PMLOGO3		= PMLOGO2+2
PMLOGO4		= PMLOGO3+2
PMLOGO5		= PMLOGO4+2
PMCDIR		= PMLOGO5+2
PMFEX		= PMCDIR+2
PMFORMAT	= PMFEX+2
PMANALYSIS	= PMFORMAT+2
PMNOCREATE	= PMANALYSIS+2
PMVolName	= PMNOCREATE+2
PMTheOld	= PMVolName+2
PMUnRecog	= PMTheOld+2
PMDead		= PMUnRecog+2
PMProtect	= PMDead+2
PMNoDisk	= PMProtect+2
PMNuther	= PMNoDisk+2
PMUnitNone	= PMNuther+2
PMHFS		= PMUnitNone+2
PMSG05a		= PMHFS+2
PMSGNoClock	= PMSG05a+2
PMTimeTitle	= PMSGNoClock+2
PMTimeHeader	= PMTimeTitle+2
PMTimeHeader2	= PMTimeHeader+2
PMTimeHeader3	= PMTimeHeader2+2
PMTimeHeader4	= PMTimeHeader3+2
PMTimeHeader5	= PMTimeHeader4+2
PMTimeHeader6	= PMTimeHeader5+2
PMTimeHeader7	= PMTimeHeader6+2
PMNULL		= PMTimeHeader7+2
