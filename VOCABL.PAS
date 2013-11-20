unit Vocabl;

interface

  uses Crt, Lexic, Util;

  const
    vGo1    =  1;
    vGo2    =  2;
    vGo3    = 30;
    vTake1  =  3;
    vTake2  =  4;
    vLeave1 =  5;
    vLeave2 =  6;
    vOpen   =  7;
    vKill1  =  8;
    vKill2  =  9;
    vLook1  = 10;
    vLook2  = 11;
    vSee1   = 12;
    vSee2   = 13;
    vBreak1 = 14;
    vBreak2 = 15;
    vBreak3 = 29;
    vAsk1   = 16;
    vAsk2   = 17;
    vInvent = 18;
    vGive1  = 19;
    vGive2  = 20;
    vWith   = 21;
    vTo     = 22;
    vQuit1  = 23;
    vQuit2  = 24;
    vSay1   = 25;
    vSay2   = 26;
    vExec   = 27;
    vSave   = 28;
    vPerc   = 31;
    vAll    = 32;
    vWeigh  = 33;
    vPiss1  = 34;
    vPiss2  = 35;
    vCls    = 36;
    vGo4    = 37;

    _Blank                   = ' ';
    _Quotes                  = '"';
    _Ok                      = 'Ok.';
    _Surprise		     = '­Usted ha descubierto algo!';
    _The_room_contains       = 'Usted ve:';
    _You_are_in              = 'Usted se encuentra en ';
    _The_bag_contains        = 'Sus pertenecias son:';
    _You_try_but_you_can_not = 'Usted trata de abrir, pero no puede lograrlo.';
    _It_is_open              = 'No es necesario.';
    _Door_warning            = 'Tenga cuidado. Por aqu¡ se puede entrar, pero no se puede salir.';
    _Is_not_the_password     = ' no es la contrase¤a.';
    _You_need_a_password     = 'Necesita unas palabras m gicas.';
    _Can_not_do_this         = 'No puede hacer eso.';
    _Cant_kill_dead_thing    = 'No puede matar a algo que nunca tuvo vida.';
    _Why_me                  = '¨Por qu‚ hizo eso? No era necesario matarle.';
    _There_is_not            = 'No existe "';
    _In_the_room             = '" en este lugar.';
    _Is_not_into_the_bag     = ' no est  dentro de sus pertenencias.';
    _Either_in_your_bag      = ' Entre sus pertenencias tampoco.';
    _Whos_gift_is_this       = '¨Y para qui‚n es? ¨O es un obsequio suyo para s¡ mismo?';
    _What_do_you_want_to_see = '¨Ver qu‚?';
    _Is_not_here             = ' no est  aqu¡.';
    _Here                    = '" aqu¡.';
    _Bag_is_very_heavy       = 'Ser¡a demasiado peso.';
    _Cant_take_this          = 'Usted no puede cargar con eso.';
    _Bag_is_empty            = 'Usted no lleva nada consigo.';
    _I_am_dying              = 'Lamento informarle que usted est  muerto.';
    _You_invoke_magics_words = 'Usted se arrodilla, levanta los brazos y dice:';
    _You_hit_your_head       = 'OUCH! Usted se ha golpeado las narices.';
    _Will_be_easier_if_open  = 'Trate de abrir antes.';
    _You_can_not_open_this   = 'Imposible de abrir.';
    _Very_very_thanks        = 'Muchas gracias. Hace mucho que esperaba por esto.';
    _Cool_thanks             = 'Qu‚ amable! Gracias...';
    _Gift_is_not_accepted    = 'Su regalo no es aceptado.';
    _Talking_to_your_self    = '¨Hablando solo?';
    _Silence                 = 'No desea hablar con usted.';
    _No_protection           = 'No debi¢ cruzar desprotegido.';
    _Undesirable_object      = 'Usted llevaba un objeto que le impidi¢ cruzar.';
    _Can_not_break           = 'Usted trata, pero no lo consigue.';
    _This_is_not_breakable   = 'Usted no puede romper eso.';
    _Ahhhhhh                 = 'AAAAARRRGGGGG!!!';
    _Crashh                  = 'CRASSSHHH!!!';
    _Ja_ja_ja                = 'Todos sus esfuerzos son en vano. Probablemente no est‚ usando el objeto indicado.';
    _Must_solve_riddle_first = 'Debe resolver este acertijo:';
    _Must_answer             = 'Trate de esta forma: "Abrir tal cosa con tal respuesta".';
    _You_solved_the_riddle   = 'Usted ha descifrado el acertijo correctamente.';
    _Wrong_answer            = 'Esa no es la respuesta.';
    _What_do_you_want_to_do  = '¨Qu‚ desea hacer?';
    _I_dont_understand       = 'No le comprendo.';
    _Enter_file_name         = '¨Nombre del fichero rastro?';
    _Wanna_stop              = '¨Desea interrumpir la ejecuci¢n (S/N)?';
    _Output_error            = 'Error salvando fichero rastro.';
    _File_not_found          = 'Fichero rastro no encontrado.';
    _Nothing_to_save         = 'No hay nada que salvar.';
    _Take_one_thing_only     = 'Mejor tome las cosas una a una.';
    _You_let_your_bag_empty  = 'Usted deja todas sus pertencias en el suelo.';
    _Your_bag_is_empty       = 'Usted no lleva nada consigo.';
    _Complete                = 'Complete la oraci¢n. No sea ambiguo.';

  type
    Line        = string[80];
    PSimplifier = ^Simplifier;
    Simplifier  = object( LexObj )
                    procedure Clear;
		    function  SameMeaning( str1, str2 : string ) : boolean;
                  end;

  procedure Clear( var s : string );
  function  SameMeaning( str1, str2 : string ) : boolean;
  procedure FadeLine( dlay : byte ; s : Line );
  procedure Normalize( var s : string );

  var
    l   : PSimplifier;
    voc : PLexObj;

