unit Castles;

interface

  uses
    Crt, Objects, Lexic, Vocabl, StrColl, TeleType, HistTTY, Util;

  const
    sLimit   = 10;
    sDelta   =  5;
    LWeight  = 40;

    _Delay1  =  2;
    _Delay2  =  0;

    _AskAt   = 15;
    _TalkAt  =  2;

    OpenDoor = #0#0#0;
    VerboseExec: boolean = true;

  type
    PThing       = ^Thing;
    Thing        = object( TCollection )
		     name : PString;
		     descr: PString;
		     mase : byte;
		     constructor Init( nme, desc: string ; mse: byte );
                     destructor  Done;                     virtual;
		     function	 Image: string; 	  virtual;
		     procedure	 Output( s: string );	  virtual;
                   end;

    PLivingThing = ^LivingThing;
    LivingThing  = object( Thing )
		     dead: boolean;
                     procedure Speak;                              virtual;
		     function  Die  ( weapon: string ): boolean; virtual;
		     procedure Acept( gift  : PThing ); 	  virtual;
                   end;

    PLinking     = ^Linking;
    Linking      = object( Thing )
		     destination: PThing;
		     opn	: boolean;
		     key	: String;
		     passcomment: PString;
		     constructor Init( nme, desc, keyword, pscm: string ; destt: PThing );
		     destructor  Done;                             virtual;
		     function	 Open( psKey: string ): boolean; virtual;
		     procedure	 Pass( body : PThing ); 	  virtual;
                     procedure   Close;                            virtual;
		     function	 Dest: PThing;
                   end;

    PRoom        = ^Room;
    Room         = object( Thing )
		     visited: boolean;
                     procedure Describe;                              virtual;
		     function  Get  ( nm	: string ): PThing; virtual;
		     function  Take ( nm	: string ): PThing; virtual;
		     procedure Open ( nm, psKey: string );	    virtual;
		     procedure Break( nm, nw   : string );	    virtual;
                   end;

    PSuitcase    = ^Suitcase;
    Suitcase     = object( Room )
                     procedure Describe;                              virtual;
		     function  Empty	: boolean;
		     function  Heaviness: word;
                   end;

    PMan         = ^Man;
    Man          = object( LivingThing )
		     curr  : PRoom;
		     bag   : PSuitcase;
		     Visits: integer;
		     constructor Init( nme, desc: string );
                     destructor  Done; virtual;
                     procedure   Inventary;
		     procedure	 OpenD( door, key: string );
		     procedure	 WalkT( door: string );
		     function	 Die  ( weapon : string ): boolean; virtual;
		     procedure	 Go   ( newRoom: PRoom	);
                     procedure   Look;
		     procedure	 See  ( what: string );
		     procedure	 Ask  ( who : string );
		     procedure	 Kill ( who, weapon: string );
		     procedure	 Give ( what, who: string );
		     procedure	 Take ( what: string );
		     procedure	 Leave( what: string );
		     procedure	 Drink( what: string );
		     procedure	 Eat  ( what: string );
		     procedure	 Break( what, how: string );
		     procedure	 Weigh( what: string );
                     procedure   LeaveAll;
                   end;

    PTroll       = ^Troll;
    Troll        = object( LivingThing )
		     likeness: PString;
		     LowData : PString;
		     HiData  : PString;
		     happy   : boolean;
		     constructor Init( nm, ds, lk, hD, lD: string );
		     destructor  Done;                             virtual;
		     procedure	 Acept( gift: PThing ); 	  virtual;
		     function	 Die( weapon: string ): boolean; virtual;
                     procedure   Speak;                            virtual;
                   end;

    POpenLink    = ^OpenLink;
    OpenLink     = object( Linking )
		     constructor Init( nme, desc, pscm: string ; destt: PThing );
		   end;

    PDangerLink  = ^DangerLink;
    DangerLink   = object( Linking )
		     talisman: PString;
		     constructor Init( nm, desc, keyword, pscm, tlsm: string ; destt: PThing );
		     destructor  Done;                   virtual;
		     procedure	 Pass( body : PThing ); virtual;
                   end;

    PDangerLink2 = ^DangerLink2;
    DangerLink2  = object( DangerLink )
		     procedure	 Pass( body : PThing ); virtual;
                   end;

    PRiddleLink  = ^RiddleLink;
    RiddleLink   = object( Linking )
		     riddle: PString;
		     answer: PString;
		     constructor Init( nm, desc, rddle, answ, pscm: string ; destt: PThing );
		     destructor  Done;                             virtual;
		     function	 Open( psKey: string ): boolean; virtual;
                   end;

    PHidden      = ^Hidden;
    Hidden       = object( Thing )
		     hidd   : PThing;
		     breaker: PString;
		     constructor Init( nm, desc, brk: string ; hdd: PThing );
		     destructor  Done; virtual;
		     function	 Break( weapon: string ): boolean;
		     function	 HiddenThing: PThing;
                   end;

    PGuard       = ^Guard;
    Guard        = object( LivingThing )
		     confession: PString;
		     lethalweap: PString;
		     constructor Init( nm, ds, cnf, wp: string );
		     destructor  Done; virtual;
		     function	 Die( weapon: string ): boolean; virtual;
                   end;

    PCastle      = ^Castle;
    Castle       = object( Thing )
		     m	     : PMan;
		     voc     : PLexObj;
		     wish    : string;
		     track   : PHistColl;
		     constructor Init( mman: PMan ; vc: PLexObj );
                     destructor  Done; virtual;
                     procedure   Start;
                     procedure   AskMan;
                     procedure   ClearWish;
                     procedure   MakeManWish;
                     procedure   Go;
                     procedure   Take;
                     procedure   Leave;
                     procedure   Open;
                     procedure   Kill;
                     procedure   Look;
                     procedure   See;
                     procedure   Break;
                     procedure   Ask;
                     procedure   Inventary;
                     procedure   Percent;
                     procedure   Give;
		     procedure	 SaveTrack( f: string );
		     function	 ExecTrack( f: string ): boolean;
		     function	 Input : string;
		     function	 IsOver: boolean;
		     function	 Goal  : boolean; virtual;
                   private
		     relevant : boolean;
		     executing: boolean;
		     wishback : string;
                   end;

  PDaugther = ^TDaugther;
  TDaugther = object( Guard )
		function Die( weapon: string ): boolean;  virtual;
              end;

  var
    ManX: PMan;
    Tele: PHistTTY;

