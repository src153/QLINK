;' $Header:   P:/PVCS/MISC/QLINK/QLNK_LIB.ASV   1.1   17 Jul 1997 12:36:48   BOB  $
	title	QLNK_LIB -- QLINK Library File Processor
	page	58,122
	name	QLNK_LIB

COMMENT|		Module Specifications

Copyright:  (C) Copyright 1994-7 Qualitas, Inc.  All rights reserved.

Program derived from:  None.

Original code by:  Bob Smith, August, 1994.

Modifications by:  None.

|
.386
.xlist
	include MASM.INC
	include 386.INC
	include PTR.INC
	include ASCII.INC
	include ALLMEM.INC
	include DOSCALL.INC
	include OPEN.INC
	include LIB.INC
	include OMF.INC

	include QLNK_COM.INC
	include QLNK_IWF.INC
	include QLNK_SEG.INC
	include QLNK_SYM.INC
.list

DATA	segment use32 dword public 'data' ; Start DATA segment
	assume	ds:DGROUP

	extrn	ARG_FLAG:dword
	include QLNK_ARG.INC

	extrn	LCL_FLAG:dword
	include QLNK_LCL.INC

	extrn	ERRCNT:dword
	extrn	LMB_SYMBOL:dword
	extrn	LMB_TXTSTR:dword
	extrn	LaDATA:dword
	extrn	IWFCNT:dword

	extrn	LaLIB_1ST:dword
	extrn	LaLIB_LAST:dword
	extrn	EXT_LIB:byte
	extrn	NEXTSEG:word

	extrn	THISOBJ_STR:dword
	extrn	THISOBJ_FID:dword
	extrn	THISOBJ_FIL:dword

	extrn	WORKAREA:byte
	extrn	LaSYMFIND:dword

	extrn	MSG_CRLF:byte

	public	LaLIBENV
LaLIBENV dd	0		; LA of LIB= envorinment (0=none)

	public	LaLIBNAM
LaLIBNAM dd	?		; LA of library name just opened

@LIB_BLKSIZ equ  512		; # bytes per block
LOG2 @LIB_BLKLG2,@LIB_BLKSIZ	; Log (base 2) of ...

	public	LIB_BUCK,LIB_PGSZ,LIB_DOFF,LIB_DSIZ,LIB_LaDICT,LIB_PGNO
	public	LIB_NMOD,LIB_LaXDICT
LIB_BUCK dd	37		; Library # buckets
LIB_PGSZ dd	?		; Library page size
LIB_DOFF dd	?		; Library offset to dictionary
LIB_DSIZ dd	?		; Library dictionary size in blocks
LIB_LaDICT dd	?		; LA of dictionary
LIB_PGNO dd	?		; Library page #
LIB_NMOD dd	?		; # modules in library (from extended dictionary)
LIB_LaXDICT dd	?		; LA of extended dictionary

	public	LIB_BLKNDX,LIB_BLKNDX_D
	public	LIB_BLKOFF,LIB_BLKOFF_D
	public	LIB_BLKCNT
LIB_BLKNDX dd	?		; Library block index
LIB_BLKNDX_D dd ?		; ...		      delta
LIB_BLKOFF dd	?		; Library block offset
LIB_BLKOFF_D dd ?		; ...		      delta
LIB_BLKCNT dd	?		; Block counter

	public	LIBHNDL
LIBHNDL dw	?		; Library file handle

	public	LIB_FLAG,LIB_CASE
LIB_FLAG db	?		; Library flags (see LIBHDR_REC)
LIB_CASE db	?		; Case converter (dependent upon $LIBHDR_CASE)

	public	MSG_LIBOPEN,MSG_LIBREAD,MSG_LIBMOVE,MSG_LIBTYPE
MSG_LIBOPEN db	'��> FAIL:  Unable to open .LIB file:  ',EOS
MSG_LIBREAD db	'��> FAIL:  Unable to read .LIB file:  ',EOS
MSG_LIBMOVE db	'��> FAIL:  Unable to move .LIB file pointer:  ',EOS
MSG_LIBTYPE db	 '��> FAIL:  Invalid .LIB file:  ',EOS

	public	DBGMSG_OPENLIB,DBGMSG_READOBJ,DBGMSG_FINDSYM
DBGMSG_OPENLIB db  @DBG,"Opening library:      ",EOS
DBGMSG_READOBJ db  @DBG,"Reading .OBJ file:    ",EOS
DBGMSG_FINDSYM db  @DBG,"Found symbol @ "
DBGMSG_FINDSYM1 db "____:  ",EOS

DATA	ends			; End DATA segment


CODE	segment use32 byte public 'prog' ; Start CODE segment
	assume	cs:PGROUP,ds:PGROUP

	extrn	DISP_ASCIIZ:near
	extrn	DW2HEX:near
	extrn	U32_DISP_MSG:near
	extrn	U32_SKIP_WHITE:near
	extrn	CB_TERM:near
	extrn	DUMPIT:near
	extrn	PROC_OBJ:near
	extrn	DISP_FIDNAME:near
	extrn	U32_CALC_HIGHSEG:near

	NPPROC	PROC_LIBS -- Process Library Files
	assume	ds:AGROUP,es:AGROUP,fs:DGROUP,gs:AGROUP,ss:nothing
COMMENT|

Process library files looking for a symbol

On exit:

CF	=	0 if we found the symbol
	=	1 if not

|

	pushad			; Save registers
PROC_LIBS_NEXT:

; Read in the .LIB files one by one and process them

	mov	edi,LaLIB_1ST	; Get the first LA

	and	edi,edi 	; Are there any .LIB files?
	jz	near ptr PROC_LIBS_ERRCOM ; Jump if not
PROC_LIBS_NEXTLIB:
	btr	LCL_FLAG,$LCL_BRK ; Izit break time?
	jc	near ptr CB_TERM ; Jump if so

