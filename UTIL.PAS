unit Util;

interface

  function Upper( st: string ): string;

implementation

uses 
  CRT, DOS;

var
  OldExitProc: pointer;

  function Upper( st: string ): string;
    var
      i : byte;
      s : string;
    begin
      s := '';
      for i := 1 to length( st ) do
	s := s + upcase( st[i] );
      Upper := s;
    end;

  procedure PrintHex(n: word; l: integer);
  const
    HexChr: array[0..15] of char = '0123456789ABCDEF';
  var
    i : integer;
    s : string[4];
  begin
    s[0] := chr(l);
    for i :=l downto 1 do
      begin
	s[i] := HexChr[n mod 16];
	n := n div 16
      end;
    write(s)
  end{PrintHex};

  procedure PrintPtr(p: pointer);
  begin
    PrintHex(seg(p^),4);
    write(':');
    PrintHex(ofs(p^),4)
  end{PrintPtr};

  procedure Break; interrupt;
    begin
      halt( 1 );
    end;

  procedure MyExit; far;
  begin
    ExitProc := OldExitProc;

    textbackground( 0 );
    textcolor( 7 );
    if ErrorAddr <> nil
      then
	begin
	  write('Ha ocurrido el error interno #',ExitCode,' en ');
	  PrintPtr(ErrorAddr);
	  writeln('. Por favor, reporte a Merchise.'#10);
	  ErrorAddr := nil
	end
      else
	case ExitCode of
	 1: writeln( 'Ctrl-Break fue presionado. Utilice "Terminar" para una salida m s elegante.' );
	 2: writeln( '[[]] Lo siento, pero no hay memoria suficiente para inicializar La Fortaleza.' );
	end;
  end;

begin
  OldExitProc := ExitProc;
  ExitProc := @MyExit;
  SetIntVec( $23, @Break );
end.
