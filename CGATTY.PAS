unit CGATTY;

interface

  uses
    Crt, Objects, Win, TeleType,HistTTY;

type
  PCGATTY = ^TCGATTY;
  TCGATTY  =
    object( THistTTY )
      procedure   ClrToEol;		virtual;
      procedure   NewPaper;             virtual;
{     procedure   PaperBottom; 		virtual;
      procedure   SendNewLine;          virtual;
}   end;

implementation

{ TCgaTTY }

procedure TCgaTTY.ClrToEol;
  begin
    writechar( WhereX, whereY, Bounds.B.x - Bounds.A.x - WhereX + 1, ' ', cGround );
  end;

procedure TCgaTTY.NewPaper;
  var
    i: byte;
  begin
    color( cInv);
    ClrScr;
    color( cGround);
    gotoXY(1, Bounds.B.y - Bounds.A.y + 1);
    PaperTop;
{
    SendMargins;
    ClrToEol;
    TeleT.NewPaper;

    if checksnow
      then
	begin
	  for i := 1 to Bounds.B.y - Bounds.A.y - 5 do
	    begin
	      SendNewLine;
	      writechar( 1, whereY, Bounds.B.x - Bounds.A.x - 2, ' ', cGround )
	    end;
	  gotoxy( 1, 5 )
	end
  end;

procedure TCgaTTY.PaperBottom;
  begin
    if checksnow
      then
	begin
	  gotoxy( 1, Bounds.B.y - Bounds.A.y);
	  SendNewLine
	end;

    TeleT.PaperBottom
  end;
}
  end;

end.

  if height = 0
    then height := 24;

  if ColorAdapter
    then seg := $b800
    else seg := $b000;

procedure TCgaTTY.SendNewLine;

  function VPtr( x, y: byte): pointer;
  begin
    VPtr := Ptr( seg, ofs + (y * width + x) * 2)
  end;

  var
    width  : word absolute $0000:$044a;
    height : byte absolute $0000:$0484;
    scrsize: word absolute $0000:$044c;
    ofs    : word absolute $0000:$044e;
    Seg    : word;

  procedure MyMove( var src, dst; size: word);
    begin
      if CheckSnow
	then
	  asm
		cli
		push	ds
		lds	si, src
		les	di, dst
		mov	cx, size
		mov	dx, $3da

       @WrtLoop:in	al, dx
		test	al, 8
		jne	@Write
	@Again1:in	al, dx
		rcr	al, 1
		jc	@Again1
	@Again2:in	al, dx
		rcr	al, 1
		jnc	@Again2
	@Write: movsw
		loop	@WrtLoop

		pop	ds
		sti
	  end
	else Move( src, dst, size * 2)
    end;

  begin
    MyMove( VPtr(0,2)^, VPtr(0, 1)^, width * 22);
    gotoXY(2,WhereY);
    ClrToEol;
    SendMargins;
}
