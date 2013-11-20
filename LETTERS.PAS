unit letters;

interface

  procedure OutTextXY  ( x, y, att : byte ; str : string );
  procedure RunningText( x, y, att : byte ; str : string );

implementation

  uses
    Crt, Win;

  procedure OutTextXY( x, y, att : byte ; str : string );
    var
      s : string;
    begin
      s[0] := char(length(str));
      fillchar( s[1], length(str), 'ú' );
      WriteStr( x, y, s, att );
      delay( 50 );
      fillchar( s[1], length(str), 'ù' );
      WriteStr( x, y, s, att );
      delay( 50 );
      fillchar( s[1], length(str), '' );
      WriteStr( x, y, s, att );
      delay( 50 );
      fillchar( s[1], length(str), 'þ' );
      WriteStr( x, y, s, att );
      delay( 50 );
      WriteStr( x, y, str, att );
    end;

  procedure RunningText( x, y, att : byte ; str : string );
    var
      lastX : integer;
      i     : integer;
      xx    : integer;
    begin
      for i := 1 to length(str) do
        begin
          for xx := 80 downto x + pred(i) do
            begin
	      WriteChar( xx, y, 2, ' ', att );
	      WriteChar( xx, y, 1, str[i], att );
	      delay( 3 );
            end;
        end;
    end;


end.