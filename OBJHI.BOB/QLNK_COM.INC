;' $Header:   P:/PVCS/MISC/QLINK/QLNK_COM.INV   1.0   17 Jul 1997 12:21:10   BOB  $
;
; (C) Copyright 1994-2000 Qualitas, Inc.  All rights reserved.
;
; QLNK_COM.INC
;
; Common stuff
;

@PRODNAME equ	'QLINK'         ; The product name

@DBG	equ    <"### ">         ; Leading text for debugging output
@LQ	equ	"`"             ; Quote char use to the left of a name
@RQ	equ	"'"             ; ...                   right ...
@I	equ	<'    '>        ; Message indent
@MSG_INDEN2 SIZESTR @I		; Indent all messages this much after the 1st line
@MSG_INDENT equ @MSG_INDEN2 - 2 ; Less the surrounding quotes

@NATL_THOU equ	 ','            ; Thousands separator
@DEC_LEFT  equ	0001h		; Left-justified
@DEC_COMMA equ	0002h		; Comma insertion

@CON1KB equ	1*1024		; Constant  1KB
@CON4KB equ	4*1024		; ...	    4KB
@CON64KB equ	64*1024 	; ...	   64KB

@MAPOUT_LEN equ 16*1024 	; Size of MAPOUT buffer

@FLD_OBJ equ	0		; Index for objfiles
@FLD_EXE equ	1		; Index for exefile
@FLD_MAP equ	2		; Index for mapfile
@FLD_LIB equ	3		; Index for libraries
@FLD_DEF equ	4		; Index for deffile

@NFLDS	equ	5		; # fields


@LMB_NEWSEG_LEN equ 1024*@CON1KB ; Room for new segment data


ACBP_REC record $ACBP_A:3,$ACBP_C:3,$ACBP_B:1,$ACBP_P:1

@ACBP_A equ	mask $ACBP_A	; E0:  Alignment bits
@ACBP_C equ	mask $ACBP_C	; 1C:  Combine type bits
@ACBP_B equ	mask $ACBP_B	; 02:  Big bit
@ACBP_P equ	mask $ACBP_P	; 01:  USE16(0)/USE32(1) bit

; Values for $ACBP_A field

@ACBP_A_ABS	equ 0		; Absolute segment
@ACBP_A_BYTE	equ 1		; Byte-aligned
@ACBP_A_WORD	equ 2		; Word-aligned
@ACBP_A_PARA	equ 3		; Para-aligned
@ACBP_A_256B	equ 4		; 256-byte-aligned
@ACBP_A_DWORD	equ 5		; Dword-aligned
@ACBP_A_PAGE	equ 6		; 4KB-aligned

; Values for $ACBP_C field

@ACBP_C_PRIVATE equ 0		; Private:  do not combine
@ACBP_C_PUBLIC	equ 2		; Public:   combine with others
@ACBP_C_STACK	equ 5		; Stack:    combine with others
@ACBP_C_COMMON	equ 6		; Common:   combine by overlay, use largest size


FIXDAT_REC record $FIXDAT_F:1,$FIXDAT_FRM:3,$FIXDAT_T:1,$FIXDAT_P:1,$FIXDAT_TGT:2

@FIXDAT_F    equ mask $FIXDAT_F   ; 80:  F=1, FRM field (mod 4) has thread #
				  ;	 F=0, FRM field has frame method
@FIXDAT_FRM  equ mask $FIXDAT_FRM ; 70:  See @FIXDAT_F for meaning, @FIXDAT_FT_xxx for bits
@FIXDAT_T    equ mask $FIXDAT_T   ; 08:  T=1, TGT field has thread #
				  ;	 T=0, TGT field has target method
@FIXDAT_P    equ mask $FIXDAT_P   ; 04:  P=0 iff target displacement field present
@FIXDAT_TGT  equ mask $FIXDAT_TGT ; 03:  See @FIXDAT_T for meaning, @FIXDAT_FT_xxx for bits

@FIXDAT_FT_SEG	equ 0		; Frame/Target is a segment
@FIXDAT_FT_GRP	equ 1		; Frame/Target is a group
@FIXDAT_FT_EXT	equ 2		; Frame/Target is an external
@FIXDAT_FT_SEG2 equ 4		; Frame from LAST_DATSEG
@FIXDAT_FT_TGT	equ 5		; Frame from target's index


