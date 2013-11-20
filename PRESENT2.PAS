unit Present2;

interface

  procedure Presentation;
  function  Menu( x, y : integer ) : integer;

implementation

  uses
    Crt, Letters, Win, Sounds, Teletype, TTY;

  const
    Items : array[ 0..5 ] of string[20] =
      ( 'ÛÛÛÛÛÛÛÛÛÛÛÛÛÛ',
        '   Comenzar   ',
        ' Introducci¢n ',
        '   Consejos   ',
        '   Terminar   ',
        'ÛÛÛÛÛÛÛÛÛÛÛÛÛÛ' );

  function Menu( x, y : integer ) : integer;
    var
      i   : integer;
      p   : integer;
      ch  : byte;
      ega : boolean;
    begin
      p   := 1;
      ega := IsEGA;
      repeat
	WriteStr( x, y, Items[0], 7 );
	WriteStr( x, y + 5, Items[5], 7 );
	for i := 1 to 4 do
          begin
            if ega
	      then WriteStr( x, y + i, Items[i], cInv )
	      else WriteStr( x, y + i, Items[i], cGround );
	    WriteStr( x + 1, y + i, copy(Items[i],2,14), cGround );
	  end;
        if ega
          then
            begin
	      WriteStr( x + 1, y + p, 'ã            æ', $74 );
	      WriteStr( x + 2, y + p, copy(Items[p],3,12), $4F )
	    end
	  else WriteStr( x + 1, y + p, copy(Items[p],2,14), $4F );
	ch := byte(readkey);
        if ch = 0
          then ch := byte(readkey);
        case ch of
	  72: if p > 1
		then dec( p )
		else p := 4;
	  80: if p < 4
		then inc( p )
		else p := 1;
        end;
      until ch = 13;
      Menu := p;
    end;

  procedure HideCursor; assembler;
    asm
      mov cx, 2000H
      mov ax, 0100H
      int 10H
    end;

  procedure Presentation;
    var
      x : integer;
    begin
      HideCursor;
      textbackground( 0 );
      clrscr;

      delay( 1000 );

      WriteStr( 25, 10, ' En la lucha entre t£ y el mundo,', 15 );
      WriteStr( 25, 11, '                  apoya al mundo.', 15 );
      WriteStr( 46, 13, 'Franz Kafka', 15);
      delay( 4000 );

      clrscr;
      delay( 2000 );
      x := 40 - length( 'Merchise Software' ) div 2;
      OutTextXY( x, 12, 7, 'Merchise Software' );
      delay( 100 );
      WriteStr( x, 12, 'Merchise Software', 15 );

      delay( 1500 );
      clrscr;
      x := 40;
      OutTextXY( x, 12, 7, 'y' );
      delay( 100 );
      WriteStr( x, 12, 'y', 15 );
      delay( 700 );
      clrscr;
      x := 40 - length( '[[]]') div 2;
      OutTextXY( x, 12, 7, '[[]]' );
      delay( 100 );
      WriteStr( x, 12, '[[]]', 15 );
      delay( 1000 );
      clrscr;
      x := 40 - length( 'presentan' ) div 2;
      OutTextXY( x, 12, 7, 'presentan' );
      delay( 100 );
      WriteStr( x, 12, 'presentan', 15 );
      delay( 1000 );
      clrscr;
      delay( 1000 );
      x := 40 - length( 'L A  F O R T A L E Z A  II' ) div 2;
      OutTextXY( x, 12, 7, 'L A  F O R T A L E Z A  II' );
      delay( 100 );
      WriteStr( x, 12, 'L A  F O R T A L E Z A  II', 15 );
      Thunder;
      delay( 1000 );
      delline;
      x := 40 - length( 'La venganza de la Bestia' ) div 2;
      OutTextXY( x, 12, 4, 'La venganza de la Bestia' );
      Ouch;
      delay( 100 );
      WriteStr( x, 12, 'La venganza de la Bestia', 4 );
      delay( 1000 );
      delline;
      delay( 100 );
      delline;
      delay( 100 );
      delline;
      delay( 100 );
    end;

var
  i : integer;

begin
  if IsEGA
    then
      begin
        Items[0] := 'ƒ' + Items[0] + 'Û„…';
        Items[1] := 'Û' + Items[1] + 'ä';
        Items[2] := 'å' + Items[2] + 'ê';
        Items[3] := 'á' + Items[3] + 'â';
        Items[4] := 'å' + Items[4] + 'ê';
        Items[5] := 'ˆ' + Items[5] + 'Û†‡';
      end
    else
      begin
        Items[0] := 'Û' + Items[0] + 'Û';
        Items[5] := 'Û' + Items[5] + 'Û';
        for i := 1 to 4 do
          Items[i] := ' ' + Items[i] + ' ';
      end;
end.