; Attempt to open the .LIB file

	call	OPEN_LIBFIL	; Attempt to open .LIB file in [EDI].PLIB_PNAM
	jc	near ptr PROC_LIBS_ERROBJ ; Jump if no luck

; Search for this symbol in the .LIB file

	call	FIND_LIBSYM	; Find it
	jnc	short PROC_LIBS_DOITLIB ; Jump if found

	mov	edi,AGROUP:[edi].PLIB_NEXT ; Get the next LA

	cmp	edi,-1		; Izit the last one?
	jne	short PROC_LIBS_NEXTLIB ; Jump if not

	jmp	PROC_LIBS_ERRCOM ; Join common error code


PROC_LIBS_DOITLIB:

; If there are preceding unmatched extrns, skip loading the .OBJ file

	cmp	IWFCNT[@IWF_FAL*(type IWFCNT)],0 ; Any preceding unmatched extrns?
	ja	near ptr PROC_LIBS_EXIT ; Jump if so (note CF=0)

	call	READ_LIBOBJ	; Read in and process a library .OBJ module
	jc	near ptr PROC_LIBS_ERROBJ ; Jump if in error

; Process dependent files as described in the extended dictionary
; if it's present and /NOE is not

	mov	edx,AGROUP:[edi].PLIB_LaXDICT ; Get LA of extended dictionary

	cmp	edx,-1		; Izit invalid?
	je	near ptr PROC_LIBS_EXIT ; Jump if not (note CF=0)

; Search for this page # in the list

	movzx	ecx,AGROUP:[edi].PLIB_NMOD ; Get # modules in dictionary
	mov	eax,LIB_PGNO	; Get the page #
PROC_LIBS_NEXTPGNO:
	cmp	ax,AGROUP:[edx].LIBXMOD_PGNO ; Same page #?
	je	short PROC_LIBS_DOITPGNO ; Jump if so

	add	edx,type LIBXMOD_STR ; Skip to next entry

	loop	PROC_LIBS_NEXTPGNO ; Jump if more modules to check
PROC_LIBS_CLC:
	clc			; Mark as successful

	jmp	short PROC_LIBS_EXIT ; Join common exit code


PROC_LIBS_DOITPGNO:
	movzx	ebx,AGROUP:[edx].LIBXMOD_PMOD ; Get offset from
				; start of extended dictionary to list of
				; dependent modules (null-terminated)
;;;;;;; add	ebx,4		; This makes the arithmetic come out right
;;;;;;; 			; but I'm not sure why
	add	ebx,AGROUP:[edi].PLIB_LaXDICT ; Plus LA of extended dictionary

@PGNO_DUP equ	0FFFFh		; Duplicate page # marker

	mov	AGROUP:[edx].LIBXMOD_PGNO,@PGNO_DUP ; Zap to avoid duplicates
PROC_LIBS_NEXTMOD:
	xor	eax,eax 	; Zero to use as dword
	imul	ax,AGROUP:[ebx].LIBDEP_MOD,type LIBXMOD_STR ; Module # times
				;  size of struc
	and	eax,eax 	; Izit the end?
	jz	short PROC_LIBS_CLC ; Jump if so

	add	eax,AGROUP:[edi].PLIB_LaXDICT ; Plus LA of start of extended dictionary
	mov	ecx,@PGNO_DUP	; Get duplicate marker
	xchg	cx,AGROUP:[eax].LIBXMOD_PGNO ; Get the page #

	cmp	cx,@PGNO_DUP	; Izit already done?
	je	short @F	; Jump if so

	mov	LIB_PGNO,ecx	; Save as page #
	call	READ_LIBOBJ	; Read in and process a library .OBJ module
	jc	near ptr PROC_LIBS_ERROBJ ; Jump if in error
@@:

; I used to think that the dependency table was a list of modules
; which should be linked in.  I now think it's a single module.

;;;;;;; add	ebx,type LIBDEP_STR ; Skip to next module #
;;;;;;;
;;;;;;; jmp	PROC_LIBS_NEXTMOD ; Go around again
	jmp	PROC_LIBS_CLC	; Join common exit code


PROC_LIBS_ERROBJ:
	or	LCL_FLAG,@LCL_ERROBJ ; Mark as error processing .OBJ file
PROC_LIBS_ERRCOM:
	call	DUMPIT		; Dump all the tables

	stc			; Mark as not found
PROC_LIBS_EXIT:
	popad			; Restore

	ret			; Return to caller

	assume	ds:nothing,es:nothing,fs:nothing,gs:nothing,ss:nothing

PROC_LIBS endp			; End PROC_LIBS procedure
	NPPROC	READ_LIBOBJ -- Read In And Process A Library .OBJ File
	assume	ds:AGROUP,es:AGROUP,fs:DGROUP,gs:AGROUP,ss:nothing
COMMENT|

Read in and process a library .OBJ file

On exit:

CF	=	0 if all went well
	=	1 if not

|

	pushad			; Save registers

; Move file pointer to this .OBJ file

	mov	ecx,LIB_PGNO	; Get the page #
	imul	ecx,LIB_PGSZ	; Times the page size

	mov	dx,cx		; Copy low-order word
	shr	ecx,16		; Shift down high-order word so CX:DX = size
	mov	bx,LIBHNDL	; Get the .LIB file handle
	mov	al,0		; Method is from start of file
	DOSCALL @MOVFP2 	; Move the file pointer
	jc	near ptr READ_LIBOBJ_ERRMOVE ; Jump if something went wrong

; Read in the .OBJ file

	movzx	edx,NEXTSEG	; Get next available segment
	shl	edx,4-0 	; Convert from paras to bytes
	mov	ecx,@CON64KB	; Read in the whole .OBJ file *FIXME*