LOCAT_REC record $LOCAT_FIX:1,$LOCAT_M:1,$LOCAT_LOC:4,$LOCAT_DRO:10

@LOCAT_FIX equ	mask $LOCAT_FIX ; 8000:  FIXUPP(1) or THRED(0)
@LOCAT_M   equ	mask $LOCAT_M	; 4000:  Segment-relative(1) or Self-relative(0)
@LOCAT_LOC equ	mask $LOCAT_LOC ; 3C00:  Location (see @LOCAT_LOC_xxx)
@LOCAT_DRO equ	mask $LOCAT_DRO ; 03FF:  Data Record Offset

@LOCAT_LOC_LO	equ	0	;  0:  Low-order byte
@LOCAT_LOC_ELO	equ	1	;  1:  16-bit offset
@LOCAT_LOC_SEG	equ	2	;  2:  16-bit base segment/group
@LOCAT_LOC_VEC	equ	3	;  3:  Ptr16:16
;;;CAT_LOC_			;  4:  High-order byte (not supported)
;;;CAT_LOC_			;  5:  Same as 1
;;;CAT_LOC_			;  6:  Invalid
;;;CAT_LOC_			;  7:  Invalid
;;;CAT_LOC_			;  8:  Invalid
@LOCAT_LOC_EDD	equ	9	;  9:  32-bit offset
;;;CAT_LOC_			; 10:  Invalid
@LOCAT_LOC_FVEC equ    11	; 11:  Ptr16:32
;;;CAT_LOC_			; 12:  Invalid
;;;CAT_LOC_			; 13:  Same as 9
;;;CAT_LOC_			; 14:  Invalid
;;;CAT_LOC_			; 15:  Invalid


THRED_REC record $THRED_D:1,$THRED_R:1,$THRED_M:3,$THRED_T:2

@THRED_D equ	mask $THRED_D	; 40:  D=0 for Target thread, D=1 for Frame
;;;	 equ	mask $THRED_R	; 20:  (reserved)
@THRED_M equ	mask $THRED_M	; 1C:  Method
@THRED_T equ	mask $THRED_T	; 03:  Thread #


THRED_STR struc 		; T_THREAD/F_THREAD struc

THRED_M db	-1		; Method (-1 = invalid)
THRED_NDX dw	?		; Index

THRED_STR ends


SPSYM_STR struc 		; Special symbol struc (e.g., '_end' and '_edata')

SPSYM_PTXT dd	?		; 00:  Offset in DGROUP of text (CC_STR)
SPSYM_PGRP dd	?		; 04:  ...		   Group name
SPSYM_PCLS dd	?		; 08:  ...		   Class name
SPSYM_PSCT dd	?		; 0C:  ...		   Segment-Class-CombineType
SPSYM_LEN dd	?		; 10:  Length in bytes of SPSYM_PSCT data
SPSYM_PSYMBOL dd ?		; 14:  After PROC_SPEC_BEG, LA of symbol (SYM_STR)

SPSYM_STR ends


@SYMBOL_MAXLEN equ (255+1)+(255+1)+1 ; Maximum Symbol name + terminator,
				; Class name + terminator,
				; Combine type

POBJ_STR struc			; Linked list structure pointed to by
				; SEGOBJ_1ST
POBJ_NEXT dw	?		; 00:  Segment of next entry (-1 = last)
POBJ_SEQ dw	?		; 02:  Sequence # (origin-0)
POBJ_LEN db	?		; 04:  Length of name in bytes (excluding trailing zero)
POBJ_FID db	?		; 05:  FID starts here w/trailing zero

POBJ_STR ends


PLIB_STR struc			; Linked list structure pointed to by
				; SEGLIB_1ST
