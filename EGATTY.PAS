unit EGATTY;

interface

  uses
    Crt, Objects, Win, TeleType,HistTTY;

  type
    PEGATTY = ^TEGATTY;
    TEGATTY =
      object( THistTTY )
	constructor Init( R: TRect);
	destructor  Done;				  virtual;
	procedure   Page;				  virtual;
	procedure   PaperTop;				  virtual;
	procedure   PaperBottom;			  virtual;
	procedure   SendLeftMargin;			  virtual;
	procedure   SendRightMargin;			  virtual;
      end;

  const
    len = 255;
    Chr : array [char, 1..14] of char = ( {$i FortFnt.Def} );

implementation

  uses
    TTY;

  function RndLeftCh:char;
    const
      count = 20;
      PosibleChars:array[1..count] of char='€€€€€€€€€€€€€·„„Â·„Â';
    begin
      RndLeftCh := PosibleChars[random(count)+1];
    end;

  function RndRightCh:char;
    const
      count = 20;
      PosibleChars:array[1..count] of char='€€€€ÍÍÍ€€€€€‚‚‰‰‰ÊÊÊ';
    begin
      RndRightCh := PosibleChars[random(count)+1];
    end;

  procedure SetEGARes; assembler;
    asm
      mov       ax, $1201
      mov       bl, $30
      int       $10

      mov       ax, $0003
      int       $10
    end;

  procedure SetVGARes; assembler;
    asm
      mov	ax, $1202
      mov       bl, $30
      int       $10

      mov       ax, $0003
      int       $10
    end;


procedure EnableRAMAccessing;		near;   assembler;
  asm
	cli
	mov	DX, 03C4h
	mov	AX, 0402h
	out	DX, AX
	mov	AX, 0704h
	out	DX, AX
	mov	DL, 0CEh
	mov	AX, 0204h
	out	DX, AX
	mov	AX, 0005h
	out	DX, AX
	mov	AX, 0006h
	out	DX, AX
  end; { EnableRAMAccessing }

procedure DisableRAMAccessing;		near;   assembler;
  asm
	mov	DX, 03C4h
	mov	AX, 0302h
	out	DX, AX
	mov	AX, 0304h
	out	DX, AX
	mov	DL, 0CEh
	mov	AX, 0004h
	out	DX, AX
	mov	AX, 1005h
	out	DX, AX
	mov	AX, 0E06h
	out	DX, AX
	sti
  end; { DisableRAMAccessing }

  procedure InstallChars;
    type
      PCharTable = ^TCharTable;
      TCharTable = array[char, 0..31] of byte;
    var
      aux : PCharTable;
      i   : char;
    begin
      if IsEGA
	then
          begin
	    asm
	      push  BP
	      mov   AX, $1201
	      mov   BL, $30;
	      int   $10
	      mov   AX, $0003
	      int   $10
	    end;
            EnableRAMAccessing;
            {$ifndef msdos}
            aux := ptr(SegA000, 0);
            {$else}
            aux := ptr($A000, 0);
            {$endif}
            for i := #0 to #255 do
              move(chr[i], aux^[i], sizeof(chr[i]));
            DisableRAMAccessing
          end
    end;


  { EGATTY }

  destructor TEGATTY.Done;
    begin
      SetVGARes;
      THistTTY.Done
    end;

  constructor TEGATTY.Init;
    begin
      InstallChars;
      THistTTY.Init(R);
      SetMaxStrLen(Bounds.B.X -Bounds.A.X - length(prompt) - 4);
    end;

  procedure TEGATTY.PaperTop;
    const
      header = 'la fortaleza II';
    begin
      SetMarginState(mgTop);
      SendNewLine;
      SetMarginState(mgMiddle);
      SendNewLine;
      SendNewLine;
      {
      writeStr( Bounds.B.x - Bounds.A.x - length(header) - 2, whereY, header, cGround );
      }
    end;

  procedure TEGATTY.Page;
    begin
      {
      SetColor;
      SendNewLine;
      writechar( 2, whereY, Bounds.B.x - Bounds.A.x - 3, '˙', cHighText );
      SendNewLine;
      ClrToEol;
      }
    end;

  procedure TEGATTY.SendLeftMargin;
    begin
      case mgState of
	mgTop:	  writeStr( 1, whereY, 'É', cInv);
	mgMiddle: writeStr(1, whereY, RndLeftCh, cInv);
      end;
    end;

  procedure TEGATTY.SendRightMargin;
    begin
      case mgState of
	mgTop:	  writeStr( Bounds.B.x - 2, whereY, 'ÑÖ', cInv );
	mgMiddle: writeStr( Bounds.B.x - 3, whereY, RndRightCh+'  ', cInv );
      end;
    end;

  procedure TEGATTY.PaperBottom;
    const
      paper : string[30] = 'äãåçéç€çéåèê€€éãåçéê€çéçéãåçéå';
    var
      i : byte;
      j : byte;
    begin
      BreakSound;
      SendNewLine;
      j := succ(random(30));
      for i := 1 to Bounds.B.x - Bounds.A.x - 1 do
	begin
	  writechar( i, whereY, 1, paper[j], $7 );
	  if j < 30
	    then inc(j)
	    else j := 1
	end;
    end;

end.