implementation

  const
    Spanish : string = ' ‚¡¢£¤¥';
    English : string = 'aeiounN';

  procedure Normalize( var s : string );
    var
      i : integer;
      p : integer;
    begin
      for i := 1 to length(Spanish) do
        begin
          repeat
	    p := pos( Spanish[i], s );
            if p <> 0
              then s[p] := English[i]
          until p = 0;
        end;
    end;

  procedure Simplifier.Clear;
    var
      auxS : string;
    begin
      auxS := '';
      while not EOS do
        begin
          SetToken;
          if IsKWord( token ) = 0
	    then auxS := concat( auxS, ' ', token )
	end;
      Normalize( auxS );
      SetStr( auxS );
    end;

  function Simplifier.SameMeaning( str1, str2 : string ) : boolean;
    var
      auxS : string;
    begin
      Normalize( str1 );
      Normalize( str2 );
      SetStr( str2 );
      FormatStr;
      Clear;
      auxS := st;
      SetStr( str1 );
      FormatStr;
      Normalize( st   );
      Normalize( auxS );
      SameMeaning := st = auxS;
    end;

  const
    Sets  : SetType = ( allowed   : [#0..#255];
		        unallowed : [];
		        clase     : Identifier );

    KWarr : array[1..4] of string = ( 'LA',
			              'EL',
			              'POR',
			              'AL' );

    ComAr : array[1..37] of string =
    ( 'ATRAVESAR', 'IR', 'TOMAR', 'COGER', 'SOLTAR', 'DEJAR',
      'ABRIR', 'MATAR', 'ASESINAR', 'OBSERVAR', 'MIRAR', 'LEER',
      'VER', 'ROMPER', 'FORZAR', 'PREGUNTAR', 'INTERROGAR', 'INVENTARIO',
      'REGALAR', 'DAR', 'CON', 'A', 'ABANDONAR', 'TERMINAR', 'RESPONDIENDO',
      'DICIENDO', 'EJECUTAR', 'SALVAR', 'DESTROZAR', 'CRUZAR',
      'PORCIENTO', 'TODO', 'PESAR', 'MIAR', 'ORINAR', 'CLS', 'PASAR' );

    LexDta : LexData = ( StrId   : '''';
		         ComOp   : '{';
		         ComClos : '}';
		         UnvSep  : ' ' );

  procedure Clear( var s : string );
    begin
      l^.SetStr( s );
      l^.Clear;
      s := upper(l^.st);
    end;

  function SameMeaning( str1, str2 : string ) : boolean;
    begin
      SameMeaning := l^.SameMeaning( str1, str2 )
    end;

procedure FadeLine( dlay : byte ; s : Line );
  var
    xS : set of byte;
    i  : byte;
    x  : byte;
    xx : byte;
    yy : byte;
  begin
    {
    for i := 1 to length(s) do
      begin
        if s[i] = #13
          then writeln
          else write(s[i]);
        delay( random(dlay) );
      end;
    writeln;
    }
    if s <> ''
      then
        begin
          Randomize;
          i  := 0;
          xS := [];
          xx := whereX;
          yy := whereY;
          repeat
            x := succ(random( length(s) ));
            if not( x in xS )
	      then
	        begin
	          inc( i );
                  if s[x] <> ' '
                    then
                      begin
			gotoxy( xx + pred(x), yy );
	                write( s[x] );
                      end;
	          xS := xS + [x];
	          delay( dlay );
	        end;
          until i = length( s );
	  gotoxy( xx + pred(i), yy );
        end;
    writeln;
  end;

begin
  l   := new( PSimplifier, Init( @KWarr, @Sets,  4, 1, LexDta ));
  voc := new( PLexObj	 , Init( @ComAr, @Sets, 36, 1, LexDta ));
end.