PLIB_NEXT dd	?		; 00:  LA of next entry (-1 = last)
PLIB_HNDL dw	?		; 04:  File handle (-1 = unopened)
PLIB_PGSZ dw	?		; 06:  Page size of library
PLIB_DSIZ dw	?		; 08:  Size of dictionary in blocks
PLIB_DOFF dd	?		; 0A:  Offset to dictionary
PLIB_LaDICT dd	?		; 0E:  LA of dictionary
PLIB_FLAG db	?		; 12:  Flags:  see LIBHDR_REC in LIB.INC
PLIB_CASE db	?		; 13:  Converter to lowercase if appropriate
PLIB_NMOD dw	?		; 14:  # modules in library (from extended dictionary)
PLIB_LaXDICT dd ?		; 16:  LA of extended dictionary (0 = none)
PLIB_PNAM dd	?		; 1A:  LA of FID as ASCIIZ string (CC_STR)

PLIB_STR ends


LIBDIR_STR struc		; Linked list of library directories

LIBDIR_NEXT dd	?		; 00:  Next entry (-1=last)
LIBDIR_DIR db	?		; 04:  ASCIIZ string of library directory

LIBDIR_STR ends


OBJHDR_STR struc		; .OBJ Header structure

OBJHDR_TYP db	?		; 00:  Record type
OBJHDR_LEN dw	?		; 01:  ...    length (not counting this header)

OBJHDR_STR ends
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
LMB_STR struc			; Linear memory block structure

LMB_LEN dd	?		; 00:  Length of this linear memory block (LMB)
LMB_HNDL dd	?		; 04:  LMB handle
LMB_INI dd	?		; 08:  Initial next current bound
LMB_CURB dq	?		; 0C:  ... current bounds (see BOUND_STR)
LMB_OVRB dq	?		; 14:  ... overall ...

LMB_STR ends
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
BOUND_STR struc

BOUND_BEG dd	?		; 00:  Starting address
BOUND_NXT dd	?		; 04:  Next	...

BOUND_STR ends
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PEROBJ_STR struc		; Maps LMB_PEROBJ entries
				; Accumulated over all .OBJ files
PEROBJ_PFID dd	?		; 00:  LA of FID text (CC_STR)
PEROBJ_PTHEADR dd ?		; 04:  ...   THEADR text (CC_STR, 0=none)
PEROBJ_PLINNUM dd ?		; 08:  LA of line number record (LINNUM_STR)
PEROBJ_PLIBSYM dd ?		; 0C:  LA of symbol which caused this .OBJ
				;      file to be loaded (0=none) (SYM_STR)

PEROBJ_STR ends
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PERSEG_STR struc		; Maps LMB_PERSEG entries
				; Accumulated over all .OBJ files
PERSEG_SEGSYM dd ?		; 00:  LA of segment name symbol (SYM_STR)
PERSEG_CLS    dd ?		; 04:  LA of class (PERCLS_STR)
PERSEG_LMB    db (type LMB_STR) dup (?) ; 08:  Each entry is an LMB_STR struc
PERSEG_GRPSYM dd ?		; 24:  LA of group name symbol (SYM_STR, 0=none)
PERSEG_GRPLNK dd ?		; 28:  LA of next segment in group (PERSEG_STR)
PERSEG_GRPOFF dd ?		; 2C:  Offset of this segment in group (0=ungrouped)
PERSEG_GRPOBJ dd ?		; 30:  LA of the last .OBJ which grouped this
				;      segment (PEROBJ_STR)
PERSEG_SEGSEQ dd ?		; 34:  LA of next segment in sequence (PERSEG_STR)
PERSEG_ADRB   dq ?		; 38:  Address bounds of this segment
PERSEG_NEWLEN dd ?		; 40:  New segment length (after adding the
				;      length of this segment)
PERSEG_OLDLEN dd ?		; 44:  Old segment length (before adding the
				;      length of this segment)
PERSEG_SEG1ST dd ?		; 48:  LA of first segment in SEGOBJ_STR (0=uninit)
PERSEG_SEGLST dd ?		; 4C:  LA of last segment in SEGOBJ_STR (0=uninit)
PERSEG_PPEROBJ dd ?		; 50:  LA of last .OBJ file which defined
				;      this segment
PERSEG_FLAG   dd ?		; 54:  Flags:  see PERSEG_REC below
PERSEG_WFLAG  dd ?		; 58:  Windows flags:  see NE_SEGTAB_REC
PERSEG_BAKPAT_LNK dd ?		; 5C:  LA of next BAKPAT record for this seg (0=none)

PERSEG_STR ends