;;;;;;; mov	bx,LIBHNDL	; Get the .LIB file handle
	DOSCALL @READF2 	; Read it in
	jc	short READ_LIBOBJ_ERRREAD ; Jump if something went wrong

	mov	ecx,eax 	; Copy as actual length
	mov	esi,edx 	; ...	  start of OMFs

	push	eax		; Pass # bytes used
	call	U32_CALC_HIGHSEG ; Calculate new HIGHSEG value

; Process the .OBJ file

	mov	eax,AGROUP:[edi].PLIB_PNAM ; Get LA of filename (Count, Char[])
	mov	THISOBJ_FID,eax ; Save for later use
	mov	THISOBJ_STR,edi ; ...
	mov	THISOBJ_FIL,esi ; ...

	test	ARG_FLAG,@ARG_DBGMSG ; Displaying debugging messages?
	jz	short PROC_FILES_XDBG ; Jump if not

	pushad			; Save for a moment

	lea	edx,DBGMSG_READOBJ ; Get line start
	add	edx,LaDATA	; Plus LA of DGROUP
	DOSCALL @STROUT 	; Display it

	cmp	ds:[esi].LO,@OMF_THEADR ; Duzit start with a THEADR?
	lea	edx,ds:[esi+3]	; DS:EDX ==> filename (Count, Char[]) in THEADR
	je	short @F	; Assume so

	mov	edx,THISOBJ_FID ; DS:EDX ==> filename (Count, Char[])
@@:
	movzx	ecx,ds:[edx].LO ; Get the count
	inc	edx		; Skip over it
	mov	bx,@STD_OUT	; Send to standard output
	DOSCALL @WRITF2 	; Write it out

	lea	edx,MSG_CRLF	; Get line ending
	add	edx,LaDATA	; Plus LA of DGROUP
	DOSCALL @STROUT 	; Display it

	popad			; Restore
PROC_FILES_XDBG:
	call	PROC_OBJ	; Process a single .OBJ file at DS:ESI, len ECX
				; Return with CF significant
	jmp	short READ_LIBOBJ_EXIT ; Join common exit code


COMMENT|

Unable to read .LIB file.

|

READ_LIBOBJ_ERRREAD:
	inc	ERRCNT		; Mark as writing to error file

	inc	IWFCNT[@IWF_FAL*(type IWFCNT)] ; Count in a failure

	push	fs		; Pass DGROUP segment
	push	dword ptr (offset DGROUP:MSG_LIBREAD) ; Pass offset of message
	call	U32_DISP_MSG	; Display the message

	push	0		; Don't display THEADR (it's not valid)
	call	DISP_FIDNAME	; Display the name of the .LIB file at THISOBJ_FID

	dec	ERRCNT		; Mark as no longer writing to error file

	jmp	short READ_LIBOBJ_ERRCOM ; Join common error code


COMMENT|

Unable to move .LIB file pointer.

|

READ_LIBOBJ_ERRMOVE:
	inc	ERRCNT		; Mark as writing to error file

	inc	IWFCNT[@IWF_FAL*(type IWFCNT)] ; Count in a failure

	push	fs		; Pass DGROUP segment
	push	dword ptr (offset DGROUP:MSG_LIBMOVE) ; Pass offset of message
	call	U32_DISP_MSG	; Display the message

	push	1		; Display THEADR
	call	DISP_FIDNAME	; Display the name of the .LIB file at THISOBJ_FID

	dec	ERRCNT		; Mark as no longer writing to error file

;;;;;;; jmp	short READ_LIBOBJ_ERRCOM ; Join common error code

READ_LIBOBJ_ERRCOM:
	stc			; Mark as in error
READ_LIBOBJ_EXIT:
	popad			; Restore

	ret			; Return to caller

	assume	ds:nothing,es:nothing,fs:nothing,gs:nothing,ss:nothing

READ_LIBOBJ endp		; End READ_LIBOBJ procedure
	NPPROC	OPEN_LIBFIL -- Open A Library File
	assume	ds:AGROUP,es:AGROUP,fs:DGROUP,gs:AGROUP,ss:nothing
COMMENT|

Open a library file

On entry:

EDI	=	LA of PLIB_STR

On exit:

CF	=	0 if successful
	=	1 if not

|

	pushad			; Save registers

	mov	edx,ds:[edi].PLIB_PNAM ; DS:EDX ==> next .LIB FID
				; as ASCIIZ (Count, Char[])
	inc	edx		; Skip over length byte
	mov	ax,AGROUP:[edi].PLIB_HNDL ; Get file handle

	cmp	ax,-1		; Izit invalid?
	jne	near ptr OPEN_LIBFIL_READ ; Jump if not (with handle in AX)

	mov	LaLIBNAM,edx	; Save as LA of LIB name

	mov	al,@OPEN_R	; Open as read-only
	DOSCALL @OPENF2 	; Open the .LIB file
				; Return AX = file handle
	jnc	near ptr OPEN_LIBFIL_READ0 ; Jump if found

; Traverse the paths found in the LIB= environment variable
; to find the .LIB file

	mov	esi,LaLIBENV	; Get LA of LIB= text

	and	esi,esi 	; Izit valid?
	jz	near ptr OPEN_LIBFIL_ERR ; Jump if not

; Copy the next path to WORKAREA

OPEN_LIBFIL_NEXTPATH:
	call	U32_SKIP_WHITE	; Skip over white space

	lods	ds:[esi].LO	; Get first char

	cmp	al,0		; Izit end of the line?
	je	near ptr OPEN_LIBFIL_ERR ; Jump if so

	cmp	al,';'          ; Izit empty path?
	je	short OPEN_LIBFIL_NEXTPATH ; Jump if so

	dec	esi		; Back off to first char

	push	edi		; Save LA of PLIB_STR

	lea	edi,WORKAREA	; Get offset in DGROUP of work area
	add	edi,LaDATA	; Plus LA of DGROUP
