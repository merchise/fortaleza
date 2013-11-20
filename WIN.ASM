; Turbo Pascal 6.0 example
; Assembler include file for WIN.PAS unit
; Copyright (c) 1989,90 by Borland International, Inc.

        TITLE   WIN

        LOCALS  @@

; Coordinate record

X               EQU     (BYTE PTR 0)
Y               EQU     (BYTE PTR 1)

; BIOS workspace equates

CrtMode         EQU     (BYTE PTR 49H)
CrtWidth        EQU     (BYTE PTR 4AH)

DATA    SEGMENT WORD PUBLIC

; Externals from CRT unit

        EXTRN   CheckSnow:BYTE,WindMin:WORD,WindMax:WORD

DATA    ENDS

CODE    SEGMENT BYTE PUBLIC

        ASSUME  CS:CODE,DS:DATA

; procedure WriteStr(X, Y: Byte; S: String; Attr: Byte);

        PUBLIC  WriteStr

WriteStr:

        PUSH    BP
        MOV     BP,SP
        LES     BX,[BP+8]
        MOV     CL,ES:[BX]
        MOV     SI,OFFSET CS:CrtWriteStr
        CALL    CrtWrite
        POP     BP
        RETF    10

; procedure WriteChar(X, Y, Count: Byte; Ch: Char; Attr: Byte);

        PUBLIC  WriteChar

WriteChar:

        PUSH    BP
        MOV     BP,SP
        MOV     CL,[BP+10]
        MOV     SI,OFFSET CS:CrtWriteChar
        CALL    CrtWrite
        POP     BP
        RETF    10

; procedure FillWin(Ch: Char; Attr: Byte);

        PUBLIC  FillWin

FillWin:

        MOV     SI,OFFSET CS:CrtWriteChar
        JMP     SHORT CommonWin

; procedure ReadWin(var Buf);

        PUBLIC  ReadWin

ReadWin:

        MOV     SI,OFFSET CS:CrtReadWin
        JMP     SHORT CommonWin

; procedure WriteWin(var Buf);

        PUBLIC  WriteWin

WriteWin:

        MOV     SI,OFFSET CS:CrtWriteWin

; Common FillWin/ReadWin/WriteWin routine

CommonWin:

        PUSH    BP
        MOV     BP,SP
        XOR     CX,CX
        MOV     DX,WindMin
        MOV     CL,WindMax.X
        SUB     CL,DL
        INC     CX
@@1:    PUSH    CX
        PUSH    DX
        PUSH    SI
        CALL    CrtBlock
        POP     SI
        POP     DX
        POP     CX
        INC     DH
        CMP     DH,WindMax.Y
        JBE     @@1
        POP     BP
        RETF    4

; Write string to screen

CrtWriteStr:

        PUSH    DS
        MOV     AH,[BP+6]
        LDS     SI,[BP+8]
        INC     SI
        JC      @@4
@@1:    LODSB
        MOV     BX,AX
@@2:    IN      AL,DX
        TEST    AL,1
        JNE     @@2
        CLI
@@3SI,OFFSET CS:CrtWriteChar
        CALL    CrtWrite
  e7rLFs r  MOV     AH,[BP+6]
        LDS     SI,[BP+8]
    S
;qE S
       POP     BPTAL  DH
      Doe     PUSH    JNE     @@2
        CLI
kb AH Y         SI,[BP+8]
    S
;qE S
       POP     BPTAL  DH
      Doe      POP     BPTAL  DH
      Doe     PUSH    JNE     @@2
        CLI
kb AH Y         SI,[BP+8]
    S
;qE S
       POP     BPTAL  DH
      Doe      POP     BPTAL  DH
      Doe     PUSH    JNE     @@2
        CLI
kb AH Y         SI,[BP+ T
      Doe   BPTATAL  DHSrXS     PTa o72E:nHL rLFs r  MOVS rLFTAL  DHtWriteChar c: String TL    CrtWri TcIa B   @@2rf  S,aktr )(C      CrtWri T  z
4z

kb AH YttVrcA cIa BeLN TAL  DHSrHT TAL  DHSo7L  DHSrHT 
      Doe   BP     PUSH    JNE     @@2
      BE o72      Doe      POP     BPTAL  T@Arcre(C           Doe      TES     c       Doe     4R 
,1 c       Doe     4R 
,1 c       Doe  rS:4L@4 SJi @@2r r  SN k     mnPTAL  DH
      Doe     PUSH    JNE     @@2
           1 1    DH
  oe     4
okD 4R 
,1SI,[BP iC S,1SI       D@2
       ASaN:yL
esTAL  DHSo7L  DHSrHT 
      Doe   BP TXr (4A   @@2
   Tc4@z
o