PERSEG_REC record  \
$PERSEG_FIXUP:1,   \
$PERSEG_WFLAG:1,   \
$PERSEG_SEQ:1,	   \
$PERSEG_TYPES:1,   \
$PERSEG_SYMBOLS:1, \
$PERSEG_SUFCODE:1, \
$PERSEG_BEGDATA:1, \
$PERSEG_BSS:1,	   \
$PERSEG_STACK:1,   \
$PERSEG_OTHCLS:1,  \
$PERSEG_DGROUP:1,  \
$PERSEG_OTHGRP:1,  \
$PERSEG__TEXT:1,   \
$PERSEG_SKIP:1

@PERSEG_FIXUP	equ  mask $PERSEG_FIXUP   ; 00002000:  Segment has fixup data
@PERSEG_WFLAG	equ  mask $PERSEG_WFLAG   ; 00001000:  PERSEG_WFLAG is valid
@PERSEG_SEQ	equ  mask $PERSEG_SEQ	  ; 00000800:  Segment has been sequenced
@PERSEG_TYPES	equ  mask $PERSEG_TYPES   ; 00000400:  Segment name is $$TYPES
@PERSEG_SYMBOLS equ  mask $PERSEG_SYMBOLS ; 00000200:  ...	       $$SYMBOLS
@PERSEG_SUFCODE equ  mask $PERSEG_SUFCODE ; 00000100:  Class name has suffix 'CODE'
@PERSEG_BEGDATA equ  mask $PERSEG_BEGDATA ; 00000080:  ...	  is 'BEGDATA'
@PERSEG_BSS	equ  mask $PERSEG_BSS	  ; 00000040:  ...	     'BSS'
@PERSEG_STACK	equ  mask $PERSEG_STACK   ; 00000020:  ...	     'STACK'
@PERSEG_OTHCLS	equ  mask $PERSEG_OTHCLS  ; 00000010:  ...	     none of the above
@PERSEG_ALLCLS	equ  @PERSEG_SUFCODE or \
		     @PERSEG_BEGDATA or \
		     @PERSEG_BSS     or \
		     @PERSEG_STACK	    ; All specific classes
@PERSEG_DGROUP	equ  mask $PERSEG_DGROUP  ; 00000008:  Segment is in group 'DGROUP'
@PERSEG_OTHGRP	equ  mask $PERSEG_OTHGRP  ; 00000004:  ...	  not in ...
@PERSEG__TEXT	equ  mask $PERSEG__TEXT   ; 00000002:  ...	  '_TEXT'
@PERSEG_SKIP	equ  mask $PERSEG_SKIP	  ; 00000001:  ...	  skippable
					  ; (e.g., $$SYMBOLS, $$TYPES, or
					  ;  _end/_edata seg)
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SEGOBJ_STR struc		; Maps LMB_SEGOBJ entries
				; Accumulated over all .OBJ files
SEGOBJ_NXT dd	?		; 00:  LA of next SEGOBJ_STR entry (-1=none)
SEGOBJ_OFF dd	?		; 04:  Offset of this entry in the segment
SEGOBJ_SIZ dd	?		; 08:  Size of this segment piece
SEGOBJ_PPEROBJ dd ?		; 0C:  LA of PEROBJ_STR

SEGOBJ_STR ends
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PERGRP_STR struc		; Maps LMB_PERGRP entries
				; Accumulated over all .OBJ files
PERGRP_GRPSYM dd ?		; 00:  LA of group name symbol (SYM_STR)
PERGRP_GRPLNK dd ?		; 04:  LA of next PERSEG_STR entry in chain (PERSEG_STR)
PERGRP_ADRB dq	?		; 08:  Address bounds of this group
PERGRP_FLAG dd	?		; 10:  Flags:  see PERGRP_REC below

PERGRP_STR ends

PERGRP_REC record \
$PERGRP_SEGTAB:1

@PERGRP_SEGTAB equ mask $PERGRP_SEGTAB ; 00000001:  Used in segment Table
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PERCLS_STR struc		; Maps LMB_PERCLS entries
				; Accumulated over all .OBJ files
PERCLS_PSYM dd	?		; 00:  LA of class name symbol (SYM_STR,
				;      0=none, -1=skip)
PERCLS_PERLSEG dd ?		; 04:  LA of logical segment info (PERLSEG_STR)
PERCLS_PERSEG1ST dd ?		; 08:  LA of first segment in class (PERSEG_STR)