OPEN_LIBFIL_NEXTCHAR:
	lods	ds:[esi].LO	; Get next char

	cmp	al,0		; Izit end of the line?
	je	short OPEN_LIBFIL_END ; Jump if so

	cmp	al,';'          ; Izit end of the path?
	je	short OPEN_LIBFIL_END ; Jump if so

	stos	AGROUP:[edi].LO ; Save in workarea

	jmp	OPEN_LIBFIL_NEXTCHAR ; Go around again


OPEN_LIBFIL_END:
	dec	esi		; Back off to last char

; Append a path separator if no drive or path separator already there

	mov	al,AGROUP:[edi-1] ; Get last char appended

	cmp	al,':'          ; Izit a drive separator?
	je	short @F	; Jump if so

	cmp	al,'\'          ; Izit a path separator?
	je	short @F	; Jump if so

	mov	al,'\'          ; Get path separator
	stos	AGROUP:[edi].LO ; Save in workarea
@@:

; Append the original .LIB filename

	push	esi		; Save for a moment

	mov	esi,edx 	; Copy start of original ASCIIZ .LIB file
@@:
	lods	AGROUP:[esi].LO ; Get the next char
	stos	AGROUP:[edi].LO ; Save in workarea

	cmp	al,0		; Izit end of the ASCIIZ .LIB filename?
	jne	short @B	; Jump if not

	mov	ecx,edi 	; Save LA of next address (after terminating zero)

	pop	esi		; Restore

	pop	edi		; ...

; Attempt to open the .LIB file

	push	edx		; Save LA of ASCIIZ .LIB filename

	lea	edx,WORKAREA	; Get offset in DGROUP of work area
	add	edx,LaDATA	; Plus LA of DGROUP
	mov	LaLIBNAM,edx	; Save as LA of LIB name
	mov	al,@OPEN_R	; Open as read-only
	DOSCALL @OPENF2 	; Open the .LIB file
				; Return AX = file handle
	pop	edx		; Restore
	jc	short OPEN_LIBFIL_NEXTPATH ; Jump if not found

; There's a new .LIB file in the path.  Save its full name in TXTSTR

	REGSAVE <eax,edi>	; Save for a moment

	mov	edi,LMB_TXTSTR.LMB_CURB.BOUND_NXT ; Get next available address

	lea	esi,WORKAREA	; Copy LA of workarea to source register
	add	esi,LaDATA	; Plus LA of DGROUP
	sub	ecx,esi 	; Less starting address to get length
				; (including trailing zero)
	mov	al,cl		; Copy length byte (w/trailing zero)
	dec	al		; Exclude trailing zero
	stos	AGROUP:[edi].LO ; Precede saved name with it
    rep movs	AGROUP:[edi].LO,ds:[esi].LO ; Copy to save area

	xchg	LMB_TXTSTR.LMB_CURB.BOUND_NXT,edi ; Save as next available addr
	mov	ecx,edi 	; Copy LA of starting address

	REGREST <edi,eax>	; Restore

	mov	AGROUP:[edi].PLIB_PNAM,ecx ; Save for later use
OPEN_LIBFIL_READ0:
	test	ARG_FLAG,@ARG_DBGMSG ; Displaying debugging messages?
	jz	short OPEN_LIBFIL_READ ; Jump if not

	REGSAVE <eax,edx,esi>	; Save for a moment

	lea	edx,DBGMSG_OPENLIB ; Get line start
	add	edx,LaDATA	; Plus LA of DGROUP
	DOSCALL @STROUT 	; Display it

	mov	esi,LaLIBNAM	; DS:ESI ==> library name
	call	DISP_ASCIIZ	; Display it

	lea	edx,MSG_CRLF	; Get line ending
	add	edx,LaDATA	; Plus LA of DGROUP
	DOSCALL @STROUT 	; Display it

	REGREST <esi,edx,eax>	; Restore
OPEN_LIBFIL_READ:
	mov	LIBHNDL,ax	; Save for later use
	xchg	AGROUP:[edi].PLIB_HNDL,ax ; ...

; If this .LIB file has not been opened before, read in its header.
; read in the dictionary, and save the header contents in PLIB_STR.

	cmp	ax,-1		; Izit unopened?
	jne	near ptr OPEN_LIBFIL_DONE ; Jump if not

; Read in the .LIB file header

	mov	bx,LIBHNDL	; Get the .LIB file handle
	movzx	edx,NEXTSEG	; Get next available segment
	shl	edx,4-0 	; Convert from paras to bytes
	mov	ecx,type LIBHDR_STR ; Read in the header
	DOSCALL @READF2 	; Read it in
	jc	near ptr OPEN_LIBFIL_ERRREAD ; Jump if something went wrong

	cmp	eax,ecx 	; Did we get it all?
	jc	near ptr OPEN_LIBFIL_ERRREAD ; Jump if something went wrong

	push	eax		; Pass # bytes used
	call	U32_CALC_HIGHSEG ; Calculate new HIGHSEG value

	cmp	AGROUP:[edx].LIBHDR_TYPE,@OMF_LIBHDR ; Izit a valid .LIB file?
	jne	near ptr OPEN_LIBFIL_ERRTYPE ; Jump if not

	mov	ax,AGROUP:[edx].LIBHDR_RLEN ; Get the record length
	add	ax,3		; Plus size of preceding data to get page size
	mov	AGROUP:[edi].PLIB_PGSZ,ax ; Save for later use

	mov	eax,AGROUP:[edx].LIBHDR_DOFF ; Get the dictionary offset
	mov	AGROUP:[edi].PLIB_DOFF,eax ; Save for later use

	mov	ax,AGROUP:[edx].LIBHDR_DSIZ ; Get the dictionary size
	mov	AGROUP:[edi].PLIB_DSIZ,ax ; Save for later use

	mov	al,AGROUP:[edx].LIBHDR_FLAG ; Get the flags
	mov	AGROUP:[edi].PLIB_FLAG,al ; Save for later use

	test	al,@LIBHDR_CASE ; Izit case sensitive?
	mov	al,0		; Assume so
	jnz	short @F	; Jump if so

	mov	al,20h		; Convert to lowercase with OR instruction