implementation

  uses
    EqString, Sounds, CmdLine;

  { Thing }

  constructor Thing.Init( nme, desc: string ; mse: byte );
    begin
      TCollection.Init( sLimit, sDelta );
      name  :=	newStr( nme );
      descr :=	newStr( desc );
      mase  :=	mse
    end;

  destructor Thing.Done;
    begin
      disposeStr( name );
      disposeStr( descr );
      TCollection.Done;
    end;

  function Thing.Image: string;
    begin
      Image :=	descr^
    end;

  procedure Thing.Output( s: string );
    var
      w : byte;
      p : byte;
      ss: string;
    begin
      if not Visible
        then exit;
      p := pos( #13, s );
      if p <> 0
        then
          begin
	    ss := copy( s, 1, pred(p) );
	    s  := copy( s, succ(p), length(s) - p );
	    Output( ss );
            Output( s  )
          end
        else
          begin
	    w := lo(windmax) - lo(windmin) - 2;
            repeat
              if length( s ) > w
                then
                  begin
		    p := w;
                    repeat
                      dec( p )
                    until (s[p] = _Blank) or (s[p] = #13) or (p = 0);
                    if p = 0
                      then
                        begin
			  s :=	copy( s, 1, w );
			  Tele^.Sendln( s );
                        end
                      else
                        begin
			  Tele^.Sendln( copy( s, 1, p ) );
			  s :=	copy( s, succ(p), length(s) - p );
			end
                  end
                else
                  begin
                    Tele^.Sendln( s );
		    s := '';
                  end;
              until s = '';
          end;
    end;


  { Living Thing }

  procedure LivingThing.Speak;
    begin
      Output( _Silence );
    end;

  function LivingThing.Die( weapon: string ): boolean;
    begin
      dead := TRUE;
      Die  := TRUE;
    end;

  procedure LivingThing.Acept( gift: PThing );
    begin
      abstract
    end;

  { Linking }

  constructor Linking.Init( nme, desc, keyword, pscm: string ; destt: PThing );
    begin
      Thing.Init( nme, desc, succ(LWeight) );
      destination := destt;
      passcomment := newStr( pscm );
      if keyword = OpenDoor
        then
          begin
	    key := '';
	    opn := TRUE
          end
	else key := keyword;
    end;

  destructor Linking.Done;
    begin
      disposeStr( passcomment );
      Thing.Done;
    end;

  function Linking.Open( psKey: string ): boolean;
    begin
      opn  := (key = '') or (upper(psKey) = upper(key));
      Open := opn;
    end;

  procedure Linking.Pass( body: PThing );
    begin
      Output( passcomment^ );
    end;

  procedure Linking.Close;
    begin
      opn := FALSE
    end;

  function Linking.Dest: PThing;
    begin
      if opn
	then Dest := destination
	else Dest := nil;
    end;

  { Room }

  procedure Room.Describe;
    var
      i: byte;
    begin
      for i :=	0 to pred( count ) do
        Output( PThing(At(i))^.name^ );
    end;

  function Room.Get ( nm: string ): PThing;

    function ExactNameMatch( item: PThing ): boolean; far;
      var
	s: string;
      begin
	s := item^.name^;
        Normalize( s );
	ExactNameMatch := upper(s) = upper(nm)
      end;

    function NonExactNameMatch( item: PThing ): boolean; far;
      var
	s: string;
      begin
	s := item^.name^;
        Normalize( s );
	NonExactNameMatch := Equals( upper(s), nm )
      end;

    var
      T: PThing;
    begin
      Normalize( nm );
      T := FirstThat( @ExactNameMatch );
      if T = nil
	then T := FirstThat( @NonExactNameMatch );
      Get := T
    end;

  function Room.Take( nm: string ): PThing;
    var
      auxP: pointer;
    begin
      auxP := Get( nm );
      Take := auxP;
      if auxP <> nil
        then Delete( auxP );
    end;

  procedure Room.Open( nm, psKey: string );
    var
      auxT: PLinking;
    begin
      PThing(auxT) := Get( nm );
      if auxT <> nil
        then
          if (typeof( auxT^ ) = typeof( Linking )) or (typeof( auxT^ ) = typeof( DangerLink )) or
             (typeof( auxT^ ) = typeof( RiddleLink )) or (typeof( auxT^ ) = typeof( DangerLink2 )) or
             (typeof( auxT^ ) = typeof( OpenLink ))
            then
              if auxT^.opn
                then Output( _It_is_open )
                else
                  begin
                    if auxT^.Open( psKey )
                      then
                        begin
                          if typeof( auxT^.Dest^ ) = typeof( Room )
                            then
                              begin
				PThing(auxT) := PRoom(auxT^.Dest)^.Get( nm );
                                if auxT <> nil
                                  then auxT^.Open( psKey )
                                  else Output( _Door_warning );
                              end;
                          Output( _Ok );
                        end
                      else
                        if typeof( auxT^ ) <> typeof( RiddleLink )
                          then
                            begin
                              Output( _You_try_but_you_can_not );
                              if psKey = ''
                                then Output( _You_need_a_password )
                                else Output( _Quotes + psKey + _Quotes + _Is_not_the_password );
                            end
                  end
            else Output( _Can_not_do_this )
        else
          if nm <> ''
            then Output( _Can_not_do_this + _Blank + _There_is_not + nm + _In_the_room )
            else Output( _Complete );
    end;

  procedure Room.Break( nm, nw: string );
    var
      whatP: PHidden;
      hiddn: PThing;
    begin
      PThing(whatP) :=	Get( nm );
      if whatP <> nil
        then
          if typeof( whatP^ ) = typeof( Hidden )
            then
              if whatP^.Break( nw )
                then
                  begin
		    hiddn := whatP^.hiddenThing;
		    AtInsert( IndexOf(whatP), hiddn );
                    Delete( whatP );
                    Output( _Crashh );
		    Output( _Surprise );
                  end
                else Output( _Can_not_break )
            else Output( _This_is_not_breakable )
        else
          if nm <> ''
            then Output( _Can_not_do_this + _Blank + _There_is_not + nm + _In_the_room )
            else Output( _Complete );
    end;

  { Suitcase }

  procedure Suitcase.Describe;
    var
      i: byte;
      s: string;
    begin
      for i :=	0 to pred( count ) do
        begin
	  str( PThing(At(i))^.mase, s );
          Output( PThing(At(i))^.name^ + ' (' + s + ')' );
        end;
      i := LWeight - Heaviness;
      if not Empty
        then
          if i = 0
            then Output( 'Usted no puede ni con un  tomo m s.' )
            else
              if i = 1
                then Output( 'Usted est  a punto de agotar sus capacidades.' )
                else
                  begin
		    str( i, s );
                    Output( 'Usted podr¡a cargar ' + s + ' bolsas m s.' );
                  end;
    end;

  function Suitcase.Empty: boolean;
    begin
      Empty :=	count = 0;
    end;

  function Suitcase.Heaviness: word;
    var
      w: word;
      i: byte;
    begin
      w := 0;
      if count > 0
        then
	  for i := 0 to pred(count) do
	    inc( w, PThing(At(i))^.mase );
      Heaviness := w;
    end;

  { Man }

  constructor Man.Init( nme, desc: string );
    begin
      Thing.Init( nme, desc, 0 );
      bag := new( PSuitcase, Init( '', '', 0 ));
    end;

  destructor Man.Done;
    begin
      dispose( bag, done );
    end;

  procedure Man.Ask( who: string );
    var
      whoP: PLivingThing;
    begin
      if dead
        then exit;
      PThing(whoP) := curr^.Get( who );
      if whoP <> nil
        then
          if (typeof(whoP^) = typeof(Troll)) or ((typeof(whoP^) = typeof(Guard)) or (typeof(whoP^) = typeof(TDaugther)))
            then whoP^.Speak
            else Output( _Talking_to_your_self )
        else
          if who <> ''
            then Output( _Quotes + who + _Quotes + _Is_not_here )
            else Output( _Complete )
    end;

  function Man.Die( weapon: string ): boolean;
    begin
      if dead
        then exit;
      LivingThing.Die( weapon );
      Output( _I_am_dying );
    end;

  procedure Man.Go( newRoom: PRoom  );
    begin
      if dead
        then exit;
      curr := newRoom;
      if not newRoom^.visited
        then
          begin
	    newRoom^.visited := true;
            inc( Visits )
          end;
    end;

  procedure Man.Look;
    begin
      if dead or not visible
        then exit;
      Tele^.Clear;
      Tele^.NewPaper;
      Output( _You_are_in + curr^.name^ + '.' );
      Output( curr^.descr^ );
      Output( _The_room_contains );
      curr^.Describe;
    end;

  procedure Man.Inventary;
    begin
      if dead
        then exit;
      if not bag^.Empty
        then
          begin
            Output( _The_bag_contains );
            bag^.Describe;
          end
        else Output( _Bag_is_empty );
    end;

  procedure Man.Kill( who, weapon: string );
    var
      whoP: PLivingThing;
      weap: PThing;
    begin
      if dead
        then exit;
      PThing(whoP) := curr^.Get( who );
      if whoP <> nil
        then
          if (typeof(whoP^) = typeof(Troll)) or ((typeof(whoP^) = typeof(Guard)) or (typeof(whoP^) = typeof(TDaugther)))
            then
              if (bag^.Get( weapon ) <> nil) or (weapon = '')
                then
                  if whoP^.Die( weapon )
                    then curr^.Free( whoP )
                    else
                else Output( _Quotes + weapon + _Quotes + _Is_not_into_the_bag )
            else Output( _Cant_kill_dead_thing )
        else
          if who <> ''
            then Output( _Quotes + who + _Quotes + _Is_not_here )
            else Output( _Complete )
    end;

  procedure Man.See( what: string );
    var
      whatP: PThing;
    begin
      if dead
        then exit;
      if what <> ''
        then
          begin
	    whatP := curr^.Get( what );
            if whatP <> nil
              then Output( whatP^.Image )
              else
                begin
		  whatP := bag^.Get( what );
                  if whatP <> nil
                    then Output( whatP^.Image )
                    else Output( _There_is_not + what + _In_the_room + _Either_in_your_bag );
                end;
          end
        else Output( _What_do_you_want_to_see );
    end;

  procedure Man.Take( what: string );
    var
      whatP: PThing;
    begin
      if dead
        then exit;
      whatP :=	curr^.Get( what );
      if whatP <> nil
        then
          if bag^.Heaviness + whatP^.mase <= LWeight
            then
              begin
                bag^.insert( curr^.Take( what ));
                Output( _Ok )
              end
            else
              if whatP^.mase > LWeight
                then Output( _Cant_take_this )
                else Output( _Bag_is_very_heavy )
        else
          if what <> ''
            then Output( _There_is_not + what + _In_the_room )
            else Output( _Complete )
    end;

  procedure Man.Leave( what: string );
    var
      whatP: PThing;
    begin
      if dead
        then exit;
      whatP :=	bag^.Get( what );
      if whatP <> nil
        then
          begin
            curr^.insert( bag^.Take( what ));
            Output( _Ok )
          end
        else
          if what <> ''
            then Output( _Quotes + what + _Quotes + _Is_not_into_the_bag )
            else Output( _Complete );
    end;

  procedure Man.Give( what, who: string );
    var
      whoP : PLivingThing;
      whatP: PThing;
    begin
      if (bag^.Empty)
        then Output( _Bag_is_empty )
        else
          begin
	    PThing(whoP) := curr^.Get( who );
            if whoP <> nil
              then
                if (typeof(whoP^) = typeof(Troll))
                  then
                    begin
		      whatP :=	bag^.Take( what );
                      if whatP <> nil
                        then
                          begin
                            whoP^.Acept( whatP );
			    dispose( whatP, done );
                          end
                        else Output( _Quotes + what + _Quotes + _Is_not_into_the_bag );
                    end
                  else Output( _Gift_is_not_accepted )
              else
                if who <> ''
                  then Output( _Quotes + who + _Quotes + _Is_not_here )
                  else Output( _Whos_gift_is_this );
          end;
    end;

  procedure Man.OpenD( door, key: string );
    begin
      if dead
        then exit;
      if key <> ''
        then
          begin
            Output( _You_invoke_magics_words );
            Output( key + '!!!' );
          end;
      curr^.Open( door, key );
    end;

  procedure Man.WalkT( door: string );
    var
      nextRoom: PRoom;
      link    : PLinking;
    begin
      if dead
        then exit;
      PThing(link) := curr^.Get( door );
      if link <> nil
        then
          if (typeof( link^ ) = typeof( Linking )) or (typeof( link^ ) = typeof( DangerLink )) or
             (typeof( link^ ) = typeof( DangerLink2 )) or (typeof( link^ ) = typeof( RiddleLink )) or
             (typeof( link^ ) = typeof( OpenLink ))
            then
              begin
		PThing(nextRoom) := link^.Dest;
                if nextRoom <> nil
                  then
                    begin
                      Go( nextRoom );
                      link^.Pass( @self );
                    end
                  else
                    begin
                      Output( _You_hit_your_head );
                      Ouch;
                      Output( _Will_be_easier_if_open );
                    end
              end
            else Output( _You_can_not_open_this )
        else
          if door <> ''
            then Output( _There_is_not + door + _In_the_room )
            else Output( _Complete )
    end;

  procedure Man.Drink( what: string );
    begin
    end;

  procedure Man.Eat( what: string );
    begin
    end;

  procedure Man.Break( what, how: string );
    begin
      if (bag^.Get( how ) <> nil) or (how = '')
	then curr^.Break( what, how )
        else Output( _Quotes + how + _Quotes + _Is_not_into_the_bag )
    end;

  procedure Man.Weigh( what: string );
    var
      t: PThing;
      s	: string;
    begin
      if bag^.Get( 'Balanza' ) <> nil
        then
          begin
	    t := bag^.Get( what );
            if t = nil
	      then t := curr^.Get( what );
            if t <> nil
              then
                if (typeof(t^) = typeof(Thing)) and (t^.mase <= LWeight)
                  then
		    if upper(t^.name^) <> 'BALANZA'
		      then
			begin
			  str( t^.mase, s );
			  if t^.mase = 1
			    then s := s + ' bolsa.'
			    else s := s + ' bolsas.';
			  Output( 'Usted coloca el objeto en el plato de la balanza.'#13+
				 'La aguja indica ' + s );
			end
		      else Output( 'Usted trata infructuosamente de colocar la balanza sobre ella misma.'  )
		  else Output( '­Se ha vuelto loco! ¨C¢mo va a pesar eso?' )
	      else
		if what = ''
		  then Output( _Complete )
		  else Output( 'No hay "' + what + '" en este lugar. Ni en sus pertenencias tampoco.' )
          end
        else Output( 'Usted no trae la balanza.' );
    end;

  procedure Man.LeaveAll;
    var
      i: integer;
      t: PThing;
    begin
     if bag^.count = 0
       then Output( _Your_bag_is_empty )
       else
         begin
           while bag^.count <> 0 do
             begin
	       t := bag^.At(0);
               curr^.Insert( t );
               bag^.Delete( t );
             end;
           Output( _You_let_your_bag_empty )
         end;
    end;

  { Troll }

  constructor Troll.Init( nm, ds, lk, hD, lD: string );
    begin
      Thing.Init( nm, ds, 100 );
      likeness := newStr( lk );
      hiData   := newStr( hD );
      lowData  := newStr( lD );
      happy    := FALSE;
    end;

  destructor Troll.Done;
    begin
      disposeStr( likeness );
      disposeStr( lowData );
      disposeStr( hiData );
      Thing.Done;
    end;

  procedure Troll.Speak;
    begin
      if happy
        then Output( HiData^ )
        else Output( LowData^ );
    end;

  procedure Troll.Acept( gift: PThing );
    begin
      happy :=	upper(gift^.name^) = upper(likeness^);
      if happy
        then Output( _Very_very_thanks )
        else Output( _Cool_thanks );
    end;

  function Troll.Die( weapon: string ): boolean;
    begin
      Output( _Ahhhhhh );
      LivingThing.Die( weapon );
    end;

  { OpenLink }

  constructor OpenLink.Init( nme, desc, pscm: string ; destt: PThing );
    begin
      Linking.Init( nme, desc, '', pscm, destt );
      opn := TRUE;
    end;

  { DangerLink }

  constructor DangerLink.Init( nm, desc, keyword, pscm, tlsm: string ; destt: PThing );
    begin
      Linking.Init( nm, desc, keyword, pscm, destt );
      talisman := newStr( tlsm );
    end;

  destructor DangerLink.Done;
    begin
      disposeStr( talisman );
      Linking.Done;
    end;

  procedure DangerLink.Pass( body: PThing );
    var
      auxP: PThing;
    begin
      auxP := PMan(body)^.bag^.Get( talisman^ );
      if auxP = nil
        then
          begin
            Output( _No_protection );
            PMan(body)^.Die( '' );
          end
        else Linking.Pass( body );
    end;

  { DangerLink2 }

  procedure DangerLink2.Pass( body: PThing );
    var
      auxP: PThing;
    begin
      auxP := PMan(body)^.bag^.Get( talisman^ );
      if auxP <> nil
        then
          begin
            Output( _Undesirable_object );
            PMan(body)^.Die( '' );
          end
        else Linking.Pass( body );
    end;

  { Hidden }

  constructor Hidden.Init( nm, desc, brk: string ; hdd: PThing );
    begin
      Thing.Init( nm, desc, succ(LWeight) );
      breaker := newStr( brk );
      hidd    := hdd;
    end;

  destructor Hidden.Done;
    begin
      disposeStr( breaker );
      dispose( hidd, done );
      Thing.Done;
    end;

  function Hidden.Break( weapon: string ): boolean;
    begin
      if breaker = nil
	then Break := true
	else Break := Equals( upper(breaker^), upper(weapon) );
    end;

  function Hidden.HiddenThing: PThing;
    begin
      HiddenThing := hidd
    end;

  { Guard }

  constructor Guard.Init( nm, ds, cnf, wp: string );
    begin
      Thing.Init( nm, ds, succ(LWeight) );
      confession := newStr( cnf );
      lethalweap := newStr( wp );
    end;

  destructor Guard.Done;
    begin
      disposeStr( confession );
      disposeStr( lethalweap );
      Thing.Done;
    end;

  function Guard.Die( weapon: string ): boolean;
    begin
      if Equals(upper(lethalweap^), upper(weapon))
        then
          begin
            Output( confession^ );
            LivingThing.Die( weapon );
          end
        else Output( _Ja_ja_ja );
      Die := dead;
    end;

  { Castle }

  constructor Castle.Init( mman: PMan ; vc: PLexObj );
    begin
      Thing.Init( '', '', 0 );
      m     := mman;
      voc   := vc;
      track := new( PHistColl, Init( 10, 5 ));
    end;

  destructor Castle.Done;
    begin
      dispose( track, done );
    end;

  procedure Castle.SaveTrack( f: string );
    begin
      if f = ''
        then exit;
      if track^.count > 1
        then
          begin
            if not track^.Save( f )
              then Output( _Output_error );
          end
        else Output( _Nothing_to_save );
    end;

  procedure Castle.Start;
    begin
      m^.Go( At(0) );
    end;

  procedure Castle.AskMan;
    begin
      Output( '' );
      Output( _What_do_you_want_to_do );
      wish := Tele^.Receive;
      if wish <> ''
	then wishback := wish;
      wish := upper( wish );
    end;

  procedure Castle.ClearWish;
    begin
      Clear( wish );
    end;

  procedure Castle.MakeManWish;
    var
      rest   : string;
      visBak : boolean;
    begin
      relevant := true;
      Tele^.SetState( stThinking );
      voc^.SetStr( wish );
      voc^.SetToken;
      voc^.SetStr( copy( wish, voc^.poss, length( wish ) - pred(voc^.poss) ));
      case voc^.IsKWord( voc^.token ) of
	vGo1, vGo2, vGo3, vGo4:
	  begin
	    visBak := visible;
	    visible := false;
	    Open;
	    visible := visBak;
	    Go;
	  end;
	vTake1, vTake2:
	  Take;
	vLeave1, vLeave2:
	  Leave;
	vOpen:
	  Open;
	vKill1, vKill2:
	  Kill;
	vPiss1, vPiss2:
	  Output( 'Usted se asegura de que nadie est  mirando y... Ah, ­qu‚ alivio!' );
	vCls:
	  Output( 'Recuerde que se encuentra dentro de La Fortaleza, y no en el sistema operativo.' );
	vLook1, vLook2:
	  if voc^.EOS
	    then Look
	    else See;
	vSee1, vSee2:
	  See;
	vBreak1, vBreak2, vBreak3:
	  Break;
	vAsk1, vAsk2:
	  Ask;
	vInvent:
          begin
            Inventary;
	    relevant := false;
          end;
	vGive1, vGive2:
	  Give;
	vQuit1, vQuit2:
          begin
            m^.Die( '' );
	    relevant := false
          end;
	vWeigh:
	  begin
	    m^.Weigh( voc^.st );
	    relevant := false
          end;
	vExec:
	  begin
	    Output( _Enter_file_name );
	    textcolor( 0 );
	    textbackground( 7 );
	    rest := Tele^.Receive;
	    ExecTrack( rest );
	    relevant := false;
	  end;
	vSave:
	  begin
	    Output( _Enter_file_name );
	    rest := Tele^.Receive;
	    if rest = ''
	      then rest := TrkName;
            SaveTrack( rest );
	    relevant := false;
	  end;
	vPerc:
	  begin
	    Percent;
	    relevant := false;
	  end;
	else
          begin
            if voc^.Token <> ''
              then Output( _I_dont_understand );
	    relevant := false;
          end;
      end;
      if relevant and (wishback <> '') and not executing
        then track^.Insert( newStr( wishback ));
    end;

  procedure Castle.Go;
    begin
      m^.WalkT( voc^.st );
    end;

  procedure Castle.Take;
    begin
      if voc^.IsKWord( voc^.st ) = vAll
        then Output( _Take_one_thing_only )
        else m^.Take( voc^.st )
    end;

  procedure Castle.Leave;
    begin
      if voc^.IsKWord( voc^.st ) = vAll
        then m^.LeaveAll
        else m^.Leave( voc^.st );
    end;

  procedure Castle.Open;
    var
      link: string;
      b   : byte;
    begin
      link := '';
      repeat
        voc^.SetToken;
	b := voc^.IsKWord( voc^.token );
        if not( b in [vWith,vSay1,vSay2])
	  then link :=	concat( link, _Blank, voc^.token );
      until (b in [vWith,vSay1,vSay2]) or voc^.EOS;
      system.delete( link, 1, 1 );
      if not voc^.EOS
	then m^.OpenD( link, copy( voc^.st, voc^.poss, length(voc^.st) - pred(voc^.poss) ))
	else m^.OpenD( link, '' );
    end;

  procedure Castle.Kill;
    var
      who: string;
      b  : byte;
    begin
      who := '';
      repeat
        voc^.SetToken;
	b := voc^.IsKWord( voc^.token );
        if b <> vWith
	  then who := concat( who, _Blank, voc^.token );
      until (b = vWith) or voc^.EOS;
      system.delete( who, 1, 1 );
      if not voc^.EOS
	then m^.Kill( who, copy( voc^.st, voc^.poss, length(voc^.st) - pred(voc^.poss) ))
	else m^.Kill( who, '' );
    end;

  procedure Castle.Percent;
    var
      s: string;
    begin
      str( round(m^.Visits/pred(count)*100), s );
      Output( 'Usted ha avanzado un ' + s + '%' );
    end;

  procedure Castle.Look;
    begin
      m^.Look
    end;

  procedure Castle.See;
    begin
      m^.See( voc^.st );
    end;

  procedure Castle.Break;
    var
      what: string;
      b   : byte;
    begin
      what := '';
      repeat
        voc^.SetToken;
	b := voc^.IsKWord( voc^.token );
        if b <> vWith
	  then what :=	concat( what, _Blank, voc^.token );
      until (b = vWith) or voc^.EOS;
      system.delete( what, 1, 1 );
      if not voc^.EOS
	then m^.Break( what, copy( voc^.st, voc^.poss, length(voc^.st) - pred(voc^.poss) ))
	else m^.Break( what, '' );
    end;

  procedure Castle.Ask;
    begin
      m^.Ask( voc^.st );
    end;

  procedure Castle.Inventary;
    begin
      m^.Inventary;
    end;

  procedure Castle.Give;
    var
      what: string;
      b   : byte;
    begin
      what := '';
      repeat
        voc^.SetToken;
	b := voc^.IsKWord( voc^.token );
        if b <> vTo
	  then what :=	concat( what, _Blank, voc^.token );
      until (b = vTo) or voc^.EOS;
      system.delete( what, 1, 1 );
      if not voc^.EOS
	then m^.Give( what, copy( voc^.st, voc^.poss, length(voc^.st) - pred(voc^.poss) ))
	else m^.Give( what, '' );
    end;

  function Castle.ExecTrack( f: string ): boolean;
    var
      i 	  : word;
      stop, VisBak: boolean;
    begin
      VisBak := Visible;
      Output( 'Ejecutando el rastro...' );
      if not VerboseExec
	then Visible := false;
      if f = ''
        then exit;
      if track <> nil
	then dispose( track, done );
      track :=	new( PHistColl, Init( 10, 5 ));
      Tele^.SetHistory( PHistColl(track) );
      if track^.Load( f )
        then
          begin
	    i	      := 0;
	    stop      := FALSE;
	    executing := TRUE;
            repeat
	      wish := PString( track^.At(i) )^;
              Output( '' );
              Output( ' ' + wish );
              ClearWish;
              MakeManWish;
              inc( i );
            until Goal or IsOver or (i = track^.count);
	    executing := FALSE
          end
	else
	  begin
	    Visible :=	true;
	    Output( _File_not_found )
	  end;
      Visible := VisBak
    end;

  function Castle.Input: string;
    begin
    end;

  function Castle.IsOver: boolean;
    begin
      IsOver := m^.dead;
    end;

  function Castle.Goal: boolean;
    begin
      Goal := false
    end;

  { Riddle Link }

  constructor RiddleLink.Init( nm, desc, rddle, answ, pscm: string ; destt: PThing );
    begin
      Linking.Init( nm, desc, '', pscm, destt );
      riddle := newStr( rddle );
      answer := newStr( answ );
    end;

  destructor RiddleLink.Done;
    begin
      disposeStr( riddle );
      disposeStr( answer );
    end;

  function RiddleLink.Open( psKey: string ): boolean;
    begin
      if upper(psKey) = upper(answer^)
        then
          begin
            Output( _You_solved_the_riddle );
            Linking.Open( '' );
	    Open := TRUE;
          end
        else
          begin
            if psKey = ''
              then
                begin
                  Output( _Must_solve_riddle_first );
                  Output( riddle^ );
                end
              else
                begin
                  Output( _Wrong_answer );
                  Output( riddle^ );
                end;
	    Open := FALSE;
          end
    end;

  function TDaugther.Die( weapon: string ): boolean;
    begin
      if upper(weapon) = upper(lethalweap^)
        then
          begin
            Output( confession^ );
            LivingThing.Die( weapon );
          end
        else
          begin
            Output( 'Usted fracasa en su intento. La enorme serpiente se lanza sobre usted '+
                    'y lo devora en pocos segundos.' );
            ManX^.Die( '' );
          end;
      Die := dead;
    end;

end.