PERCLS_STR ends

@PERCLS_NONE equ 0		; No class symbol
@PERCLS_SKIP equ -1		; Skip this class
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PERLSEG_STR struc		; Maps LMB_PERLSEG entries
				; Accumulated over all .OBJ files
PERLSEG_LSEG dd ?		; 00:  Logical segment # (0=none)
PERLSEG_FLAG dd ?		; 04:  Flags:  see PERLSEG_REC below
PERLSEG_LEN dd	?		; 08:  Accumulation of segment lengths in this class

PERLSEG_STR ends

PERLSEG_REC record \
$PERLSEG_DGROUP:1, \
$PERLSEG_MOVABLE:1,\
$PERLSEG_FIXUP:1,  \
$PERLSEG_SEGTAB:1

@PERLSEG_DGROUP equ mask $PERLSEG_DGROUP  ; 00000008:	Segment is in DGROUP
@PERLSEG_MOVABLE equ mask $PERLSEG_MOVABLE ; 00000004:	Segment is movable
@PERLSEG_FIXUP	equ mask $PERLSEG_FIXUP   ; 00000002:	Segment has fixup data
@PERLSEG_SEGTAB equ mask $PERLSEG_SEGTAB  ; 00000001:	Used in segment Table
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
LNAMES_STR struc		; Maps LMB_LNAMES entries
				; Cleared after each .OBJ file
LNAMES_PTXT dd	?		; 00:  LA of LNAMES_TXT struc
LNAMES_PSYM dd	?		; 04:  LA of symbol (SYM_STR)

LNAMES_STR ends


LNAMES_TXT struc

LNAMES_TXT_FLAG db ?		; 00:  Global(1)/local(0) name flag
LNAMES_TXT_CC db ?		; 01:  CC_STR of text

LNAMES_TXT ends
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SEGDEF_STR struc		; Maps LMB_SEGDEF entries
				; Cleared after each .OBJ file
SEGDEF_PPERSEG dd ?		; 00:  LA of PERSEG entry (PERSEG_STR)

SEGDEF_STR ends
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
GRPDEF_STR struc		; Maps LMB_GRPDEF entries
				; Cleared after each .OBJ file
GRPDEF_PPERGRP dd ?		; 00:  LA of PERGRP entry (PERGRP_STR)

GRPDEF_STR ends
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
EXTDEF_STR struc		; Maps LMB_EXTDEF entries
				; Cleared after each .OBJ file
EXTDEF_PSYM dd	?		; 00:  LA of symbol (SYM_STR)
EXTDEF_FLAG dd	?		; 04:  Flags (see EXTDEF_REC below)

EXTDEF_STR ends

EXTDEF_REC record \
$EXTDEF_MAT:1
@EXTDEF_MAT equ mask $EXTDEF_MAT ; 01:	EXTDEF entry has matching entry

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
COMDEF_STR struc		; Maps LMB_COMDEF entries
				; Accumulated over all .OBJ files
COMDEF_PPUBDEF dd ?		; 00:  LA of public (PUBDEF_STR)

COMDEF_STR ends
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PUBDEF_STR struc		; Maps LMB_PUBDEF entries
				; Accumulated over all .OBJ files
PUBDEF_PSYM dd	?		; 00:  LA of symbol (SYM_STR)
PUBDEF_BASE dd	?		; 04:  Base address (filled in during CHECK_PUBEXT)
PUBDEF_ADDR dd	?		; 08:  Base+offset  ( ...	      OMF_PUBDEF)
PUBDEF_PPERGRP dd ?		; 0C:  LA of base group   (PERGRP_STR) (0=none)
PUBDEF_PPERSEG dd ?		; 10:  ...	  segment (PERSEG_STR) (0=none)
PUBDEF_PPEROBJ dd ?		; 14:  LA of PEROBJ entry (PEROBJ_STR)
PUBDEF_SIZ  dd	?		; 18:  Size of symbol in bytes (COMDEF)
PUBDEF_NELM dd	?		; 1C:  # elements (element size=LEN/NELM) (COMDEF)
				;      -1 = near data