@@:
	mov	AGROUP:[edi].PLIB_CASE,al ; Save for later use

; Move file pointer to the dictionary

	mov	ecx,AGROUP:[edi].PLIB_DOFF ; Geyt offset of dictionary

	mov	dx,cx		; Copy low-order word
	shr	ecx,16		; Shift down high-order word so CX:DX = size
	mov	al,0		; Method is from start of file
	mov	bx,LIBHNDL	; Get the .LIB file handle
	DOSCALL @MOVFP2 	; Move the file pointer
	jc	near ptr OPEN_LIBFIL_ERRMOVE ; Jump if something went wrong (note CF=1)

; Read in the dictionary

	movzx	ecx,AGROUP:[edi].PLIB_DSIZ ; Get size of dictionary in blocks
	shl	ecx,@LIB_BLKLG2-0 ; Convert from blocks to bytes
	movzx	edx,NEXTSEG	; Get next available segment
	shl	edx,4-0 	; Convert from paras to bytes
;;;;;;; mov	bx,LIBHNDL	; Get the .LIB file handle
	DOSCALL @READF2 	; Read it in
	jc	near ptr OPEN_LIBFIL_ERRREAD ; Jump if something went wrong

	cmp	eax,ecx 	; Did we get it all?
	jc	near ptr OPEN_LIBFIL_ERRREAD ; Jump if something went wrong

	mov	AGROUP:[edi].PLIB_LaDICT,edx ; Save as LA of dictionary

; Protect the dictionary

	add	edx,ecx 	; Add length to start to get next
	add	edx,16-1	; Round up to para boundary
	shr	edx,4-0 	; Convert from bytes to paras
	mov	NEXTSEG,dx	; Protect the dictionary

; Unless told not to, read in the extended dictionary

	test	ARG_FLAG,@ARG_NOEXT ; No extended dictionaries?
	jnz	short OPEN_LIBFIL_DONE ; Jump if so

; Move file pointer to the extended dictionary

	movzx	ecx,AGROUP:[edi].PLIB_DSIZ ; Get the dictionary size in blocks
	shl	ecx,@LIB_BLKLG2-0 ; Convert from blocks to bytes
	add	ecx,AGROUP:[edi].PLIB_DOFF ; Plus offset to dictionary

	mov	dx,cx		; Copy low-order word
	shr	ecx,16		; Shift down high-order word so CX:DX = size
;;;;;;; mov	bx,LIBHNDL	; Get the .LIB file handle
	mov	al,0		; Method is from start of file
	DOSCALL @MOVFP2 	; Move the file pointer
	jc	near ptr OPEN_LIBFIL_ERRMOVE ; Jump if something went wrong (note CF=1)

; Read in the extended dictionary header

;;;;;;; mov	bx,LIBHNDL	; Get the .LIB file handle
	movzx	edx,NEXTSEG	; Get next available segment
	shl	edx,4-0 	; Convert from paras to bytes
	mov	ecx,type LIBXHDR_STR ; Read in the header
	DOSCALL @READF2 	; Read it in
	jc	near ptr OPEN_LIBFIL_ERRREAD ; Jump if something went wrong

	cmp	eax,ecx 	; Did we get it all?
	jc	near ptr OPEN_LIBFIL_ERRREAD ; Jump if something went wrong

	push	eax		; Pass # bytes used
	call	U32_CALC_HIGHSEG ; Calculate new HIGHSEG value

; Process the extended dictionary header

	cmp	AGROUP:[edx].LIBXHDR_TYPE,@OMF_LIBEXT ; Izit a valid extended dictionary?
	jne	short OPEN_LIBFIL_DONE ; Jump if not

	mov	ax,AGROUP:[edx].LIBXHDR_NMOD ; Get # modules in library
	mov	AGROUP:[edi].PLIB_NMOD,ax ; Save for later use

; Read in the extended dictionary

	movzx	ecx,AGROUP:[edx].LIBXHDR_RLEN ; Get the record length
				; excluding the three-byte header
;;;;;;; mov	bx,LIBHNDL	; Get the .LIB file handle
;;;;;;; movzx	edx,NEXTSEG	; Get next available segment
;;;;;;; shl	edx,4-0 	; Convert from paras to bytes
	DOSCALL @READF2 	; Read it in
				; Return EAX = actual # bytes read
	jc	short OPEN_LIBFIL_ERRREAD ; Jump if something went wrong

; Note that the above ECX isn't exactly right so we get less than we asked for

;;;;;;; cmp	eax,ecx 	; Did we get it all?
;;;;;;; jc	short OPEN_LIBFIL_ERRREAD ; Jump if something went wrong

	mov	AGROUP:[edi].PLIB_LaXDICT,edx ; Save for later use

; Protect the extended dictionary

	add	edx,eax 	; Add length to start to get next
	add	edx,16-1	; Round up to para boundary
	shr	edx,4-0 	; Convert from bytes to paras
	mov	NEXTSEG,dx	; Protect the dictionary
OPEN_LIBFIL_DONE:
	movzx	eax,AGROUP:[edi].PLIB_PGSZ ; Get page size
	mov	LIB_PGSZ,eax	; Save for later use

	mov	eax,AGROUP:[edi].PLIB_DOFF ; Get offset of dictionary
	mov	LIB_DOFF,eax	; Save for later use

	movzx	eax,AGROUP:[edi].PLIB_DSIZ ; Get size of dictionary in blocks
	mov	LIB_DSIZ,eax	; Save for later use

	mov	al,AGROUP:[edi].PLIB_FLAG ; Get flags
	mov	LIB_FLAG,al	; Save for later use

	mov	al,AGROUP:[edi].PLIB_CASE ; Get case converter
	mov	LIB_CASE,al	; Save for later use

	mov	eax,AGROUP:[edi].PLIB_LaDICT ; Get LA of dictionary
	mov	LIB_LaDICT,eax	; Save for later use

	mov	eax,AGROUP:[edi].PLIB_LaXDICT ; Get LA of extended dictionary
	mov	LIB_LaXDICT,eax ; Save for later use

	clc			; Mark as successful

	jmp	OPEN_LIBFIL_EXIT ; Join common exit code


