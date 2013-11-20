unit CmdLine;

interface

uses
  DOS;

const
  TrkName: PathStr = '';

implementation

uses
  CRT, Util, TTY, Castles;

var
  f: text;
  s, param: string;

function Clean( s: string): string;
  var
    i: byte;
  begin
    i := 1;
    while i < length( s) do
      if not ( s[i] in [#33..#126])
	then delete(s, i, 1)
	else inc( i);
    clean := s;
  end;

procedure Analyze( var id, param: string);
  var
    p: byte; 
  begin
    id := upper( clean( id));
    p := pos( ';', id);
    if p <> 0
      then delete( id, p, 255);
    p := pos( '=', id);
    if p = 0
      then id := ''
      else
	begin
	  param := copy( id, p+1, 255);
	  delete( id, p, 255);
	end
  end;

var
  i: byte;
begin
  assign( f, 'FORT.INI');
  reset( f);
  if IOresult = 0
    then
      begin
	while (not eof( f)) and (IOresult = 0) do
	  begin
	    readln( f, s);
	    Analyze( s, param);

	    if s <> ''
	      then
		if copy(s, 1, 6) = 'USEEGA'
		  then
		    UseEGA := (param[1] = '1')
		  else
		    if copy(s, 1, 9) = 'CHECKSNOW'
		      then
			CheckSnow := (param[1] = '1')
		      else
			if copy(s, 1, 11) = 'VERBOSEEXEC'
			  then
			    VerboseExec := (param[1] = '1')
			  else
			    if (copy(s, 1, 9) = 'EXECTRACK')
			      then
				if param = ''
				  then TrkName := ''
				  else TrkName := FExpand(param)
			       else {Ignore error};
	  end;
	close( f)
      end;
  for i := 1 to ParamCount do
    begin
      s := upper( ParamStr( i));
      if s[1] <> '/'
	then 
          if s = ''
            then TrkName := ''
	    else TrkName := FExpand(s)
	else
	  case s[2] of
	    'I': VerboseExec := s[3] <> '-';
	    'S': CheckSnow := s[3] <> '-';
	    'E': UseEGA := s[3] <> '-';
	  end
    end
end.