PUBDEF_SRT  dd	?		; 20:  Index used for sorting (alpha & num)
PUBDEF_COMDAT dd ?		; 24:  LA of matching COMDAT_STR (0=none)
PUBDEF_IMPDEF dd   ?		; 28:  LA of import if @SYMFL_IMP (IMPDEF_STR) (0=none)

PUBDEF_STR ends
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
FIXUPP_STR struc		; Maps LMB_FIXUP entries
				; Accumulated over all .OBJ files
FIXUPP_DRO_BEG dd ?		; 00:  LA of data record fixup start
FIXUPP_DRO_CUR dd ?		; 04:  ...		       current
FIXUPP_OFF dd	?		; 08:  Offset of data record
FIXUPP_LOCAT dw ?		; 0C:  LOCAT word
FIXUPP_FIXDAT db ?		; 0E:  FIXDAT byte
FIXUPP_FLAG db	?		; 0F:  Flags (see FIXFL_REC below)
				;		   SEGDEF      GRPDEF	   EXTDEF
FIXUPP_FRM dd	?		; 10:  Frame str:  PERSEG_STR, PERGRP_STR, SYM_STR
FIXUPP_TGT dd	?		; 14:  Target ...
FIXUPP_DSP dd	?		; 18:  Target displacement
FIXUPP_PPERSEG dd ?		; 1C:  LA of segment of DRO (PERSEG_STR)
FIXUPP_PPEROBJ dd ?		; 20:  LA of this .OBJ file (PEROBJ_STR)
FIXUPP_OLDLEN dd ?		; 24:  Old segment length (before adding the
				;      length of this segment)
FIXUPP_LASTOLDLEN dd ?		; 28:  Last value of FIXUPP_OLDLEN

FIXUPP_STR ends

FIXFLG_REC record \
$FIXFL_FCT:1,	\
$FIXFL_ABS:1,	\
$FIXFL_MOD:1,	\
$FIXFL_LID:1,	\
$FIXFL_32 :1

@FIXFL_FCT equ	mask $FIXFL_FCT ; 10:  This fixup is a Far Call Translation
@FIXFL_ABS equ	mask $FIXFL_ABS ; 08:  ...	     with an absolute constant
@FIXFL_MOD equ	mask $FIXFL_MOD ; 04:  ...	     to a MODEND record
@FIXFL_LID equ	mask $FIXFL_LID ; 02:  ...		an LIDATA record
@FIXFL_32  equ	mask $FIXFL_32	; 01:  ...		a 32-bit record
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
LINNUM_STR struc		; Maps LMB_LINNUM entries
				; Accumulated over all .OBJ files
LINNUM_PPEROBJ dd ?		; 00:  LA of PEROBJ entry (PEROBJ_STR)
LINNUM_PPERGRP dd ?		; 04:  LA of base group   (PERGRP_STR) (0=none)
LINNUM_PPERSEG dd ?		; 08:  ...	  segment (PERSEG_STR) (0=none)
LINNUM_LINNUM dd ?		; 0C:  Line number
LINNUM_NUMOFF dd ?		; 10:  Line number offset

LINNUM_STR ends
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
BAKPAT_STR struc		; Maps LMB_BAKPAT entries
				; Accumulated over all .OBJ files
BAKPAT_LNK  dd	?		; 00:  LA of next BAKPAT record for this seg (0=none)
BAKPAT_TYPE dd	?		; 04:  Location type (see @BAKPATLOC_xxx)
BAKPAT_OFF  dd	?		; 05:  Offset
BAKPAT_VAL  dd	?		; 09:  Value

BAKPAT_STR ends


@BAKPATLOC_BYTE equ 0		; Byte fixup
@BAKPATLOC_WORD equ 1		; Word ...
@BAKPATLOC_DWORD equ 2		; Dword ...
@BAKPATLOC_MAX	equ 2		; Maximum allowed value

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
DATREC_STR struc		; LEDATA/LIDATA struc used in LMB_PERSEG

DATREC_TYP db	?		; 00:  OMF type
DATREC_OFF dd	?		; 01:  Data offset
DATREC_LEN dd	?		; 05:  Data length

; Followed by the LEDATA/LIDATA data

DATREC_STR ends
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
DEFSEG_STR struc		; Definitions File SEGMENTS struc
				; Accumulated over all .OBJ files
