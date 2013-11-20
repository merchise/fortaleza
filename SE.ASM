; *******************************************************
; *							*
; *	MACROS						*
; *							*
; *******************************************************

	LOCALS	@@

; Public variable definition macro

VAR MACRO Symbol,SType,Count
  PUBLIC Symbol
  Symbol LABEL SType
  IF Count
    DB SType * Count DUP(?)
  ENDIF
ENDM

; Parameter definition macro

ARG MACRO Symbol,SType,Count
  LOCAL Offset
  @AP = @AP + SType * Count
  Offset = @AP
  Symbol EQU (SType PTR [BP+@AF-Offset])
ENDM

@AP = 0
@AF = 0

; Local variables definition macro

LOC MACRO Symbol,SType,Count
  LOCAL Offset
  @LP = @LP + SType * Count
  Offset = @LP
  Symbol EQU (SType PTR [BP+@LF-Offset])
ENDM

@LP = 0
@LF = 0

; Stack frame modifiers

sfFar		EQU	01H		;FAR frame
sfMarkBP	EQU	02H		;Make saved BP odd
sfSaveDS	EQU	04H		;Save DS at [BP-2]

; Stack frame types

DEFAULT@	EQU	0
NEAR@		EQU	0
FAR@		EQU	sfFar
WINFAR		EQU	sfFar

; Entry code generation macro

ENTRY MACRO FrameType
  IFB <FrameType>
    @SF = DEFAULT@
  ELSE
    IFIDNI <FrameType>,<NEAR>
      @SF = NEAR@
    ELSE
      IFIDNI <FrameType>,<FAR>
        @SF = FAR@
      ELSE
        @SF = FrameType
      ENDIF
    ENDIF
  ENDIF
  IF @SF  AND  sfMarkBP
    INC BP
  ENDIF
  PUSH BP
  MOV BP,SP
  IF @SF  AND  sfFar
    @AF = @AP + 6
  ELSE
    @AF = @AP + 4
  ENDIF
  IF @SF  AND  sfSaveDS
    PUSH DS
    @LF = -2
  ELSE
    @LF = 0
  ENDIF
  IF @LP
    SUB SP,@LP
  ENDIF
ENDM

; Exit code generation macro

EXIT MACRO ArgSize
  IF @LF  -  @LP
    MOV SP,BP
  ENDIF
  POP BP
  IF @SF  AND  sfMarkBP
    DEC BP
  ENDIF
  IFNB <ArgSize>
    @AP = ArgSize
  ENDIF
  IF @SF  AND  sfFar
    RETF @AP
  ELSE
    RETN @AP
  ENDIF
  @AP = 0
  @LP = 0
ENDM

; *******************************************************
; *							*
; *	EQUATES						*
; *							*
; *******************************************************

; 10-Byte record

b0		EQU	(BYTE PTR 0)
b1		EQU	(BYTE PTR 1)
b2		EQU	(BYTE PTR 2)
b3		EQU	(BYTE PTR 3)
b4		EQU	(BYTE PTR 4)
b5		EQU	(BYTE PTR 5)
b6		EQU	(BYTE PTR 6)
b7		EQU	(BYTE PTR 7)
b8		EQU	(BYTE PTR 8)
b9		EQU	(BYTE PTR 9)

; 5-Word record

w0		EQU	(WORD PTR 0)
w2		EQU	(WORD PTR 2)
w4		EQU	(WORD PTR 4)
w6		EQU	(WORD PTR 6)
w8		EQU	(WORD PTR 8)

; Pointer record

ofs		EQU	(WORD PTR 0)
seg		EQU	(WORD PTR 2)

; 8087 status word masks

mIE		EQU	0001H
mDE		EQU	0002H
mZE		EQU	0004H
mOE		EQU	0008H
mUE		EQU	0010H
mPE		EQU	0020H
mC0		EQU	0100H
mC1		EQU	0200H
mC2		EQU	0400H
mC3		EQU	4000H

