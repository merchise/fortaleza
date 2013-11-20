unit Scroller;

interface

  uses
    Crt, Win;

  procedure ScrollText( var Text ; count : integer );

implementation

  type
    SuperArray = array[1..500] of string[80];

  const
    page  = 22;
    limit = 23;

  procedure ScrollText( var Text ; count : integer );
    var
      lines : SuperArray absolute Text;
      top   : integer;
      ch    : byte;
      moved : boolean;

    procedure Display;
      var
        i : integer;
      begin
        for i := 1 to limit do
          begin
	    WriteChar( 1, succ(i), 80, ' ', 2 );
	    if pred(top) + i <= count
	      then WriteStr( 1, succ(i), lines[pred(top) + i], 2 );
	  end;
      end;

    begin
      top   := 1;
      moved := true;
      repeat
        if moved
          then Display;
        ch := byte(readkey);
        if ch = 0
          then ch := byte(readkey);
        moved := true;
        case ch of
	  71:
	    if top <> 1
              then top := 1
	      else moved := false;
          72:
	    if top > 1
	      then dec( top )
	      else moved := false;
	  73:
	    if top <> 1
	      then
		if top - page < 1
		  then top := 1
		  else dec( top, page )
	      else moved := false;
          79:
	    if top <> count - limit
	      then top := count - limit
	      else moved := false;
          80:
	    if top < count - limit
	      then inc( top )
	      else moved := false;
	  81:
	    if top <> count - limit
	      then
		if top + page > count - limit
		  then top := count - limit
		  else inc( top, page )
	      else moved := false;
          else moved := false;
        end;
      until ch = 27;
    end;

end.