DEFSEG_FLAG dd	?		; 00:  Flags (see DEF_FLAG)
DEFSEG_SEGNAME db 256 dup (?)	; 04:  CC_STR of Segment name
DEFSEG_CLSNAME db 256 dup (?)	; 04:  ...	   Class   ...

DEFSEG_STR ends
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
EXPDEF_STR struc		; Exported names struc
				; Accumulated over all .OBJ files
EXPDEF_PPEROBJ dd ?		; 00:  LA of PEROBJ entry (PEROBJ_STR)
EXPDEF_PSYM    dd ?		; 04:  LA of symbol (SYM_STR)
EXPDEF_ORDINAL dw ?		; 08:  Ordinal (if EXPDEF_FLAG.EXPFL_ORD)
EXPDEF_FLAG    dw ?		; 0A:  Flags (see EXPFL_REC below)
EXPDEF_EXPNAME db 256 dup (?)	; 0C:  CC_STR of Exported name
EXPDEF_INTNAME db 256 dup (?)	;10C:  ...	 Internal ...

EXPDEF_STR ends

EXPFL_REC record \
$EXPFL_PRV:1,	\
$EXPFL_NON:1,	\
$EXPFL_ORD:1,	\
$EXPFL_RES:1,	\
$EXPFL_NOD:1,	\
$EXPFL_CNT:5

@EXPFL_PRV equ	mask $EXPFL_PRV ; 0200:  PRIVATE
@EXPFL_NON equ	mask $EXPFL_NON ; 0100:  NONAME
@EXPFL_ORD equ	mask $EXPFL_ORD ; 0080:  Ordinal field is valid
@EXPFL_RES equ	mask $EXPFL_RES ; 0040:  Resident name
@EXPFL_NOD equ	mask $EXPFL_NOD ; 0020:  No data
@EXPFL_CNT equ	mask $EXPFL_CNT ; 001F:  Parm count
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
IMPDEF_STR struc		; Imported names struc
				; Accumulated over all .OBJ files
IMPDEF_PPEROBJ dd ?		; 00:  LA of .OBJ entry (PEROBJ_STR)
IMPDEF_ORDINAL dw ?		; 04:  Ordinal # (if IMPDEF_ENTRY[0] == 0)
IMPDEF_FLAG    db ?		; 06:  Flags (0=name, 0!=ordinal)
	       db ?		; 07:  (reserved)
IMPDEF_PPERMOD dd ?		; 08:  LA of module name (PERMOD_STR)
IMPDEF_INTNAME db 256 dup (?)	; 0C:  CC_STR of Internal name
IMPDEF_EXPNAME db 256 dup (?)	;10C:  CC_STR of Exported name
IMPDEF_ENTRY   db 256 dup (?)	;30C:  CC_STR of Entry name

IMPDEF_STR ends
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PERMOD_STR struc		; Module names struc
				; Accumulated over all .OBJ files
PERMOD_MODSYM dd ?		; 00:  LA of module name (SYM_STR)
PERMOD_FLAG dd	?		; 04:  Flags (see PERMOD_REC)

PERMOD_STR ends

PERMOD_REC record \
$PERMOD_USED:1

@PERMOD_USED equ mask $PERMOD_USED ; 00000001:	Name copied to module reference table
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
COMDAT_STR struc		; Maps LMB_COMDAT entries
				; Accumulated over all .OBJ files
COMDAT_TYP db	?		; 00:  OMF type
COMDAT_FLAG db	?		; 01:  Flag byte
COMDAT_ATTR db	?		; 02:  Attribute byte
COMDAT_ALIN db	?		; 03:  Alignment byte
COMDAT_OFF dd	?		; 04:  Data offset
COMDAT_PBGRP dd ?		; 08:  Public Base Group   (-1=none/not present)
COMDAT_PBSEG dd ?		; 0C:  Public Base Segment (-1=none/not present)
COMDAT_PNI dd	?		; 10:  Public Name Index
COMDAT_LEN dd	?		; 14:  Data length
COMDAT_CSUM dd	?		; 18:  Data checksum
COMDAT_PPERSEG dd ?		; 1C:  Data segment (PERSEG_STR)
COMDAT_NEXT dd	?		; 20:  Next LMB_COMDAT entry (-1=last)