COMMENT|

Unable to open .LIB file.

|

OPEN_LIBFIL_ERROPEN:
	inc	ERRCNT		; Mark as writing to error file

	inc	IWFCNT[@IWF_FAL*(type IWFCNT)] ; Count in a failure

	push	fs		; Pass DGROUP segment
	push	dword ptr (offset DGROUP:MSG_LIBOPEN) ; Pass offset of message
	call	U32_DISP_MSG	; Display the message

	jmp	short OPEN_LIBFIL_ERRCOM ; Join common error code


OPEN_LIBFIL_ERRREAD:
	inc	ERRCNT		; Mark as writing to error file

	inc	IWFCNT[@IWF_FAL*(type IWFCNT)] ; Count in a failure

	push	fs		; Pass DGROUP segment
	push	dword ptr (offset DGROUP:MSG_LIBREAD) ; Pass offset of message
	call	U32_DISP_MSG	; Display the message

	jmp	short OPEN_LIBFIL_ERRCOM ; Join common error code


OPEN_LIBFIL_ERRTYPE:
	inc	ERRCNT		; Mark as writing to error file

	inc	IWFCNT[@IWF_FAL*(type IWFCNT)] ; Count in a failure

	push	fs		; Pass DGROUP segment
	push	dword ptr (offset DGROUP:MSG_LIBTYPE) ; Pass offset of message
	call	U32_DISP_MSG	; Display the message

	jmp	short OPEN_LIBFIL_ERRCOM ; Join common error code


OPEN_LIBFIL_ERRMOVE:
	inc	ERRCNT		; Mark as writing to error file

	inc	IWFCNT[@IWF_FAL*(type IWFCNT)] ; Count in a failure

	push	fs		; Pass DGROUP segment
	push	dword ptr (offset DGROUP:MSG_LIBMOVE) ; Pass offset of message
	call	U32_DISP_MSG	; Display the message

;;;;;;; jmp	short OPEN_LIBFIL_ERRCOM ; Join common error code


OPEN_LIBFIL_ERRCOM:
	mov	eax,ds:[edi].PLIB_PNAM ; DS:EAX ==> next .LIB FID (Count, Char[])
	mov	THISOBJ_FID,eax ; Save for later use

	push	0		; Don't display THEADR (it's not valid)
	call	DISP_FIDNAME	; Display the name of the .LIB file at THISOBJ_FID

	dec	ERRCNT		; Mark as no longer writing to error file
OPEN_LIBFIL_ERR:
	stc			; Mark as not found
OPEN_LIBFIL_EXIT:
	popad			; Restore

	ret			; Return to caller

	assume	ds:nothing,es:nothing,fs:nothing,gs:nothing,ss:nothing

OPEN_LIBFIL endp		; End OPEN_LIBFIL procedure
	NPPROC	FIND_LIBSYM -- Find A Symbol In A Library File
	assume	ds:AGROUP,es:AGROUP,fs:DGROUP,gs:AGROUP,ss:nothing
COMMENT|

Find a symbol in a library file

On entry:

LaSYMFIND =	LA of symbol to find (SYM_STR)

On exit:

LIB_PGNO =	page # of .OBJ file containing symbol if found
CF	=	0 if successful
	=	1 if not

|

	pushad			; Save registers

	mov	LIB_BLKNDX,0	; Initialize block index
	mov	LIB_BLKNDX_D,0	; ...			 delta
	mov	LIB_BLKOFF,0	; ...		   offset
	mov	LIB_BLKOFF_D,0	; ...			 delta

	mov	esi,LaSYMFIND	; Get LA of symbol to find (SYM_STR)
	mov	esi,AGROUP:[esi].SYM_PNAM ; Get LA of symbol (Count, Char[])

COMMENT|

Hash the symbol

Note that the hash algorithm reads chars forwards beginning with the
symbol length, ending with the next to the last char (but not the last
char), and reads chars backwards beginning with the last char, ending
with the first char (but not the symbol length).

|

	movzx	ecx,AGROUP:[esi].LO ; Get symbol length
	lea	edi,AGROUP:[esi+ecx] ; Point to last char
FIND_LIBSYM_NEXT:
	xor	eax,eax 	; Zero to use as dword
	lods	AGROUP:[esi].LO ; Get and skip over next char
	or	al,LIB_CASE	; Convert AL to lowercase if appropriate

	mov	edx,LIB_BLKNDX	; Get current block index
	rol	dx,2		; Rotate to the left
	xor	edx,eax 	; XOR in char
	mov	LIB_BLKNDX,edx	; Save for later use

	mov	edx,LIB_BLKOFF_D ; Get current block offset delta
	ror	dx,2		; Rotate to the right
	xor	edx,eax 	; XOR in char
	mov	LIB_BLKOFF_D,edx ; Save for later use

	mov	al,AGROUP:[edi] ; Get last char
	or	al,LIB_CASE	; Convert AL to lowercase if appropriate
	dec	edi		; Back up to prev char

	mov	edx,LIB_BLKOFF	; Get current block offset
	ror	dx,2		; Rotate to the right
	xor	edx,eax 	; XOR in char
	mov	LIB_BLKOFF,edx	; Save for later use

	mov	edx,LIB_BLKNDX_D ; Get current block index delta
	rol	dx,2		; Rotate to the left
	xor	edx,eax 	; XOR in char
	mov	LIB_BLKNDX_D,edx ; Save for later use

	loop	FIND_LIBSYM_NEXT ; Jump if more chars in symbol

