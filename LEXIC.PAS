unit Lexic;

interface

  const
    KWmax   = 100;
    Setmax  = 100;

  type
    TokenSet  = set of char;
    TokenType = ( Number, Identifier, Strn, KeyWord, Symbol, Operator, Unexisting );
    LexData   = record
		  StrId   : char;
		  ComOp   : char;
		  ComClos : char;
		  UnvSep  : char;
		end;
    SetType   = record
		  allowed   : TokenSet;		  { Set of chars that may compose a token }
		  unallowed : TokenSet;           { Chars that doesn't mean a token alone }
		  clase     : TokenType;	  { Token's type }
		end;

    KWordObj  = object
		  nKW : byte;     	          { Number of key-words }
		  ary : pointer;		  { Pointer to the key-words array }
		  constructor Init    ( nK : byte  ; pKW : pointer );
		  function    IsKWord ( s  : string                ) : byte; virtual;  { 0 if s isn't a reserved word }
		end;

    AlphObj   = object( KWordObj )
		  nSet    : byte;		{ Number of sets }
		  SetArr  : pointer;            { Pointer to the sets' array }
		  StrId   : char;               { String identifier }
		  ComOp   : char;               { Comments identifier }
		  ComClos : char;
		  UnvSep  : char;
		  constructor Init;
		  function    GetSet ( ch : char ; var tSet : TokenSet ) : TokenType ; virtual;
		end;
    PLexObj   = ^LexObj;
    LexObj    = object( AlphObj )
		  st   : string;
		  tk   : string;
		  ps   : byte;
		  cf   : TokenType;
		  skip : boolean;

		  constructor Init( kwP, stP : pointer ; kwN, stN : byte ; var data : LexData );

		  procedure SetStr( s : string );     	{ Sets string in st and formats it }
		  procedure FormatStr;                  { Formats st }
		  procedure SetToken;                   { Sets a token in tk }
		  procedure SetClasif;                  { Sets token's clasification in cf }

		  function GetStr( var s : string ) : boolean;	  { Gets a string to s. FALSE if there isn't any string. }
		  function Token  		    : string;	  { Returns tk }
		  function Clasif 		    : TokenType;  { Returns cf }
		  function Poss   		    : byte;       { Returns ps }
		  function EOS			    : boolean;    { TRUE if ps is in the End Of the String }
		end;

implementation

uses
  Util;

  constructor KWordObj.Init( nK : byte ; pKW : pointer );
    begin
      nKW := nK;
      ary := pKW;
    end;

  function KWordObj.IsKWord( s : string ) : byte;
    type
      KWaryType = array[ 1..KWmax ] of string;
    var
      i     : byte;
      KWary : ^KWaryType;
    begin
      KWary := ary;
      i     := 0;
      repeat
	inc( i )
      until ( upper(s) = upper(KWary^[i]) ) or ( i = nKW );
      if ( upper(s) = upper(KWary^[i]) )
	then IsKWord := i
	else IsKWord := 0;
    end;

  constructor AlphObj.Init;
    begin
      nSet    := 0;
      SetArr  := nil;
      StrId   := ' ';
      ComOp   := ' ';
      ComClos := ' ';
    end;

  function AlphObj.GetSet( ch : char ; var tSet : TokenSet ) : TokenType;
    type
      SetAryType = array[ 1..SetMax ] of SetType;
    var
      i      : byte;
      SetAry : ^SetAryType;
    begin
      SetAry := SetArr;
      i      := 0;
      repeat
	inc( i );
	tSet := SetAry^[i].allowed;
      until ( ch in (SetAry^[i].allowed - SetAry^[i].unallowed) ) or ( i = nSet );
      if ch in (SetAry^[i].allowed - SetAry^[i].unallowed)
	then GetSet := SetAry^[i].clase
	else GetSet := Unexisting;
    end;

  constructor LexObj.Init( kwP, stP : pointer ; kwN, stN : byte ; var data : LexData );
    begin
      st      := '';
      tk      := '';
      ps      := 1;
      cf      := Unexisting;
      StrId   := data.StrId;
      ComOp   := data.ComOp;
      ComClos := data.ComClos;
      UnvSep  := data.UnvSep;
      nKW     := kwN;
      ary     := kwP;
      nSet    := stN;
      SetArr  := stP;
    end;

  procedure LexObj.FormatStr;
    var
      i      : byte;
      k      : string;
      inside : boolean;
      comm   : boolean;
    begin
      inside := FALSE;
      comm   := FALSE;
      k      := '';
      i      := 1;
      while st[i] = UnvSep do
	inc( i );
      delete( st, 1, pred(i) );
      for i := 1 to length( st ) do
	begin
	  if st[i] = StrId
	    then inside := not inside;
	  if not inside
	    then
	      begin
		if st[i] = ComOp
		  then comm := TRUE;
		if not comm
		  then
		    if not( ( st[i] = UnvSep ) and ( (st[pred(i)] = UnvSep ) or (st[pred(i)] = ComClos) ) and ( pred(i) <> 0 ) )
		      then k  := k + st[i];
		if st[i] = ComClos
		  then comm := FALSE;
	      end
	    else k := k + st[i];
	end;
      st := k
    end;

  procedure LexObj.SetStr( s : string );
    begin
      st := s;
      ps := 1;
      FormatStr;
    end;

  procedure LexObj.SetToken;
    var
      aux   : string;
      tSet  : TokenSet;
    begin
      tk := '';
      if st[ps] = StrId
	then
	  if GetStr( aux )
	    then
	      begin
		tk := StrId + aux + StrId;
		if st[ps] = UnvSep
		  then inc( ps );
	      end
	    else tk := ''
	else
	  begin
	    cf := GetSet( st[ps], tSet );
	    while (cf = Unexisting) and not EOS do
	      begin
		inc( ps );
		cf := GetSet( st[ps], tSet );
              end;
            while ( st[ps] in tSet ) and ( ps <= length( st ) ) and ( st[ps] <> UnvSep ) do
	      begin
		tk := tk + st[ps];
		inc( ps );
	      end;
	      if st[ps] = UnvSep
		then inc( ps );
	  end;
    end;

  function LexObj.GetStr( var s : string ) : boolean;
    var
      aux  : string;
      p    : byte;
    begin
      if st[ps] = StrId
	then
	  begin
	    aux := copy( st, ps, length( st ) - pred(ps) );
	    delete( aux, 1, 1 );
	    p := pos( StrId, aux );
	    if p <> 0
	      then
		begin
		  s      := copy( aux, 1, pred(p) );
		  ps     := ps + succ(p);
		  GetStr := TRUE;
		end
	      else GetStr := FALSE;
	  end;
    end;

  procedure LexObj.SetClasif;
    var
      i      : byte;
      auxSet : TokenSet;
      auxStr : string;
    begin
      if tk = ''
	then cf := Unexisting
	else
	  if tk[1] = StrId
	    then
	      if byte( pos( StrId, copy( tk, 2, pred( length( tk ) ) ))) <> 0
		then cf := Strn
		else cf := Unexisting
	    else
	      if IsKWord( tk ) <> 0
		then cf := KeyWord;
    end;

  function LexObj.Token : string;
    begin
      Token := tk
    end;

  function LexObj.Clasif : TokenType;
    begin
      Clasif := cf
    end;

  function LexObj.Poss : byte;
    begin
      Poss := ps
    end;

  function LexObj.EOS : boolean;
    begin
      EOS := ( ps > length( st ) );
    end;

end.