; Followed by the COMDAT data

COMDAT_STR ends


CDFL_REC record \
$CDFL_ROM:1,	\
$CDFL_LCL:1,	\
$CDFL_ITER:1,	\
$CDFL_CONT:1

@CDFL_ROM  equ	mask $CDFL_ROM	; Data in code
@CDFL_LCL  equ	mask $CDFL_LCL	; Local name
@CDFL_ITER equ	mask $CDFL_ITER ; Iterated data (otherwise enumerated)
@CDFL_CONT equ	mask $CDFL_CONT ; Continuation of previous COMDAT record
				; for this symbol
@CDFL_ALL  equ	@CDFL_ROM or @CDFL_LCL or @CDFL_ITER or @CDFL_CONT


CDAT_REC record \
$CDAT_SEL:4,	\
$CDAT_TYP:4

@CDAT_SEL equ	mask $CDAT_SEL	; Selection criteria (see @CDATSEL_xxx below)
@CDAT_TYP equ	mask $CDAT_TYP	; Allocation type    (see @CDATTYP_xxx below)

@CDATSEL_NONE equ 00h		; No match
@CDATSEL_ANY  equ 01h		; Pick any instance
@CDATSEL_SIZE equ 02h		; Pick any instance of same length
@CDATSEL_CSUM equ 03h		; Pick any instance of same checksum
@CDATSEL_MAX  equ 03h		; Maximum selection value

@CDATTYP_EXPL equ 00h		; Allocate in segment
@CDATTYP_FC16 equ 01h		; ...	   as CODE16
@CDATTYP_FD16 equ 02h		; ...	      DATA16
@CDATTYP_CD32 equ 03h		; ...	      CODE32
@CDATTYP_DT32 equ 04h		; ...	      DATA32
@CDATTYP_MAX  equ 04h		; Maximum allocation value

@CDAL_SEG   equ 0		; Use value from SEGDEF
@CDAL_BYTE  equ 1		; Byte-aligned
@CDAL_WORD  equ 2		; Word-...
@CDAL_PARA  equ 3		; Para-...
@CDAL_256B  equ 4		; 256 byte-...
@CDAL_DWORD equ 5		; Dword-...
@CDAL_MAX   equ 5		; Maximum alignment value
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
UNCURB	macro	REG1,NAM,REG2

ifb <REG2>
	bound	&REG1,LMB_&NAM.LMB_CURB ; Ensure within current bounds
else
	bound	&REG1,AGROUP:[&REG2].&NAM&_LMB.LMB_CURB ; Ensure within current bounds
endif				; IFB <REG2>
	endm			; UNCURB


UNOVRB	macro	REG1,NAM,REG2

ifb <REG2>
	bound	&REG1,LMB_&NAM.LMB_OVRB ; Ensure within overall bounds
else
	bound	&REG1,AGROUP:[&REG2].&NAM&_LMB.LMB_OVRB ; Ensure within overall bounds
endif				; IFB <REG2>
	endm			; UNOVRB


CC_STR	struc			; (Count, Char[]) struc

CC_COUNT db	?		; 00:  Count
CC_CHAR db	1 dup (?)	; 01:  Char[]

CC_STR	ends


CCMAC	macro	TXT,NAM 	; Form (Count, Char[]) variable
	local	L1,L2

ifnb <NAM>
	public	NAM
NAM	label	byte
endif				; IFNB <NAM>
L1	db	L2,TXT		; The count & text (CC_STR)
L2	equ	$-L1-(type CC_COUNT) ; Length of ...

	endm			; CCMAC
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Name Substitution structures and equates

NS_STR	struc

NS_NEXT dd	?		; Ptr to next entry
NS_FLAG dd	?		; Flags (see NS_REC below)
NS_OBJSEQ dw	?		; .OBJ sequence # (-1 = deleted)
NS_LEN1 db	?		; CC_STR for Name1
NS_NAME1 db	?		; followed by CC_STR for Name2 (if needed)

NS_STR	ends


NS_REC	record	\
$NS_STOP:1,	\
$NS_HALT:1

@NS_STOP equ	mask $NS_STOP	; Stop substitution on this symbol
@NS_HALT equ	mask $NS_HALT	; Halt all substitutions