; Adjust Block index modulo # blocks in dictionary

	xor	edx,edx 	; Zero to use EDX:EAX as qword
	mov	eax,LIB_BLKNDX	; Get the block index
	div	LIB_DSIZ	; Divide by # blocks in dictionary
				; EAX = quotient
				; EDX = remainder
	mov	LIB_BLKNDX,edx	; Save the remainder

; Adjust Block index delta modulo # blocks in dictionary
; If this value is zero, make it a one

	xor	edx,edx 	; Zero to use EDX:EAX as qword
	mov	eax,LIB_BLKNDX_D ; Get the block index delta
	div	LIB_DSIZ	; Divide by # blocks in dictionary
				; EAX = quotient
				; EDX = remainder
	cmp	edx,1		; Remainder zero?
	adc	edx,0		; If so, use delta of 1

	mov	LIB_BLKNDX_D,edx ; Save the remainder

; Adjust Block offset modulo # buckets

	xor	edx,edx 	; Zero to use EDX:EAX as qword
	mov	eax,LIB_BLKOFF	; Get the block offset
	div	LIB_BUCK	; Divide by # buckets
				; EAX = quotient
				; EDX = remainder
	mov	LIB_BLKOFF,edx	; Save the remainder

; Adjust Block offset delta modulo # buckets

	xor	edx,edx 	; Zero to use EDX:EAX as qword
	mov	eax,LIB_BLKOFF_D ; Get the block offset
	div	LIB_BUCK	; Divide by # buckets
				; EAX = quotient
				; EDX = remainder
	cmp	edx,1		; Remainder zero?
	adc	edx,0		; If so, use delta of 1

	mov	LIB_BLKOFF_D,edx ; Save the remainder

; Lookup the symbol in the dictionary

	mov	eax,LIB_DSIZ	; Get size of dictionary in blocks
	mov	LIB_BLKCNT,eax	; Save for later use
FIND_LIBSYM_NEXTBLK:
	mov	ebx,LIB_BLKNDX	; Get the block # to search
	shl	ebx,@LIB_BLKLG2-0 ; Convert from blocks to bytes
	add	ebx,LIB_LaDICT	; Plus LA of dictionary

	mov	ecx,LIB_BUCK	; Get # buckets in a block
FIND_LIBSYM_NEXTOFF:

; Using the block offset into the buckets, get the index of the symbol

	mov	eax,LIB_BLKOFF	; Get block offset (<37)
	xlat	AGROUP:[ebx]	; Get the word offset in the block

	shl	eax,1-0 	; Convert from words to bytes
	jz	short FIND_LIBSYM_LOOPOFF ; Jump if it's empty

	lea	esi,AGROUP:[eax+ebx] ; Point to symbol (Count, Char[])

	mov	edi,LaSYMFIND	; Get LA of symbol to find (SYM_STR)
	UNCURB	edi,SYMBOL	; Ensure within current bounds
	mov	edi,AGROUP:[edi].SYM_PNAM ; Get LA of symbol (Count, Char[])

	push	ecx		; Save for a moment
	UNCURB	edi,TXTSTR	; Ensure within current bounds
	movzx	ecx,AGROUP:[edi].LO ; Get symbol length
	inc	ecx		; Count it in
   repe cmps	AGROUP:[esi].LO,AGROUP:[edi].LO
	pop	ecx		; Restore
	je	short FIND_LIBSYM_DONE ; Jump if it matches
FIND_LIBSYM_LOOPOFF:

; Add in the block offset delta

	mov	eax,LIB_BLKOFF	; Get the block offset
	add	eax,LIB_BLKOFF_D ; Add in the block offset delta

	cmp	eax,LIB_BUCK	; Did we wrap?
	jb	short @F	; Jump if not

	sub	eax,LIB_BUCK	; Back to the start
@@:
	mov	LIB_BLKOFF,eax	; Save the remainder

	loop	FIND_LIBSYM_NEXTOFF ; Jump if there's more buckets

; We're back at the start:  try the next block

	mov	eax,LIB_BLKNDX	; Get the in block index
	add	eax,LIB_BLKNDX_D ; Add in the block index delta

	cmp	eax,LIB_DSIZ	; Did we wrap?
	jb	short @F	; Jump if not

	sub	eax,LIB_DSIZ	; Back to the start
@@:
	mov	LIB_BLKNDX,eax	; Save remainder

	dec	LIB_BLKCNT	; Count out another block
	jnz	near ptr FIND_LIBSYM_NEXTBLK ; Jump if more blocks to check

	stc			; Mark as in error

	jmp	short FIND_LIBSYM_EXIT ; Join common exit code

FIND_LIBSYM_DONE:
	movzx	eax,AGROUP:[esi].ELO ; Get the page #
	mov	LIB_PGNO,eax	; Save for later use

	test	ARG_FLAG,@ARG_DBGMSG ; Displaying debugging messages?
	jz	short FIND_LIBSYM_XDBG ; Jump if not

	pushad			; Save for a moment

	mov	eax,LIB_PGNO	; Get the page #
	lea	edi,DBGMSG_FINDSYM1 ; DGROUP:EDI ==> output format area
	add	edi,LaDATA	; Plus LA of DGROUP
	call	DW2HEX		; Convert AX to hex at ES:EDI

	lea	edx,DBGMSG_FINDSYM ; Get line start
	add	edx,LaDATA	; Plus LA of DGROUP
	DOSCALL @STROUT 	; Display it

	mov	edx,LaSYMFIND	; Get LA of symbol to find (SYM_STR)
	UNCURB	edx,SYMBOL	; Ensure within current bounds
	mov	edx,AGROUP:[edx].SYM_PNAM ; Get LA of symbol (Count, Char[])
	movzx	ecx,ds:[edx].LO ; Get the count
	inc	edx		; Skip over it
	mov	bx,@STD_OUT	; Send to standard output
	DOSCALL @WRITF2 	; Write it out

	lea	edx,MSG_CRLF	; Get line ending
	add	edx,LaDATA	; Plus LA of DGROUP
	DOSCALL @STROUT 	; Display it

	popad			; Restore
