unit TeleType;

interface

  uses
    Crt, Objects, Win;

  const
    stSending   = 1;
    stReceiving = 2;
    stReading   = 3;
    stStoring   = 4;
    stWaiting   = 5;
    stThinking  = 6;

    cMonoGrnd	    = $70;
    cMonoInv	    = $07;
    cMonoSBar	    = $0F;
    cMonoLBars	    = $70;
    cMonoHigh	    = $70;
    cMonoMenuBar    = $07;
    cMonoMenuBorder = $70;

    cColorGrnd	     = $70;
    cColorInv	     = $07;
    cColorSBar	     = $1F;
    cColorLBars      = $3F;
    cColorHigh	     = $7F;
    cColorMenuBar    = $4f;
    cColorMenuBorder = $74;

    cWhiteGrnd	     = $F0;
    cWhiteInv	     = $07;
    cWhiteSBar	     = $0f;
    cWhiteLBars      = $70;
    cWhiteHigh	     = $7f;
    cWhiteMenuBar    = $07;
    cWhiteMenuBorder = $70;

    mgTop	= 01;
    mgMiddle	= 00;
    mgBottom	= 02;

  type
    PTeleT = ^TeleT;
    TeleT  =
      object( TObject )
	att   : byte;
	state : word;
	Bounds: TRect;
	Screen: TRect;
	break : PString;
	mgState: byte;
	constructor Init( R: TRect );
	destructor  Done;			 virtual;
	procedure   StartTransmition;	         virtual;
	procedure   ClrToEol;		         virtual;
	procedure   SetMarginState(aState:byte); virtual;
	procedure   SendLeftMargin;		 virtual;
	procedure   SendRightMargin;		 virtual;
	procedure   SendMargins;		 virtual;
	procedure   SendNewLine;		 virtual;
	procedure   Send  ( s: string );	 virtual;
	procedure   Sendln( s: string );	 virtual;
	function    Receive: string;		 virtual;
	procedure   SetState( st: word );	 virtual;
	procedure   Draw;			 virtual;
	procedure   Clear;			 virtual;
	procedure   NewPaper;			 virtual;
	procedure   Page;			 virtual;
	procedure   PaperTop;			 virtual;
	procedure   PaperBottom;		 virtual;
	procedure   BreakSound; 		 virtual;
	procedure   Color( c: byte );
	procedure   SetColor;
      end;

  const
    cGround     : byte = cColorGrnd;
    cInv        : byte = cColorInv;
    cStatusBar  : byte = cColorSBar;
    cLimitBars  : byte = cColorLBars;
    cHighText   : byte = cColorHigh;
    cMenuBorder : byte = cColorMenuBorder;
    cMenuBar    : byte = cColorMenuBar;

    sDelay    : byte =	2;
    sSound    : byte = 50;

    prompt     = #16#32;

  procedure NoCursor;
  procedure NormalCursor;
  procedure BlockCursor;
  function  ColorAdapter: boolean;
  procedure SetSpeed( s: byte );
  procedure Silent;

  const
    Visible: boolean = true;

