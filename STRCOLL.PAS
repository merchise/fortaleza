unit StrColl;

interface

  uses Objects;

  type
    Filename       = string;

    PStrCollection = ^TStrCollection;
    TStrCollection = object( TCollection )
                       procedure FreeItem( Item : pointer );  virtual;
                       function  Load( f : FileName ) : boolean;
                       function  Save( f : FileName ) : boolean;
                     end;

implementation

  procedure TStrCollection.FreeItem( Item : pointer );
    begin
      disposeStr( Item );
    end;

  function TStrCollection.Load( f : Filename ) : boolean;
    var
      auxF : text;
      auxS : string;
    begin
      assign( auxF, f );
      reset( auxF );
      if IOResult = 0
        then
          begin
            repeat
	      readln( auxF, auxS );
              if auxS <> ''
		then insert( newStr( auxS ));
	    until eof( auxF ) or (IOresult <> 0);
            close( auxF );
            Load := TRUE
          end
        else Load := FALSE
    end;

  function TStrCollection.Save( f : Filename ) : boolean;
    var
      auxF : text;
      i    : word;
    begin
      assign( auxF, f );
      {$I-}
      rewrite( auxF );
      {$I+}
      if IOResult = 0
        then
          begin
            for i := 0 to pred(count) do
              if At(i) <> nil
		then writeln( auxF, PString(At(i))^ );
            close( auxF );
            Save := TRUE;
          end 
        else Save := FALSE
    end;

  end.