; ASCII equates

bell		EQU	07H
bs		EQU	08H
tab		EQU	09H
lf		EQU	0AH
cr		EQU	0DH
eof		EQU	1AH
esc		EQU	1BH
del		EQU	7FH

; DOS interrupt vector number

DOS		EQU	21H

; DOS function codes

dosSetDrive	EQU	0EH
dosGetDrive	EQU	19H
dosSetDTA	EQU	1AH
dosSetInt	EQU	25H
dosParse	EQU	29H
dosGetDate	EQU	2AH
dosSetDate	EQU	2BH
dosGetTime	EQU	2CH
dosSetTime	EQU	2DH
dosVersion	EQU	30H
dosGetInt	EQU	35H
dosCreateDir	EQU	39H
dosRemoveDir	EQU	3AH
dosSetDir	EQU	3BH
dosCreate	EQU	3CH
dosOpen		EQU	3DH
dosClose	EQU	3EH
dosRead		EQU	3FH
dosWrite	EQU	40H
dosDelete	EQU	41H
dosSeek		EQU	42H
dosAttrib	EQU	43H
dosIOCtl	EQU	44H
dosGetDir	EQU	47H
dosSetMem	EQU	4AH
dosExec		EQU	4BH
dosExit		EQU	4CH
dosGetExit	EQU	4DH
dosFindFirst	EQU	4EH
dosSetPSP	EQU	50H
dosGetPSP	EQU	51H
dosMakePSP	EQU	55H
dosRename	EQU	56H
dosFDate	EQU	57H

; Program segment prefix variables

pspMemTop	EQU	(WORD PTR 02H)
pspFileTab	EQU	(BYTE PTR 18H)
pspEnvSeg	EQU	(WORD PTR 2CH)
pspFCB1		EQU	(BYTE PTR 5CH)
pspFCB2		EQU	(BYTE PTR 6CH)
pspCmdLine	EQU	(BYTE PTR 80H)

; Free-list memory record layout

mNext		EQU	(DWORD PTR 0)
mSize		EQU	(DWORD PTR 4)
mRecSize	EQU	8

; File record layout

fHandle		EQU	(WORD PTR 0)
fMode		EQU	(WORD PTR 2)
fBufSize	EQU	(WORD PTR 4)
fPrivate	EQU	(WORD PTR 6)
fBufPos		EQU	(WORD PTR 8)
fBufEnd		EQU	(WORD PTR 10)
fBufPtr		EQU	(DWORD PTR 12)
fOpenProc	EQU	(DWORD PTR 16)
fInOutProc	EQU	(DWORD PTR 20)
fFlushProc	EQU	(DWORD PTR 24)
fCloseProc	EQU	(DWORD PTR 28)
fUserData	EQU	(BYTE PTR 32)
fName		EQU	(BYTE PTR 48)
fBuffer		EQU	(BYTE PTR 128)
fRecSize	EQU	256

; fMode values

fmClosed	EQU	0D7B0H
fmInput		EQU	0D7B1H
fmOutput	EQU	0D7B2H
fmInOut		EQU	0D7B3H

; Overlay header record

ovSignature	EQU	(WORD PTR 0)
ovSaveReturn	EQU	(WORD PTR 2)
ovFilePos	EQU	(WORD PTR 4)
ovCodeSize	EQU	(WORD PTR 8)
ovFixupSize	EQU	(WORD PTR 10)
ovJumpCount	EQU	(WORD PTR 12)
ovLink		EQU	(WORD PTR 14)
ovSegment	EQU	(WORD PTR 16)
ovRetryCount	EQU	(WORD PTR 18)
ovNext		EQU	(WORD PTR 20)
ovEmsPage	EQU	(WORD PTR 22)
ovEmsOffset	EQU	(WORD PTR 24)
ovUserData	EQU	(BYTE PTR 26)
ovVectors	EQU	(BYTE PTR 32)
ovRecSize	EQU	32