implementation

  { TeleT }

  constructor TeleT.Init( R: TRect );
    var
      s: string;
      i: byte;
    begin
      TObject.Init;
      Bounds := R;
      Screen.Assign( lo(windmin) + 1, hi(windmin) + 1, lo(windmax), hi(windmax) + 1);
    end;

  destructor TeleT.Done;
    begin
      with Screen do
        window( A.x, A.y, B.x, B.y );
      TObject.Done;
    end;

  procedure TeleT.StartTransmition;
    begin
      Color( cGround );
      SetState( stWaiting );
      NewPaper;
    end;

  procedure TeleT.SetMarginState;
    begin
      mgState := aState;
    end;

  procedure TeleT.SendLeftMargin;
    begin
      writeStr( 1, whereY, ' ', cGround);
    end;

  procedure TeleT.SendRightMargin;
    begin
      writeStr( Bounds.B.x - 1, whereY, ' ', cGround );
    end;

  procedure TeleT.SendMargins;
     begin
       SendLeftMargin;
       SendRightMargin;
     end;

  procedure TeleT.SendNewLine;
    begin
      writeln;
      SendMargins;
      gotoXY(2,WhereY);
      ClrToEol
    end;

  procedure TeleT.ClrToEol;
    begin
      writechar( WhereX, whereY, Bounds.B.x - Bounds.A.x - WhereX - 1, ' ', cGround );
    end;

  procedure TeleT.Sendln( s: string );
    begin
      Send( s );
      SendNewLine;
    end;

  procedure TeleT.Send( s: string );
    var
      i: byte;
    begin
{
      if state <> stSending
        then SetState( stSending );
}
      for i := 1 to length(s) do
        begin
          SetColor;
{         writechar( whereX, whereY, 1, s[i], 11 );
	  if s[i] <> ' '
	    then delay( sDelay );
}         if WhereX = 1
            then gotoXY(2,WhereY);
          write( s[i] );
          if keypressed
            then
              if readkey = #32
                then
                  begin
                    SetState( stWaiting );
                    repeat until readkey <> #0;
                    SetState( stSending );
                  end;
          if (i mod 3 = 0) and (s[i] <> ' ')
            then
              begin
                sound( sSound );
                delay( sDelay div 2 );
                nosound
              end;
        end;
    end;

  function TeleT.Receive: string;
    var
      s: string;
    begin
      Color( cHighText );
      if state <> stReceiving
        then SetState( stReceiving );
      SetColor;
      SendLeftMargin;
      Send( prompt );
      Color( cHighText );
      SetColor;
      readln( s );
      Receive := s;
      SendNewLine;
      Color( cGround );
    end;

  procedure TeleT.SetState( st: word );
    begin
      state := st;
      Draw
    end;

  procedure TeleT.Draw;
    var
      x, y, attr : byte;
      s 	 : string;
    begin
      x := whereX;
      y := whereY;
      with Screen do
        window( A.x, A.y, B.x, B.y );
{
      case state of
	stSending  : s := '  Escribiendo...';
	stReceiving: s := '  Recibiendo... ';
	stReading  : s := '  Cargando...   ';
	stStoring  : s := '  Almacenando...';
	stWaiting  : s := '  Esperando...  ';
	stThinking : s := '  Trabajando... ';
      end;
}
      if ColorAdapter
	then attr := $38
	else attr := $3;
      WriteChar( 1, Screen.B.y, 80, '≤', attr );
      WriteChar( 1, Screen.A.y, 80, '≤', attr );
{
      writechar( Bounds.A.x - 1, Bounds.B.y + 1, Bounds.B.x - Bounds.A.x + 3, ' ', cStatusBar );
      writeStr( Bounds.A.x - 1, Bounds.B.y + 1, s, cStatusBar );
}
      with Bounds do
	window( A.x, A.y, B.x, B.y );
      gotoxy( x, y );
    end;

  procedure TeleT.Clear;
    var
      i: byte;
    begin
      PaperBottom;
      SetMarginState( mgBottom );
      Color( 0 );
      for i := 1 to Bounds.B.y - Bounds.A.y + 1 do
        begin
          writeln;
          delay( 2 );
        end;
      Color( cGround )
    end;

  procedure TeleT.NewPaper;
    begin
      gotoxy( 1, Bounds.B.y - Bounds.A.y + 1 );
      SetColor;
      PaperTop;
      Page;
      SendMargins;
      ClrToEol;
    end;

  procedure TeleT.Page;
    begin
      SetColor;
      SendNewLine;
      ClrToEol;
    end;

  procedure TeleT.PaperTop;
    begin
      SendNewLine;
      SendNewLine;
    end;

  procedure TeleT.PaperBottom;
    const
      paper: string[30] = '€‹‹‹‹€€‹‹‹‹‹‹€€‹‹  ‹‹€€€€€‹‹‹‹';
    var
      i: byte;
      j: byte;
    begin
      BreakSound;
      SendNewLine;
      j := succ(random(30));
      for i := 1 to Bounds.B.x - Bounds.A.x + 1 do
        begin
	  writechar( i, whereY, 1, paper[j], cGround );
	  if j < 30
            then inc(j)
	    else j := 1
        end;
    end;

  procedure TeleT.BreakSound;
    var
      i: integer;
    begin
      for i := 1 to 100 do
        begin
          sound( random(700) );
          delay( 1 )
        end;
      nosound;
    end;

  procedure TeleT.Color( c: byte );
    begin
      att := c;
      SetColor;
    end;

  procedure TeleT.SetColor;
    begin
      textcolor( byte(att shl 4) shr 4 );
      textbackground( att shr 4 )
    end;

  { Cursor jokes }

  procedure NoCursor; assembler;
    asm
      mov ah, 1
      mov ch, 1FH
      mov cl, 0
      int 10H
    end;

  procedure NormalCursor; assembler;
    asm
      mov ah, 1
      mov ch, 6
      mov cl, 7
      int 10H
    end;

  procedure BlockCursor; assembler;
    asm
      mov ah, 1
      mov ch, 0
      mov cl, 12
      int 10H
    end;

  function ColorAdapter: boolean;
    var
      VideoPort: word absolute $463;
    begin
      ColorAdapter := VideoPort = $3D4;
    end;

  procedure SetSpeed( s: byte );
    begin
      sDelay := 5*s
    end;

  procedure Silent;
    begin
      sSound := 0
    end;

  procedure InitColors;
    begin
      if not ColorAdapter
        then
          begin
	    cGround	:= cMonoGrnd;
	    cInv	:= cMonoInv;
	    cStatusBar	:= cMonoSBar;
	    cLimitBars	:= cMonoLBars;
	    cHighText	:= cMonoHigh;
	    cMenuBorder := cMonoMenuBorder;
	    cMenuBar	:= cMonoMenuBar;
          end
{	else
	  begin
	    cGround	:= cColorGrnd;
	    cInv	:= cColorInv;
	    cStatusBar	:= cColorSBar;
	    cLimitBars	:= cColorLBars;
	    cHighText	:= cColorHigh;
	    cMenuBorder := cColorMenuBorder;
	    cMenuBar	:= cColorMenuBar;
          end;
}   end;

begin
  InitColors
end.
