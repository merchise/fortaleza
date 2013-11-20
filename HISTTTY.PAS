unit HistTTY;

interface

uses
  Crt,Win,Objects,TeleType,StrColl;

type
 PHistColl = ^THistColl;
 THistColl =
   object ( TStrCollection )
     function IndxPred( anIndx: integer): integer;      virtual;
     function IndxSucc( anIndx: integer): integer;      virtual;
     function ScanStrBackward( aStr: string):string;    virtual;
     function ScanStrForward( aStr: string):string;     virtual;
   private
     indx : integer;
   end;

 PHistTTY  = ^THistTTY;
 THistTTY  =
   object( TeleT )
     constructor Init( R: TRect);
     destructor  Done;					virtual;
     function	 Receive: string;			virtual;
     procedure	 SetHistory( aHist: PHistColl); 	virtual;
     procedure	 SetMaxStrLen( aMax: integer);		virtual;
    private
     MaxStrLen : integer;
     History   : PHistColl;
     Template  : string;
   end;

implementation

  type
    CheckSet        = set of char;
  const
    Check: CheckSet = [#32..#255];
    NUL             = #0;
    BS              = #8;
    CR              = #13;
    LF              = #10;
    ESC             = #27;
    prompt          = ' ';

  function UpStr( aStr: string): string; assembler;
    asm
      cli
      push      ds
      les       di, @Result
      lds       si, aStr
      lodsb
      stosb
      xor       ah, ah
      mov       cx, ax
 @@2: lodsb
      cmp       al, 'a'
      jb        @@1
      cmp       al, 'z'
      jg        @@1
      sub       al, 'a'-'A'
 @@1: stosb
      loop      @@2
      pop       ds
      sti
    end;

  { THistoryCollection }

  function THistColl.IndxSucc;
    var
      i : integer;
    begin
      i := succ( anIndx);
      if i > pred( count)        { Wrap around }
	then i := 0;
      IndxSucc := i;
    end;

  function THistColl.IndxPred;
    var
      i : integer;
    begin
      i := pred( anIndx);
      if i < 0                  { Wrap around }
	then i := pred( count);
      IndxPred := i;
    end;

  function StringMatch( Str1,Str2: string ): boolean;
    var
     len     : byte;
    begin
      len := length( Str1);
      if (len = 0) or (UpStr( Str1) = UpStr( copy( Str2, 1, len)))
        then StringMatch := true
        else StringMatch := false;
    end;

  function THistColl.ScanStrBackward;
    var
      i      : integer;
      Quit   : boolean;
      TmpPtr : PString;
    begin
      i := IndxPred( indx);
      Quit := false;
      while not Quit do
        begin
	  TmpPtr := PString( At( i));
	  if StringMatch(aStr, TmpPtr^)
            then
              begin
                ScanStrBackward := TmpPtr^;
                indx := i;
                exit
              end
	    else i := IndxPred( i);
	  if i = IndxPred( indx)
	    then Quit := true;
        end;
      ScanStrBackward := '';
    end;

  function THistColl.ScanStrForward;
    var
      i      : integer;
      Quit   : boolean;
      TmpPtr : PString;
    begin
      i := IndxSucc( indx);
      Quit := false;
      while not Quit do
        begin
	  TmpPtr := PString( At( i));
	  if StringMatch(aStr, TmpPtr^)
            then
              begin
                ScanStrForward := TmpPtr^;
                indx := i;
                exit
              end
	    else i := IndxSucc( i);
	  if i = IndxSucc( indx)
	    then Quit := true;
	end;
      ScanStrForward := '';
    end;

  { THistoryTTY }

  constructor THistTTY.Init;
    begin
      TeleT.Init( R);
      SetMaxStrLen( Bounds.B.X - Bounds.A.X - length( prompt) - 1);
      Template := '';
    end;

  destructor THistTTY.Done;
    begin
      TextMode(CO80);
      TeleT.Done
    end;

  function THistTTY.Receive;

    procedure Beep( error: boolean);
      begin
        if error
          then
            begin
	      Sound( 440);
	      Delay( 110);
              NoSound;
            end
      end;

    procedure GetStr( var LineStr: string; len: byte);
      var
	SPos, TempPos, i,
	count, x1,y1, x2 : byte;
	ch     		 : char;
	s2, stmp   	 : string;
	Ins, edited 	 : boolean;

    procedure SetPosX( x:byte);
      begin
        x2 := x;
	gotoXY( x2, y1);
      end;

    procedure SetStr( aStr: string);
      begin
        LineStr := aStr;
	count := length( LineStr);
	TempPos := 1;
        SPos := 1;
	SetPosX( x1);
        ClrToEol;
	write( LineStr);
	SetPosX( x1);
      end;

    procedure DelChar;
     begin
       if count <> 0 then
	 begin
	   dec( count);
	   if SPos <= count
	     then
	       begin
		 write( copy( LineStr, succ( SPos), 255),' ');
		 gotoXY( x2, y1);
	       end
             else
	       write( ' '+BS);
	   Delete( LineStr, SPos, 1);
         end
     end;

    procedure AddChar( ch: char);
     begin
       if count < len
	 then
	   begin
	     if SPos = succ( count)
	       then LineStr := LineStr + ch
	       else
		 begin
		   write( ' ', copy( LineStr, SPos, 255));
		   gotoXY( x2, y1);
		   Insert( ch, LineStr,SPos);
		 end;
	    write( ch);
	    inc( x2);
	    inc( count);
	    inc( SPos);
	 end;
     end;

    procedure InsertStr( aStr: string);
      var
	i : byte;
      begin
	for i := 1 to length(aStr) do
	  AddChar( aStr[i]);
      end;

    procedure SubstChar( ch: char);
     begin
       if SPos <= count
         then DelChar;
       AddChar( ch);
     end;

    procedure SetChar( ch: char);
      begin
	edited := true;
	if Ins
	  then AddChar( ch)
	  else SubstChar( ch);
      end;

   const
     kbAltE   = #$12;  kbAltR  = #$13;	kbAltT = #$14;
     kbAltY   = #$15;  kbAltU  = #$16;	kbAltI = #$17;
     kbAltO   = #$18;  kbAltP  = #$19;	kbAltB = #$30;
     kbAltA   = #$1E;  kbAltS  = #$1F;	kbAltD = #$20;
     kbAltH   = #$23;  kbAltJ  = #$24;	kbAltK = #$25;
     kbAltL   = #$26;  kbAltZ  = #$2C;	kbAltX = #$2D;
     kbAltF   = #$21;  kbAltG  = #$22;	kbAltC = #$2E;
     kbAltV   = #$2F;  kbAltN  = #$31;	kbAltM = #$32;
     kbEnter  = #$0d;  kbEsc   = #$1b;  kbAltQ = #$10;
     kbF1     = #$3B;  kbF2    = #$3C;  kbF3   = #$3D;
     kbCtrlL  = #$0c;  kbBkSpc = #$08;  kbF9   = #$43;
     kbUp     = #$48;  kbDown  = #$50;	kbExtd = #$00;
     kbLeft   = #$4B;  kbRight = #$4D;
     kbEnd    = #$4F;  kbHome  = #$47;
     kbIns    = #$52;  kbDel   = #$53;

    begin
     LineStr := '';                     { Edited string          }
     count := 0;			{ Length of string       }
     SPos := 1;   			{ Position in string     }
     TempPos := 1;			{ Position in template   }
     x1 := WhereX;			{ X coord of beginning   }
     x2 := x1;                          { X coord of current pos }
     y1 := WhereY;                      { Y coord of beginning   }
     Ins := true;			{ Insert toggle		 }
     edited := true;			{ Edited or not		 }

     repeat
       ch := ReadKey;
       case ch of
       kbExtd:
         begin
	   ch := readkey;
           case ch of
	    kbF2:
	      begin
		SetStr('salvar');
		ch := kbEnter
	      end;
	    kbF9:
	      begin
		SetStr('ejecutar');
		ch := kbEnter
	      end;
	    kbAltQ:
	      begin
		SetStr('terminar');
		ch := kbEnter
	      end;
	    kbAltI:
	      InsertStr('ir ');
	    kbAltA:
	      InsertStr('abrir ');
	    kbAltC:
	      InsertStr('coger ');
	    kbAltP:
	      InsertStr('preguntar ');
	    kbAltD:
	      InsertStr('dar ');
	    kbAltL:
	      InsertStr('leer ');
	    kbAltR:
	      InsertStr('romper ');
	    kbAltM:
	      InsertStr('matar ');
	    kbF1:
	      if TempPos <= length( template)
		then
		  begin
		    SetChar( Template[ TempPos ]);
		    inc( TempPos);
		  end;
	    kbF3:
	      if (length( template) <> 0) and (TempPos <> length( Template))
		then
		  begin
		    for i := TempPos to length( template) do
		      SetChar( Template[ i]);
		    TempPos := length( template) + 1;
		  end;
	    kbHome:
              begin
                SPos := 1;
		SetPosX( x1);
	      end;
	    kbEnd:
	      begin
		SPos := succ( count);
		SetPosX( x1 + count);
	      end;
	    kbUp:
	      if ( History <> nil) and ( History^.count > 0)
		then
		  begin
		    if edited then
			s2 := LineStr;
		    stmp := History^.ScanStrBackward(s2);
		    if stmp <> ''
                      then
                        begin
			  SetStr( stmp);
			  edited := false;
			end
		      else Beep( true)
		  end;
	    kbDown:
	      if ( History <> nil) and ( History^.count > 0)
		then
		  begin
		    if edited
		      then s2 := LineStr;
		    stmp := History^.ScanStrForward( s2);
		    if stmp <> ''
		      then
			begin
			  SetStr( stmp);
			  edited := false;
			end
		      else Beep( true);
		  end;
	    kbLeft:
	      if SPos > 1 then
		begin
		  Dec( x2);
		  Dec( SPos);
		  gotoXY( x2, y1);
		end;
	    kbRight:
	      if SPos <= count
		then
		  begin
		    Inc( x2);
		    Inc( SPos);
		    gotoXY( x2, y1);
		  end;
	    kbIns:
	       begin
		 Ins := not Ins;
                 if Ins
                   then NormalCursor
                   else BlockCursor;
               end;
	    kbDel:
               begin
                 DelChar;
		 edited := true;
	       end;
           end; {case}
         end;
       kbCtrlL:
	 lineStr := ^L; 			{ Clear screen }
       kbBkSpc:
	 if SPos <> 1 then
	   begin
	     dec( SPos);
	     SetPosX( pred( x2));
             DelChar;
             edited := true;
           end;
       kbEsc:
         begin
	   History^.indx := History^.count; 	{ Reset cursor position }
	   SetStr( '');
	   edited := true;
	 end;
       else
       if (ch in Check)
	 then
	   begin
	     SetChar( ch);
	     if (TempPos <= length( template)) and (not ins)
		then inc( TempPos)
	   end
	 else
	   if not (ch in [kbEnter, kbEsc])
	     then Beep( true);
      end; {case}
     until (ch = kbEnter) or (ch = kbCtrlL);
  end;

  var
    s: string;

  begin
    History^.indx := History^.count; { Reset cursor position }
    if MaxStrLen = 0
      then MaxStrLen := Bounds.B.X -Bounds.A.X - length(prompt);
    repeat
      Color( cGround );
      if state <> stReceiving
	then SetState( stReceiving );
      SetColor;
      Send( prompt );
      Color( cHighText );
      SetColor;
      GetStr( s, MaxStrLen );
      if s = ^L
	then
	  begin
	    Clear;
	    NewPaper
	  end;
    until s <> ^L;
    Receive := s;
    Template := s;
    Color( cGround );
    SendNewLine;
  end;

 procedure THistTTY.SetHistory;
   begin
     if aHist <> nil
       then History := aHist;
   end;

 procedure THistTTY.SetMaxStrLen;
   begin
     if aMax < (Bounds.B.X -Bounds.A.X - length(prompt))
       then MaxStrLen := aMax;
   end;

end.