FIND_LIBSYM_XDBG:
	clc			; Mark as successful
FIND_LIBSYM_EXIT:
	popad			; Restore

	ret			; Return to caller

	assume	ds:nothing,es:nothing,fs:nothing,gs:nothing,ss:nothing

FIND_LIBSYM endp		; End FIND_LIBSYM procedure
	NPPROC	LINK_LIBNAM -- Link In A New Library Name
	assume	ds:AGROUP,es:AGROUP,fs:DGROUP,gs:AGROUP,ss:nothing
COMMENT|

Link in a new library name

Remember to update DISPLIB_ALLOC.

On entry:

DS:ESI	==>	ASCII name
ECX	=	length of name

On exit:

DS:ESI	==>	next char after ASCII name

|

	REGSAVE <eax,ebx,ecx,edi> ; Save registers

	mov	ebx,LMB_TXTSTR.LMB_CURB.BOUND_NXT ; Get next available address

	cmp	LaLIB_1ST,0	; Izit initialized?
	jne	short @F	; Jump if so

	mov	LaLIB_1ST,ebx	; Save for later use
	mov	LaLIB_LAST,ebx	; ...
@@:
	mov	eax,ebx 	; Copy segment of new entry
	xchg	eax,LaLIB_LAST	; Mark as new last entry

	mov	AGROUP:[eax].PLIB_NEXT,ebx ; Point it to this entry

	mov	AGROUP:[ebx].PLIB_NEXT,-1 ; Mark as no next entry
	mov	AGROUP:[ebx].PLIB_HNDL,-1 ; Mark as unopened
	mov	AGROUP:[ebx].PLIB_LaXDICT,-1 ; Mark as not present
	mov	eax,type PLIB_STR ; Get size of struc
	add	eax,ebx 	; Add to get LA of save area for libname
	mov	AGROUP:[ebx].PLIB_PNAM,eax ; Save as LA of libname (Count, Char[])
	mov	edi,eax 	; ES:EDI ==> start of save area

	REGSAVE <ecx,esi>	; Save for a moment

	mov	ebx,edi 	; Save offset of length byte
	inc	edi		; Skip over length byte
    rep movs	AGROUP:[edi].LO,ds:[esi].LO ; Copy to save area
	mov	eax,esi 	; Copy ending source address

	REGREST <esi,ecx>	; Restore

	push	dword ptr (offset DGROUP:EXT_LIB) ; Pass offset in DGROUP of def ext
	call	PMCHECK_DEFEXT	; Append the def ext of DS:ESI len ECX to ES:EDI
				; if none present, ECX & EDI updated
	mov	AGROUP:[ebx].LO,cl ; Precede saved name with length byte
	mov	esi,eax 	; Restore as ending source address on return

	mov	al,0		; Get ASCIIZ terminator
	stos	AGROUP:[edi].LO ; Terminate it

	mov	LMB_TXTSTR.LMB_CURB.BOUND_NXT,edi ; Save as next available addr

	REGREST <edi,ecx,ebx,eax> ; Restore

	ret			; Return to caller

	assume	ds:nothing,es:nothing,fs:nothing,gs:nothing,ss:nothing

LINK_LIBNAM endp		; End LINK_LIBNAM procedure
	NPPROC	PMCHECK_DEFEXT -- Check On Default Extension
	assume	ds:nothing,es:nothing,fs:DGROUP,gs:nothing,ss:nothing
COMMENT|

Check on the default extension, PM version

Remember to update CHECK_DEFEXT.

On entry:

DS:ESI	==>	FID
ES:EDI	==>	output area
ECX	=	byte count

On exit:

ES:EDI	==>	next character after extension (default or not)
ECX	=	new length if default extension appended

|

PMCHECK_DEFEXT_STR struc

	dd	?		; Caller's EBP
	dd	?		; ...	   EIP
PMCHECK_DEFEXT_OFF dd ? 	; Offset in DGROUP of the default extension

PMCHECK_DEFEXT_STR ends

	push	ebp		; Prepare to address the stack
	mov	ebp,esp 	; Hello, Mr. Stack

	REGSAVE <eax,edx,esi>	; Save registers

; Search backwards through DS:ESI for the extension marker

	add	esi,ecx 	; Add to get next address
	mov	edx,ecx 	; Save original length
PMCHECK_DEFEXT_NEXT:
	dec	esi		; Back off to previous byte
	mov	al,ds:[esi]	; Get the next byte

	cmp	al,'.'          ; Izit an extension separator?
	je	short PMCHECK_DEFEXT_EXIT ; Jump if so (no default extension)

	cmp	al,'\'          ; Izit a path separator?
	je	short PMCHECK_DEFEXT_COPY ; Jump if so (use default extension)

	loop	PMCHECK_DEFEXT_NEXT ; Jump if more bytes to check
PMCHECK_DEFEXT_COPY:
;;;;;;; mov	DEFEXT_VEC.VSEG,es ; Save for later use
;;;;;;; mov	DEFEXT_VEC.VOFF,di ; ...
	mov	esi,[ebp].PMCHECK_DEFEXT_OFF ; Get def ext offset in DGROUP

	mov	ecx,4		; Get length of ...
	add	edx,ecx 	; Count in the default extension
    rep movs	es:[edi].LO,DGROUP:[esi].LO ; Copy default extension
PMCHECK_DEFEXT_EXIT:
	mov	ecx,edx 	; Return length

	REGREST <esi,edx,eax>	; Restore

	pop	ebp		; Restore

	ret	4		; Return to caller, popping argument

	assume	ds:nothing,es:nothing,fs:nothing,gs:nothing,ss:nothing

PMCHECK_DEFEXT endp		; End PMCHECK_DEFEXT procedure

CODE	ends			; End CODE segment

	MEND			; End QLNK_LIB module
