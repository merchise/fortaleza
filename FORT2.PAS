program Fort2;

uses
  Util,
  Crt, Dos, Win, Objects, Vocabl, Castles,
  CmdLine, Advic, Letters, Teletype, HistTTY, TTY, Present2, Instr2;

const
  NRooms  = 55;
  LRooms  = 19;
  CmmLN   = 20;
  _VictAt = 10;
  _TrackF = 'TRAVEL.TRK';

type
  HelpArr  = array[ 1..25 ] of string;
  RoomsAr  = array[ 1..NRooms ] of PRoom;
  RoomData = record
               name : string[80];
               desc : string;
             end;

  PFort    = ^Fort;
  Fort     = object( Castle )
               function Goal : boolean; virtual;
             end;

  procedure SuccessSound; forward;
  procedure DefeatSound;  forward;

  function Fort.Goal : boolean;
    const
      SourcerDead  : boolean = false;
      DaugtherDead : boolean = false;

    procedure SourcererDie;
      begin
        Output( 'Usted solo alcanza a herir al Hechicero, que ha desaparecido misteriosamente.' );
        Output( 'Se escucha una voz que dice: "≠Est£pido! Vas por el camino equivocado."' );
      end;

    procedure DaugtherDie;
      begin
        Output( 'En el lugar que ocupaba la Hija del Hechicero ha aparecido un objeto.' );
	PRoom(At(45))^.Insert( new( PThing, Init( 'C†liz', 'Tiene grabadas las siguientes palabras:'#13#13+
						   ' "Lsmra elshrne o:'#13+
                                                   '  Rs imnee od e ao'#13+
                                                   '  Bt ecrnee aoil pet'#13+
                                                   '  Atrh ne urod usee'#13+
                                                   '  E nloeeiojnoa bn'#13+
                                                   '  Ecd eaulse acua elshrne'#13+
                                                   '  Epj el iadlhcieoe ucat'#13+
						   '  Pnuoe lslnd ua"', 3 )));
      end;

    begin
      if (PRoom( At(54) )^.Get( 'Hechicero' ) = nil) and not SourcerDead
        then
          begin
            SourcererDie;
            SourcerDead := true
          end;
      if (PRoom( At(45) )^.Get( 'Hija del Hechicero' ) = nil) and not DaugtherDead
        then
          begin
            DaugtherDie;
            DaugtherDead := true
          end;
      if PRoom( At(6) )^.Get( 'Pa§uelo' ) <> nil
        then ManX^.Die( '' );
      Goal := (PRoom( At(30) )^.Get( 'Rosa diamante' ) <> nil) and
              (PRoom( At(11) )^.Get( 'Bote' ) <> nil) and
              (PRoom( At(0) )^.Get( 'Antorcha' ) <> nil) and
              (PRoom( At(42) )^.Get( 'Cinta de Moebius' ) <> nil) and
              (PRoom( At(39) )^.Get( 'Escudo de Aquiles' ) <> nil) and
              (PRoom( At(3) )^.Get( 'Espejo' ) <> nil) and
              (PRoom( At(2) )^.Get( 'PÇndulo' ) <> nil) and
              (PRoom( At(45) )^.Get( 'Hija del Hechicero' ) = nil) and
              (PRoom( At(8) )^.Get( 'Monstruo' ) = nil)
    end;

  const
    RoomAr : array[ 1..NRooms ] of RoomData =
     (( name: 'una habitaci¢n para huÇspedes';
	desc: 'Est† tan oscura que usted cree que las paredes y el techo se han '+
	      'avalanzado sobre su cuerpo. En la pared que tiene delante se distingue un plateado hilo de luz. '+
	      'Es el filo de una puerta.' ),
      ( name: 'el pasillo';
	desc: 'Hay seis puertas distribuidas simÇtricamente. Las paredes son de m†rmol blanco, pero usted '+
	      'tiene la certeza de que hay algo terrible encerrado detr†s de toda esa pulcritud.'),
      ( name: 'el Sal¢n de Fumar';
	desc: 'Hay sesenta y seis sillas en el sal¢n. Al lado de cada silla crece un tent†culo rosado '+
	      'con un pitillo en el extremo. Los pitillos humean.'),
      ( name: 'el cuarto de la hija del Hechicero';
	desc: 'Se pregunta c¢mo lucir°a la hija de un hechicero. En las paredes hay cientos de ' +
	      'retratos, todos de muchachas diferentes. ®Cu†l ser† la real?... ®O todas son una misma?'),
      ( name: 'la casa de mu§ecas';
	desc: 'Es tan peque§a como cualquier casa de mu§ecas. Usted no comprende c¢mo pudo entrar. Hay un ba£l en el fondo.'),
      ( name: 'el cuarto del Le§ador';
	desc: 'Las paredes, el suelo y el techo est†n hechos de madera. Usted camina con cuidado: '+
	      'hay espinas por todas partes.' ),
      ( name: 'la Cocina';
	desc: 'En realidad, se parece mucho m†s a un matadero. El olor a sangre coagulada y carro§a no le permite '+
	      'apartar el pa§uelo de la nariz. Hay unas marcas de sangre en la pared que le llaman mucho la '+
	      'atenci¢n: fueron hechas por una mano de siete dedos.' ),
      ( name: 'las Terrazas';
	desc: 'No puede reprimir su asombro: las terrazas est†n invertidas. Usted se siente muy natural parado '+
	      'cabeza abajo. Se escucha el correr de un r°o.' ),
      ( name: 'el calabozo del Monstruo';
	desc: 'Las paredes son de barro. Hay cientos de cadenas embotadas en el techo, moviÇndose constantemente, '+
	      'como si las arrastrara un viento de acero.' ),
      ( name: 'el interior del ba£l';
	desc: 'Ahora s° est† confundido. El ba£l es inmensamente mayor que la '+
	      'casa de mu§ecas, a pesar de que est† dentro de ella. Luce como una habitaci¢n '+
	      'cualquiera.' ),
      ( name: 'una orilla del R°o Negro';
	desc: 'Las aguas del R°o Negro hacen honor a su nombre. M†s que aguas parecen una mezcla de muerte y olvido. '),
      ( name: 'una orillas del R°o Negro';
	desc: 'La espesa niebla casi no deja ver las terrazas al otro lado.' ),
      ( name: 'los Jardines del Hechicero';
	desc: 'Son tan extensos que usted no puede ver d¢nde terminan. Todos los †rboles tienen '+
	      'el mismo tama§o y la misma forma. El jard°n parece un gran juego de espejos.' ),
      ( name: 'el Comedor';
	desc: 'La mesa es tan alta que usted no puede ver lo que hay servido. Alguien se lamenta all† '+
	      'arriba.' ),
      ( name: 'la Sastrer°a';
	desc: 'Parece la casa de una ara§a gigantesca. Hay hilos por todas partes.' ),
      ( name: 'el cuarto del jardinero';
	desc: 'Es una habitaci¢n muy modesta. A usted le sorprende que los instrumentos no sean de jardiner°a, '+
	      'sino de fabricar espejos.' ),
      ( name: 'la habitaci¢n de los tesoros';
	desc: 'Nunca hab°a visto tanta riqueza. Las paredes est†n forradas de l†minas de platino y hasta '+
	      'el fuego de las antorchas es de oro. Usted no comprende de d¢nde viene la luz.' ),
      ( name: 'el sal¢n de las velas';
	desc: 'Deben ser varios kil¢metros sembrados de velas. En el centro hay un c°rculo vac°o.' ),
      ( name: 'el cuarto del Inmortal';
	desc: 'Esta habitaci¢n luce m†s vieja que el resto de la Fortaleza. Hay muchas cosas colgadas de la pared: '+
	      'retratos, cartas, reconocimientos, estandartes y muchas telas de ara§as.' ),
      ( name: 'el cuarto de juguetes';
	desc: 'Hay miles de juguetes regados por todas partes. Usted siente deseos de volver a ser un ni§o.' ),
      ( name: 'las Ruinas';
	desc: 'Este lugar debe haber sido abandonado hace siglos. '+
	      'Usted trata de imaginar c¢mo eran las construcciones originalmente, pero no lo consigue. '+
	      'Al sur se extiende un desierto y al oeste se encuentra la casa del Ogro.'),
      ( name: 'el Sal¢n de Recepciones';
	desc: 'Todo est† muy sucio y descuidado. Un fuerte olor a carro§a le hace perder el equilibrio por momentos. '+
	      'Seguramente el Ogro usa este lugar para recibir a sus enemigos.' ),
      ( name: 'el cuarto de un pintor';
	desc: 'Hay muchos cuadros en las paredes, pero ninguno est† terminado.' ),
      ( name: 'el Patio Interior';
	desc: 'Por el patio est†n diseminados varios †rboles gigantescos, todos sin hojas. '+
	      'Parece como si el invierno reinase siempre en este lugar.' ),
      ( name: 'las habitaciones del Juglar';
	desc: 'El ambiente de la habitaci¢n le induce a creer que el juglar no era exactamente lo '+
	      'que se llama una persona alegre.' ),
      ( name: 'la alcoba del Ogro';
	desc: 'El aire se ha hecho casi irrespirable. Ahora usted comprende de d¢nde ven°a el mal olor '+
	      'reinante en el Sal¢n de Recepciones. Nunca antes hab°a estado en un lugar tan repulsivo.' ),
      ( name: 'los Subterr†neos';
	desc: 'Deben ser contempor†neos de las Ruinas. Usted siente como la humedad lo invade y le perfora los '+
	      'huesos.' ),
      ( name: 'las Catacumbas';
	desc: 'Nunca antes hab°a visto tantos esqueletos juntos. M†s que enterrados en ese lugar, parec°an haber '+
	      'muerto ah°. En el fondo usted divisa un hueco sin cad†ver con una inscripci¢n. La inscripci¢n '+
	      'dice: "Este es para t°".' ),
      ( name: 'el punto donde comienzan unas enormes cataratas';
	desc: 'Un repentino acceso de vÇrtigo hace que sus rodillas se doblen. A menos de un pie de donde usted '+
	      'se encuentra el agua se precipita hacia el abismo.' ),
      ( name: 'los bajos de las cataratas';
	desc: 'Hay un ruido ensordecedor, como si millones de tambores redoblaran al lado de sus t°mpanos. '+
	      'Usted siente como si su cabeza fuese a explotar.' ),
      ( name: 'fondo del Lago';
	desc: 'Contrariamente a lo que le dijeron en su infancia, usted puede respirar debajo del '+
	      'agua. Usted siente una paz extra§a al estar en el fondo del Lago, tal vez debida a posibles '+
	      'asociaciones subconcientes con su pasado embrionario, en el vientre de su madre.' ),
      ( name: 'la Cueva de Cristal';
	desc: 'Hay resplandores de cristales por todas partes. En este lugar el agua se ha hecho m†s densa '+
	      'y le resulta dif°cil respirar.' ),
      ( name: 'la orilla del Lago';
	desc: 'Frente a usted se extiende el Lago, de aguas claras y tranquilas.' ),
      ( name: 'un Oasis';
	desc: 'Es un oasis tradicional, con varias palmeras de d†tiles y un peque§o estanque de agua turbia '+
	      'en el centro.' ),
      ( name: 'la Catedral';
	desc: 'Es un lugar impresionante. Las paredes crecen hasta una altura incre°ble y se unen en una serie '+
	      'de simÇtricas torres. Usted se siente oprimido por la arquitectura, como si en realidad '+
	      'estuviese ante los ojos de Dios, en el d°a del juicio final.' ),
      ( name: 'el Desierto otra vez';
	desc: 'El calor lo asfixia. Usted no comprende c¢mo es posible que el clima var°e tanto de un lugar a '+
	      'otro de la Fortaleza.' ),
      ( name: 'un extenso valle';
	desc: 'Siente deseos de construir una casa y quedarse a vivir en el valle. Por todos '+
	      'lados crece una especie de †rbol frutal que, valiÇndose de dos manos que salen de su tronco, '+
	      'es capaz de cultivarse ella misma.' ),
      ( name: 'la cima del Pico Negro';
	desc: 'Nunca antes hab°a estado a tanta altura. Usted se pregunta por quÇ la monta§a es '+
	      'llamada "El Pico Negro" si en realidad est† cubierta de nieve.' ),
      ( name: 'la choza de un monje';
	desc: 'El suelo est† muy limpio, al igual que los muebles y las ventanas. Hay una gran cantidad de '+
	      'cuentas regadas por el suelo.' ),
      ( name: 'la Ciudad Abandonada';
	desc: 'A pesar de ser m†s antigua que las ruinas, la ciudad se conserva intacta. '+
	      'Usted oye el ruido de la gente en las calles y siente los olores de los alimentos en las '+
	      'cocinas, pero no son m†s que ilusiones. La ciudad est† abandonada desde hace siglos.' ),
      ( name: 'la choza del Sabio';
	desc: 'El lugar se ajusta perfectamente a su concepto de desorden. Usted se pregunta c¢mo el sabio puede '+
	      'vivir en semejante caos. Hay varios esqueletos, al parecer, una colecci¢n incipiente.' ),
      ( name: 'un campo cultivado';
	desc: 'Todos los sembrados parecen bastante descuidados. Probablemente el labrador no sea capaz de atender '+
	      'una cantidad tan grande de tierra al mismo tiempo.' ),
      ( name: 'el exterior de la Torre de Cristal';
	desc: 'La Torre de Cristal crece vertiginosamente hasta perderse entre las nubes.' ),
      ( name: 'la punta de la Torre de Cristal';
	desc: 'Probablemente se encuentre a varios kil¢metros de altura. Usted se alegra de que no hayan ventanas '+
	      'en el lugar.' ),
      ( name: 'la alcoba de la hija del Hechicero';
	desc: 'Esta es la alcoba donde la hija del Hechicero se alojaba temporalmente. Es muy c¢moda y tiene muchos '+
	      'cuadros iguales al que usted lleva.' ),
      ( name: 'la Alcoba Secreta';
	desc: 'Es mucho mayor que la otra alcoba. Es casi seguro que la hija del Hechicero viva '+
	      'en este lugar permanentemente.' ),
      ( name: 'los Calabozos';
	desc: 'Los calabozos est†n formados por varios pasillos paralelos, llenos de celdas a '+
	      'ambos lados.' ),
      ( name: 'una celda';
	desc: 'Debe ser un verdadero suplicio el estar encerrado aqu°. Todo el suelo est† cubierto de '+
	      'afiladas hojas, excepto en una esquina, donde se supone que estÇ el prisionero.' ),
      ( name: 'la Antesala de la Prueba';
	desc: 'Es un sal¢n circular. La luz del sol entra por unos vitrales rojos y el lugar luce como '+
	      'pintado con sangre.' ),
      ( name: 'el Sal¢n Verde';
	desc: 'Es un sal¢n de pruebas tradicional. Este tipo de sal¢n fue usado ampliamente por los horantes '+
	      'para educar a sus hijos.' ),
      ( name: 'el Sal¢n Azul';
	desc: 'Es un sal¢n de pruebas tradicional. Este tipo de sal¢n fue usado ampliamente por los horantes '+
	      'para educar a sus hijos.' ),
      ( name: 'el Sal¢n Blanco';
	desc: 'Es un sal¢n de pruebas tradicional. Este tipo de sal¢n fue usado ampliamente por los horantes '+
	      'para educar a sus hijos. Es el £ltimo de la prueba.' ),
      ( name: 'los l°mites de la Fortaleza';
	desc: 'A su derecha crece la tercera muralla, hasta una altura irracional. Usted no puede creer que aqu° '+
	      'termine la Fortaleza. Del otro lado de la muralla se escucha (usted no entiende c¢mo) el canto de los '+
	      'p†jaros y el sonido del viento en los †rboles.' ),
      ( name: 'la Pir†mide del Hechicero';
	desc: 'Es una construcci¢n gigantesca, a base de piedras. Al parecer, las piedras fueron colocadas sin '+
	      'orden alguno, olvidando las ventanas. El lugar est† iluminado con numerosas antorchas.' ),
      ( name: 'las Habitaciones del Hechicero';
	desc: 'Las habitaciones del Hechicero est†n dentro de una pir†mide interior. Todo es igual a la gran pir†mide, '+
	      'pero en una escala menor. Hay miles de espadas colgadas de la pared.' ));

procedure SetData( var rooms : RoomsAr );
  begin
    with rooms[1]^ do { Cuarto de huÇspedes }
      begin
	Insert( new( PLinking, Init( 'Puerta', 'En realidad, lo que usted puede distinguir es el '+
		     'delicado fil¢n de luz que deja escapar la uni¢n de la puerta y el marco.', '',
                     'Usted cierra los ojos, cegado por la luz.', rooms[2] )));
      end;
    with rooms[2]^ do { Pasillo }
      begin
	Insert( new( PLinking, Init( 'Puerta', 'Es de madera trabajada, una verdadera obra de arte.', '',
		     'Usted entra a la oscuridad nuevamente.', rooms[1] )));
	Insert( new( PLinking, Init( 'Puerta de espinos', 'Est† erizada de espinas. Usted tiene miedo '+
		     'hasta de acercarse.', '', 'Usted entra lentamente, tratando de no rozar la puerta.', rooms[6] )));
	Insert( new( PDangerLink, Init( 'Puerta de metal', 'Es de acero bru§ido. '+
		     'Tiene encima un cartel que dice "Cocina. C£brase la nariz."', '', 'Al pasar siente un olor muy fuerte, '+
                     'que lo envuelve y lo asfixia. Usted sobrevive gracias al pa§uelo que lleva consigo.',
                     'Pa§uelo', rooms[7] )));
	Insert( new( PLinking, Init( 'Puerta Negra', 'Usted ve unas delgadas cortinas de humo saliendo por '+
		     'debajo de la puerta.', '', 'Usted tose fuertemente, ha entrado al Sal¢n de Fumar.', rooms[3] )));
	Insert( new( PRiddleLink, Init( 'Puerta Azul', 'Es m†s peque§a que las puertas restantes.',
		     '®Cu†l es el nombre de la hija del Hechicero?', 'Aura',
                     'Usted entra a la alcoba de la hija del Hechicero.', rooms[4] )));
	Insert( new( PLinking, Init( 'Puerta de oro', 'Usted nunca hab°a visto tanto oro fundido en una misma pieza.',
		     '', 'El resplandor del oro lo ciega por un momento. Usted ha salido a las terrazas.', rooms[8] )));
	Insert( new( PGuard, Init( 'Grifo', 'Usted no logra distinguir si es un le¢n o un †guila. Parece dormido.',
		     'El grifo se contorsiona tratando de arrancarse la daga y grita: "≠Aura!".', 'Daga' )));
      end;
    with rooms[3]^ do { Sal¢n de fumar }
      begin
	Insert( new( PLinking, Init( 'Puerta Negra', 'La puerta por este lado est† muy manchada por el humo.', '',
		     'Usted sale del Sal¢n de Fumar. A fin puede respirar normalmente.', rooms[2] )));
	Insert( new( PThing, Init( 'Balanza', 'La balanza tiene el plato en forma de mano. La aguja es muy '+
				    'delgada, hecha con varios bigotes de gato trenzados. ', 1 )));
	Insert( new( PThing, Init( 'Inscripci¢n', 'La inscripci¢n dice:'#13+
				    'La muerte es un acto de la vida. Yo, la Bestia, he de morir como '+
                                    'he vivido. Esta es mi venganza, y t£ mismo ser†s el instrumento que '+
                                    'la lleve a cabo. La naturaleza humana es el arma m†s poderosa '+
				    'que puede utilizarse contra el hombre.', 1 )));
	Insert( new( PThing, Init( 'Piedra de Roseta', 'Esta no es la piedra original. Tiene grabadas las siguientes '+
				    'palabras:'#13#13+
                                    '"Fuimos grandes una vez,   ≥   Fio rne n e,atsd absi'#13+
                                    ' antes de la Bestia        ≥   Umsgadsuavz ne el eta"'#13#13+
				    'Ojal† Champolli¢n estuviera aqu°.', 5 )));
      end;
    with rooms[4]^ do { Hija del hechicero }
      begin
	Insert( new( PLinking, Init( 'Puerta Azul', 'Conduce al pasillo.',
		     '', 'Usted sale al pasillo.', rooms[2] )));
	Insert( new( PThing, Init( 'Pa§uelo', 'Tiene bordadas una A y una S.', 1 )));
	Insert( new( PThing, Init( 'Carta', 'La carta dice:'#13'"≠Dios te salve, mi £nica esperanza! '#13 +
				    'Mi padre me ha encerrado en la Torre de Cristal, que est† m†s all† del segundo r°o. '+
                                    'El sabe que solo yo podr°a mostrarte el camino de salida. B£scame."', 1 )));
	Insert( new( POpenLink, Init( 'Agujero', 'Parece una guarida de ratones.',
				       'Usted se agacha y (con grandes dolores en todos los huesos) atraviesa el agujero.',
                                       rooms[5] )));
      end;
    with rooms[5]^ do { Casa de mu§ecas }
      begin
	Insert( new( POpenLink, Init( 'Agujero', 'Es la salida de la casa de mu§ecas.',
				       'Usted regresa a la alcoba.', rooms[4] )));
	Insert( new( PHidden, Init( 'Ventana', 'Es de un cristal muy grueso. Usted trata de ver al otro lado, ' +
				     'pero la ventana es tan opaca que solo puede divisar algunas sombras moviÇndose.',
				     'Corta-cristales', new( POpenLink, Init( 'Pasadizo', '®A d¢nde conducir†?',
                                     'Usted oye una voz que le dice: "Usa tu equilibrio para vencer la corriente". Al cabo '+
				     'de varios minutos encuentra la salida.', rooms[13] )))));
	Insert( new( PLinking, Init( 'Puerta del ba£l', 'Parece muy antigua. Usted est† seguro de que ah° '+
				      'hay "gato encerrado".', 'MIAU', '≠Usted ha ca°do dentro del ba£l!', rooms[10] )));
      end;
    with rooms[6]^ do { Le§ador }
      begin
	Insert( new( PLinking, Init( 'Puerta de espinos', 'Al igual que del otro lado, est† erizada de espinas.',
		     '', 'Usted sale lentamente, tratando de no rozar la puerta.', rooms[2] )));
	Insert( new( PThing, Init( 'Daga', 'La empu§adura tiene forma de drag¢n.', 2 )));
	Insert( new( PThing, Init( 'Botella de vino', 'Parece una botella de agua sucia.', 3 )));
	Insert( new( PThing, Init( 'Hacha', 'Est† muy mohosa.', 17 )));
      end;
    with rooms[7]^ do { Cocina }
      begin
	Insert( new( PDangerLink, Init( 'Puerta de metal', 'Conduce al pasillo.',
		     '', 'Al salir puede apartar el pa§uelo de la nariz.', 'Pa§uelo', rooms[2] )));
	Insert( new( PThing, Init( 'Receta', 'Es una receta de cocina. Dice:'#13#13+
					       '  5 Ojos de rana'#13+
                                               '  1 Mano de gigante'#13+
                                               '  2 Cucharadas de purÇ de lombrices'#13+
                                               '  1 H°gado de muchacha virgen'#13 +
                                               '  9 Libras de az£car'#13+
                                               '  1 Tanque de agua del pantano verde'#13#13+
					       'Usted recuerda haber probado esto en alguna parte.', 1 )));
	Insert( new( PThing, Init( 'Muslo de carnero', 'M†s bien parece el muslo de una persona.', 10 )));
	Insert( new( PThing, Init( 'Pescado', '®QuÇ tiempo llevar† en este lugar?', 3 )));
      end;
    with rooms[8]^ do { Terrazas }
      begin
	Insert( new( PThing, Init( 'Inscripci¢n', 'La inscripci¢n dice:'#13+
				    '"No todos los dragones merecen la muerte."', 1 )));
	Insert( new( PLinking, Init( 'Puerta de oro', 'Usted nunca hab°a visto tanto oro fundido en una misma pieza.',
		     '', 'Usted regresa al pasillo. El resplandor del oro lo ciega por un momento.', rooms[2] )));
	Insert( new( POpenLink, Init( 'Escalera de caracol', 'Parece la bajada a un o°do gigante.',
				       'El viento helado que viene del fondo de la escalera lo envuelve '+
                                       'en continuos temblores.', rooms[11] )));
	Insert( new( PThing, Init( 'Reloj de arena', 'Usted escucha un callado tic-tac.', 2 )));
	Insert( new( PThing, Init( 'Silla', 'Es una silla para tomar el sol. Usted tiene la certeza de que hab°a alguien '+
				    'sentado en ella cuando entr¢ a las terrazas.', 5 )));
      end;
    with rooms[9]^ do { Monstruo }
      begin
	Insert( new( POpenLink, Init( 'Escalera de caracol', 'Conduce a las terrazas',
				       'Su condicionamiento euclidiano le impide comprender c¢mo es posible que una misma '+
                                       'escalera sea origen y destino de tres lugares distintos a la vez.'#13 +
                                       'Usted ha subido a las terrazas.',
                                       rooms[8] )));
	Insert( new( PThing, Init( 'Inscripci¢n', 'La inscripci¢n dice:'#13'"No alimente al monstruo."', 1 )));
	Insert( new( PTroll, Init( 'Monstruo', 'El Monstruo est† encadenado a la pared. Usted aparta la '+
				    'vista r†pidamente. Nunca hab°a visto tanta fealdad concentrada en una criatura.',
                                    'Muslo de carnero','≠T£ cuidarte de Hechicero! ≠Hechicero ser malo! ≠Malo! ≠Muy malo!'#13+
                                    'Hechicero puso yo feo. A t£ no poner feo... ≠A t£ arrancal tripa, sacal ojo, '+
                                    'rompel hueso y echal dragr¢n hambroso!'#13 +
                                    'Yo consejo t£: Busca espada Marmidosa... ≠y pincha todo!', '≠Grrrr! ≠Hambre!' )));
      end;
    with rooms[10]^ do { Ba£l }
      begin
	Insert( new( PLinking, Init( 'Puerta del ba£l', 'Est† en el techo.',
		     '', 'Usted sale del ba£l y vuelve a sentir la estrechez de la casa de mu§ecas.', rooms[5] )));
	Insert( new( PThing, Init( 'Piedra verde', 'Es incre°blemente s¢lida.', 9 )));
	Insert( new( PTroll, Init( 'Gato', 'Est† concentrado en sacarle las £ltimas part°culas de carne a una '+
				    'cabeza de pescado.', 'Pescado', 'La piedra verde te servir† para romper la '+
				    'segunda muralla.', '≠No molestes!' )));
      end;
    with rooms[11]^ do { Orilla 1 }
      begin
	Insert( new( POpenLink, Init( 'Escalera de caracol', 'Contrariamente a lo que usted espera, '+
				       'la escalera en este lugar asciende hasta el calabozo del Monstruo.',
                                       'Usted sube durante unos minutos y llega al calabozo del Monstruo.',
                                       rooms[9] )));
	Insert( new( PTroll, Init( 'Caronte', 'Una capucha negra esconde su rostro. Por '+
				    'una de las mangas de su vestimenta asoma una mano descarnada casi hasta el hueso. '+
				    'Usted se alegra de no poder ver su cara.', 'Reloj de arena',
                                    'Dentro del blanco est† la llave de la muralla.',
                                    'Tr†eme el reloj de arena, pero v°ralo antes de entreg†rmelo. ' )));
	Insert( new( PThing, Init( 'Bote', 'Es el cÇlebre bote de Caronte.', pred(LWeight) )));
	Insert( new( POpenLink, Init( 'R°o Negro', 'Es el Estigia.',
				       'Usted se sumerge en las oscuras aguas del Estigia (tiene miedo de montar el '+
                                       'bote de Caronte). Pocos mortales se han atrevido '+
                                       'a tanto. Al poco rato est† del otro lado.', rooms[12] )));
      end;
    with rooms[12]^ do { Orilla 2 }
      begin
	Insert( new( POpenLink, Init( 'R°o Negro', 'Es el Estigia.', 'Usted regresa nadando a la otra orilla.', rooms[11])));
	Insert( new( PHidden, Init( 'Arbol de marfil', 'Es infinitamente blanco.',
				     'Hacha', new( PThing, Init( 'Maza', 'Es muy pesada.', LWeight - 3 )))));
	Insert( new( PHidden, Init( 'Muralla', 'Al lado de esta, la Gran Muralla China es el juego de un ni§o en la arena.',
				     'Maza', new( POpenLink, Init( 'Avenida de hierro', 'Toda la avenida est† rodeada '+
                                     'de †rboles de metal. Usted se cubre los o°dos tratando de escapar de los chirridos '+
                                     'provocados por el viento en las hojas.',
				     'Usted camina durante varios minutos hasta salir de la avenida.', rooms[13] )))));
      end;
    with rooms[13]^ do { Jardines }
      begin
	Insert( new( POpenLink, Init( 'Avenida de hierro', 'Toda la avenida est† rodeada '+
                                       'de †rboles de metal. Usted se cubre los o°dos tratando de escapar de los chirridos '+
                                       'provocados por el viento en las hojas.',
				       'Usted camina durante varios minutos hasta regresar al r°o.', rooms[12] )));
	Insert( new( PLinking, Init( 'Puerta de madera', 'Es una puerta bastante vulgar. Conduce al comedor.',
				      '', 'Usted entra al comedor.', rooms[14] )));
	Insert( new( PLinking, Init( 'Puerta amarilla', 'Conduce al cuarto del tesoro.',
				      'Omicuos Ihanti', 'Usted entra al cuarto del tesoro. Los resplandores de las piedras '+
                                      'preciosas lo ciegan por unos instantes.', rooms[17] )));
	Insert( new( PLinking, Init( 'Puerta de tela', 'La tela de la puerta es tan dura como cualquier acero.',
				      '', 'Usted entra a las habitaciones del sastre.', rooms[15] )));
	Insert( new( PLinking, Init( 'Puerta verde', 'Conduce a las habitaciones del jardinero.',
				      '', 'Usted entra a las habitaciones del jardinero.', rooms[16] )));
	Insert( new( PLinking, Init( 'Puerta roja', 'Conduce al sal¢n de las velas. La puerta est† caliente.',
				      '', 'Usted entra al sal¢n de las velas.', rooms[18] )));
	Insert( new( PThing, Init( 'Piedra', 'Es una piedra com£n. Usted se pregunta quÇ hace en la Fortaleza, '+
				    'donde todo es tan ex¢tico.', 5 )));
	Insert( new( PTroll, Init( 'Jardinero', 'Es un anciano peque§o y encorvado.', 'Hacha',
				    'En tu camino encontrar†s varios anillos. Debes guardar el que t£ consideres m†s '+
                                    'apropiado, el que se ajuste m†s a tu esp°ritu y a tu empresa. Los otros anillos '+
                                    'solo te traer†n peligros y muerte. Elige bien.', 'El jardinero no le presta atenci¢n. '+
                                    'Est† muy ocupado cortando un abeto con una navaja.')));
      end;
    with rooms[14]^ do { Comedor }
      begin
	Insert( new( PLinking, Init( 'Puerta de Madera', 'Usted distingue algunas manchas de salsa en la puerta. '+
				      'Parece los comensales acostumbran a lanzarse la comida.',
                                      '', 'Usted sale del comedor.', rooms[13] )));
	Insert( new( PDangerLink, Init( 'T£nel', 'Usted se pregunta quÇ hace un t£nel en un comedor. '+
					 '≠No intente cruzar desprotegido!', OpenDoor,
                                         'Casi a mitad de camino usted es atacado por una bandada de murciÇlagos gigantes. '+
					 'Gracias al arco, usted logra ahuyentarlos.', 'Arco', rooms[49] )));
	Insert( new( PHidden, Init( 'Huevo', 'Por el tama§o debe ser el huevo de un dinosaurio. Y de uno grande.',
				     'Piedra', new( PTroll, Init ( 'Dinosaurio', 'Deb°a sentirse muy apretado en el huevo. '+
				     'Es un peque§o tiranosaurio.', 'Sonajero', 'Ma£llale al gato.'#13+
				     'Usted se sonr°e. Es una respuesta t°pica en un cachorro de dinosaurio.',
                                     '≠Guaaaaaa! ≠Guaaaaaa!'#13'Usted se pregunta con quÇ podr°a calmarlo.' )))));
      end;
    with rooms[15]^ do { Sastrer°a }
      begin
	Insert( new( PLinking, Init( 'Puerta de Tela', 'La tela de la puerta es tan dura como cualquier acero.',
				      '', 'Usted regresa al jard°n.', rooms[13] )));
	Insert( new( PThing, Init( 'Mu§eco diab¢lico', 'Es un artefacto de brujer°a. Representa a un hombre joven y '+
				    'tiene un alfiler clavado en una pierna.', 2 )));
	Insert( new( PThing, Init( 'Aguja', 'Es una aguja de plata, tan larga que usted se pregunta c¢mo el sastre '+
				    'puede coser con ella.', 1 )));
      end;
    with rooms[16]^ do { Jardinero }
      begin
	Insert( new( PLinking, Init( 'Puerta verde', 'Conduce al jard°n.', '',
				      'Usted sale de las habitaciones del jardinero.', rooms[13] )));
	Insert( new( PThing, Init( 'Corta-cristales', 'Tiene un diamante en la punta.', 3 )));
	Insert( new( PThing, Init( 'Sombrero', 'Es muy grande. Al jardinero no debe servirle.', 2 )));
      end;
    with rooms[17]^ do { Tesoros }
      begin
	Insert( new( PLinking, Init( 'Puerta amarilla', 'Conduce al jard°n.', '', 'Usted regresa a los jardines.',
				      rooms[13] )));
	Insert( new( PThing, Init( 'Rosa diamante', 'Es incre°blemete hermosa.', 3 )));
	Insert( new( PThing, Init( 'Anillo de oro', 'El anillo es sencillo. Solo un aro, sin ning£n tipo de adorno.', 1 )));
	Insert( new( PThing, Init( 'Arpa', 'Es un arpa de diciocho cuerdas.', 3 )));
	Insert( new( PThing, Init( 'Bolsa', 'Est† llena de oro.', 5 )));
      end;
    with rooms[18]^ do { Velas }
      begin
	Insert( new( PLinking, Init( 'Puerta roja', 'Conduce a los jardines.',
				      '', 'Usted regresa a los jardines.', rooms[13] )));
	Insert( new( PLinking, Init( 'Puerta blanca', 'Conduce al cuarto de juguetes.',
				      '', 'Usted entra al cuarto de juguetes.', rooms[20] )));
	Insert( new( POpenLink, Init( 'Escalera', 'Baja hasta el cuarto del Inmortal.',
				       'Usted desciende las escaleras y entra al cuarto del Inmortal.', rooms[19] )));
	Insert( new( PTroll, Init( 'Dragon', 'A usted se le erizan los pelos de la nuca de tan solo mirarlo. '+
				    'Es una criatura extremadamente hermosa y terrible a la vez.', 'Daga',
				    'Las palabras m†gicas para entrar en el cuarto del tesoro son: "Omicuos Ihanti".',
                                    _Silence )));
      end;
    with rooms[19]^ do { Inmortal }
      begin
	Insert( new( POpenLink, Init( 'Escalera', 'Lleva hasta el sal¢n de las velas.',
				       'Usted sube lentamente hasta ver el resplandor de las velas otra vez.', rooms[18] )));
	Insert( new( PThing, Init( 'Inscripci¢n', '®QuiÇn quiere vivir para siempre?', 1 )));
	Insert( new( PGuard, Init( 'Inmortal', 'No parece tener ninguna edad en espec°fico. '+
				    'Hay mucho cansancio en la expresi¢n de su rostro.',
                                    'El Inmortal lo mira agradecido y le dice antes de morir:'#13+
                                    '"No confundas la tercera muralla con la tercera barrera que tienes que romper. '+
                                    'La tercera barrera est† en t° mismo."', 'Arco' )));
      end;
    with rooms[20]^ do { Juguetes }
      begin
	Insert( new( PLinking, Init( 'Puerta blanca', 'Conduce al sal¢n de las velas.',
				      '', 'Usted sale del cuarto de juguetes.', rooms[18] )));
	Insert( new( PLinking, Init( 'Puerta de piedra', 'Es muy antigua. Probablemente sea m†s vieja que el propio '+
				      'cuarto de juguetes. ', '', 'Usted sale del cuarto de juguetes y entra a las ruinas.',
                                      rooms[21] )));
	Insert( new( PThing, Init( 'Saltador', 'Es un tronco de abeto con un resorte en el extremo inferior.', 7 )));
	Insert( new( PThing, Init( 'Sonajero', 'Es un jugete para reciÇn nacidos.', 2 )));
	Insert( new( PThing, Init( 'Talism†n de Nieve', 'Hay una peque§a tormenta de nieve encerrada en el cristal', 1 )));
      end;
    with rooms[21]^ do { Ruinas }
      begin
	Insert( new( PLinking, Init( 'Puerta de piedra', 'Est† muy a tono con el lugar. Las ruinas est†n m†s cerca de '+
				      'ser el juego del viento en las piedras que cualquier otra cosa. ', '',
                                      'Usted sale de las ruinas y regresa al cuarto de juguetes.', rooms[20] )));
	Insert( new( PLinking, Init( 'Puerta de hierro', 'Es la entrada a la casa del Ogro.', '',
				      'Usted entra a la casa del Ogro.', rooms[22] )));
	Insert( new( POpenLink, Init( 'Escalera', 'Desde el final asciende un aire fr°o y h£medo.',
				       'Los pelda§os est†n llenos de musgo. Usted desciende cuidadosamente hasta '+
                                       'llegar a los subterr†neos.', rooms[27] )));
	Insert( new( POpenLink, Init( 'Desierto', 'Promete ser largo y abrasador.', 'Usted camina duarante muchos d°as. '+
				       'El sol y el roce de la arena llagan todo su cuerpo. Por las noches, el viento helado '+
                                       'del desierto no lo deja dormir. La sed invade su cuerpo y su mente.'+#13+
                                       'Y cuando cree que nunca llegar† descubre que est† en un Oasis.', rooms[34])));
      end;
    with rooms[22]^ do { Sal¢n de Recepciones }
      begin
	Insert( new( PLinking, Init( 'Puerta de hierro', 'Usted no comprende c¢mo puede estar tan sucia. Conduce '+
				      'a las ruinas.', '', 'Usted regresa a las ruinas.', rooms[21] )));
	Insert( new( PLinking, Init( 'Puerta gris', 'Conduce al patio.', '', 'Usted sale al patio.', rooms[24] )));
	Insert( new( PThing, Init( 'Anillo de bronce', 'Es m†s pesado que los dem†s anillos.', 2 )));
      end;
    with rooms[23]^ do { Pintor }
      begin
	Insert( new( PLinking, Init( 'Puerta azul', 'Conduce al patio.', '', 'Usted sale al patio.', rooms[24] )));
	Insert( new( PThing, Init( 'Lienzo', 'Es un cuadro muy extra§o. Tiene dibujadas tres l°neas que se '+
				    'cortan entre s° en puntos distintos.', 8 )));
	Insert( new( PThing, Init( 'Grabado', 'En el grabado aparece usted cruzando un puente con el propio grabado '+
				    'en la mano. Una estructura en abismo interesante.', 2 )));
      end;
    with rooms[24]^ do { Patio interior }
      begin
	Insert( new( PLinking, Init( 'Puerta gris', 'Conduce al Sal¢n de Recepciones.', '', 'Usted sale al Sal¢n de '+
				      'Recepciones.', rooms[22] )));
	Insert( new( PLinking, Init( 'Puerta azul', 'Conduce al cuarto del pintor.', '', 'Usted entra al cuarto del '+
				      'pintor. El olor del ¢leo golpea sus narices.', rooms[23] )));
	Insert( new( PLinking, Init( 'Puerta verde', 'Conduce al cuarto del juglar.', '', 'Usted entra al cuarto del '+
				      'juglar.', rooms[25] )));
	Insert( new( PLinking, Init( 'Puerta negra', 'Conduce a la alcoba del Ogro.', '', 'Usted entra la alcoba del Ogro.',
				      rooms[26] )));
      end;
    with rooms[25]^ do { Juglar }
      begin
	Insert( new( PLinking, Init( 'Puerta verde', 'Conduce al patio.', '', 'Usted sale al patio.', rooms[24] )));
	Insert( new( PDangerLink, Init( 'Escalera', 'Conduce a las Catacumbas.', OpenDoor,
					 'Casi al llegar al final, los pelda§os se abrieron dejando abierto un precipicio '+
                                         'lleno de lava. Por suerte, el escudo de Aquiles qued¢ trabado en un saliente y '+
					 'usted pudo regresar a la superficie.', 'Escudo de Aquiles', rooms[28] )));
	Insert( new( PThing, Init( 'Cuerda', 'Esta cuerda era usada por el juglar en los actos de equilibrismo. Tiene '+
				    'un gancho atado en uno de sus extremos.', 4 )));
	Insert( new( PTroll, Init( 'Juglar', 'Usted lo observa detenidamente. Su cara es tan larga y tan triste que se '+
				    'asemeja a la de un caballo.', 'Arpa',
                                    'Lleva algo de la fragua de Vulcano al bajar a las Catacumbas.', '≠QuÇ aburrimiento!' )));
      end;
    with rooms[26]^ do { Ogro }
      begin
	Insert( new( PLinking, Init( 'Puerta negra', 'Conduce al patio.', '', 'Usted sale al patio.', rooms[24] )));
	Insert( new( PThing, Init( 'Inscripci¢n', '≠BUUUU!', 1 )));
	Insert( new( PGuard, Init( 'Ogro', 'Es una repugnante mezcla de hombre, cerdo y buitre. Parece dormido.',
				    'El Ogro despierta sobresaltado. El agua lo quema como si fuese †cido. Antes de '+
                                    'volverse un charco de pasta pestilente le grita, v°ctima de un rencor casi '+
                                    'infantil:'#13'"≠No saldr†s del lago con Marmidosa tan f†cilmente!"'#13+
                                    'El cubo de agua vuelve a llenarse.',
                                    'Cubo de agua' )));
      end;
    with rooms[27]^ do { Subterr†neo }
      begin
	Insert( new( POpenLink, Init( 'Escalera', 'Asciende hasta las ruinas.',
				       'Los pelda§os est†n llenos de musgo. Usted asciende cuidadosamente hasta '+
                                       'regresar a las ruinas.', rooms[21] )));
	Insert( new( PDangerLink, Init( 'T£nel', 'Conduce a las catacumbas. Usted huele alguna trampa.', OpenDoor,
					 'Al dar el tercer paso, usted activ¢ un mecanismo que lanz¢ un dardo envenenado '+
                                         'hacia su pecho. Usted sobrevive gracias al escudo de Aquiles.', 'Escudo de Aquiles',
                                         rooms[28] )));
	Insert( new( PThing, Init( 'Antorcha', 'Es muy brillante y despide mucho calor.', 3 )));
      end;
    with rooms[28]^ do { Catacumbas }
      begin
	Insert( new( PDangerLink, Init( 'T£nel', 'Conduce a los subterr†neos. Usted recuerda que debe llevar el Escudo '+
					 'de Aquiles.', OpenDoor, 'Al dar el tercer paso, usted activ¢ un mecanismo que '+
                                         'lanz¢ un dardo envenenado hacia su pecho. Usted sobrevive gracias al escudo de '+
                                         'Aquiles.', 'Escudo de Aquiles', rooms[27] )));
	Insert( new( PDangerLink, Init( 'Escalera', 'Conduce a una de las habitaciones de la casa del Ogro.', OpenDoor,
					 'Casi al llegar al final, los pelda§os se abrieron dejando abierto un precipicio '+
                                         'lleno de lava. Por suerte, el escudo de Aquiles qued¢ trabado en un saliente y '+
					 'usted pudo regresar a la superficie.', 'Escudo de Aquiles', rooms[25] )));
	Insert( new( POpenLink, Init( 'Pasadizo', 'Parece m†s seguro que la escalera y el t£nel.',
				       'Usted cruza esperando algo terrible, pero no sucede nada.', rooms[29] )));
	Insert( new( PThing, Init( 'Esqueleto de MurciÇlago', 'Usted se alegra de que sea solo el esqueleto. '+
				    'Mide tres metros de ala a ala.', 7 )));
      end;
    with rooms[29]^ do { Cataratas }
      begin
	Insert( new( POpenLink, Init( 'Pasadizo', 'Conduce a las Catacumbas.',
				       'Usted regresa a las Catacumbas sin mayores contratiempos.', rooms[28] )));
	Insert( new( PThing, Init( 'Anillo de plata', 'Es muy brillante.', 1 )));
	Insert( new( POpenLink, Init( 'Catarata', 'Usted siente mareos de tan solo pensar en ella.',
				       'Usted hace un acopio de valor, cierra los ojos y se lanza al abismo. Al cabo de '+
				       'varias horas, usted cae en un profundo lago.', rooms[31] )));
      end;
    with rooms[31]^ do { Lago }
      begin
	Insert( new( PDangerLink, Init( 'Grieta', 'Usted logra ver algunos destellos de una luz '+
					 'muy fuerte al otro lado.', OpenDoor,
					 'Usted cruza sin problemas, protegido con el Talism†n de Nieve.',
                                         'Talism†n de Nieve', rooms[32] )));
	Insert( new( PHidden, Init( 'Reja', 'Los barrotes de la reja son muy gruesos. Al otro lado se divisa una escalera.',
				     'Tenazas', new(POpenLink, Init( 'Escalera', 'Esta es la £nica v°a de sacar a Marmidosa '+
				     'del Lago.', 'Usted sube hasta la Catedral.', rooms[35] )))));
	Insert( new( PDangerLink2, Init( 'Sendero dorado', 'Es muy hermoso.', OpenDoor, 'Usted sale del Lago.',
					  'Marmidosa', rooms[33] )));
	Insert( new( PThing, Init( 'Inscripci¢n', 'La inscripci¢n dice:'#13+
						    '"Has llegado hasta Marmidosa, la rival de Excalibur. Hazla parte de '+
                                                    'tu mano y ella ser† parte de tu andar. T¢mala, '+
						    'est† detr†s de la grieta."', 1 )));
	Insert( new( PTroll, Init( 'Doncella del Lago', 'Es tan hermosa que usted casi se ahoga. Usted siente ganas de '+
				    'quedarse en el Lago durante el resto de su vida.', 'Talism†n de Nieve',
                                    'Las dos partes del manuscrito est†n guardadas en la Torre '+
                                    'de Cristal. Y cuando vayas en busca de la segunda parte, lleva el tri†ngulo contigo.',
                                    'La doncella le mira con cierto aire de complicidad y exclama: ≠La cueva de cristal es '+
                                    'tan hermosa! Si pudiera entrar al menos una vez...' )));
      end;
    with rooms[32]^ do { Cueva }
      begin
	Insert( new( POpenLink, Init( 'Grieta', 'Es la salida de la Cueva de Cristal.',
				       'Usted sale de la Cueva de Cristal.', rooms[31] )));
	Insert( new( PThing, Init( 'Marmidosa', 'Es algo m†s all† de la comprensi¢n humana. '+
				    'Usted se siente orgulloso de haberla encontrado antes del Hechicero, que lleva '+
                                    'siglos busc†ndola.', 5 )));
      end;
    with rooms[33]^ do { Orilla del Lago }
      begin
	Insert( new( PDangerLink2, Init( 'Sendero dorado', 'Es muy hermoso.', OpenDoor, 'Usted se sumerge en el lago.',
					  'Marmidosa', rooms[31] )));
	Insert( new( POpenLink, Init( 'Camino', 'El camino se pierde como una serpiente en la rectitud '+
				       'del horizonte.', 'Usted nota como el paisaje va cambiando a medida '+
				       'que avanza. Cada vez se va pareciendo m†s a un desierto.', rooms[36] )));
      end;
    with rooms[34]^ do { Oasis }
      begin
	Insert( new( POpenLink, Init( 'Desierto', 'Usted se estremece al recordar la £ltima vez que atraves¢ el desierto.',
				       'Usted camina duarante muchos d°as. '+
                                       'El sol y el roce de la arena llagan todo su cuerpo. Por las noches, el viento helado '+
                                       'del desierto no lo deja dormir. La sed invade su cuerpo y su mente.'+#13+
                                       'Pero al final logra regresar a las ruinas.', rooms[21] )));
	Insert( new( POpenLink, Init( 'Ruta de los camellos', 'Est† formada por miles de pisadas de camellos. ' +
				       'Seguramente conduce a alg£n lugar agradable.',
                                       'Usted avanza siguiendo las huellas que oscilan de un lado a otro y hasta '+
                                       'describen c°rculos. Todo parece indicar que los camellos estaban ebrios.'#13+
				       'Usted arriba a la Catedral.', rooms[35] )));
	Insert( new( PThing, Init( 'Cubo de agua', 'Es un balde de madera, lleno de agua hasta el tope.', 4 )));
	Insert( new( PTroll, Init( 'Pordiosero', 'Usted no sabe si es en realidad un pordiosero, o alguien que acaba de '+
				    'atravesar el desierto.', 'Bolsa', 'Si el Ogro se ba§a, se muere.',
				    'El pordiosero guarda silencio y extiende su mano pidiendo una limosna.' )));
      end;
    with rooms[35]^ do { Catedral }
      begin
	Insert( new( POpenLink, Init( 'Ruta de los camellos', 'Es la £nica v°a de regresar a las ruinas. ',
				       'Luego de varios d°as de camino; usted regresa, m†s muerto que vivo, al Oasis.',
                                       rooms[34] )));
	Insert( new( PLinking, Init( 'Puerta', 'Es la salida de la Catedral.', '', 'Usted sale de la Catedral y el viento '+
				      'seco del desierto le golpea la cara.', rooms[36] )));
	Insert( new( PThing, Init( 'Rosario', 'Es un rosario bastante com£n.', 1 )));
	Insert( new( PTroll, Init( 'Obispo', 'Es un anciano de aspecto venerable.',
				    'Silla', 'Solo con el Talism†n de Nieve podr†s entrar hasta Marmidosa.',
                                    'El Obispo lo mira y fuerza una sonrisa. Est† muy cansado para conversar y en '+
                                    'toda la Catedral no hay d¢nde sentarse.' )));
      end;
    with rooms[36]^ do { Desierto }
      begin
	Insert( new( PThing, Init( 'Inscripci¢n', 'Dice:'#13'"El Obispo le recomend¢ cierto objeto para protegerse a la '+
				    'hora de coger a Marmidosa. ≠No intente cruzar el camino en esta direcci¢n con dicho '+
                                    'objeto encima!"',1)));
	Insert( new( PDangerLink2, Init( 'Camino', 'El camino se pierde como una serpiente en la rectitud del '+
					  'horizonte. ', OpenDoor, 'Usted nota como el paisaje va cambiando a medida que '+
                                          'avanza. El desierto va perdiendo terreno y cada vez hay m†s vegetaci¢n.',
					  'Talism†n de Nieve', rooms[33])));
	Insert( new( PLinking, Init( 'Puerta', 'Es la puerta de salida de la Catedral.', '', 'Usted entra a la Catedral',
				      rooms[35] )));
	Insert( new( PHidden, Init( 'Muralla', 'Es algo m†s peque§a que la muralla anterior.',
				     'Piedra verde', new( POpenLink, Init( 'Avenida de las flores',
                                     'Toda la avenida est† sembrada de flores carn°voras.', 'Usted se ve obligado a echarse '+
                                     'a correr para escapar de los constantes mordiscos.', rooms[37] )))));
	Insert( new( PThing, Init( 'Escudo de Aquiles', 'Usted nunca hab°a visto algo tan hermoso.'+#13+
				    'Este escudo formaba parte de la nueva armadura que Hefestos le hizo a Aquiles '+
				    'cuando la anterior cay¢ en manos de los troyanos al morir Patroclo.', 10 )));
      end;
    with rooms[37]^ do { Valle }
      begin
	Insert( new( POpenLink, Init( 'Avenida de las flores',
                                       'Toda la avenida est† sembrada de flores carn°voras.', 'Usted regresa corriendo '+
                                       'al desierto.', rooms[36] )));
	Insert( new( POpenLink, Init( 'Monta§as', 'Las monta§as rodean todo el sur del Valle. Parece el espinazo de un '+
				       'drag¢n gigantesco.',
                                       'Luego de varios d°as de camino usted llega al punto m†s alto de la cordillera.',
                                       rooms[38] )));
	Insert( new( PTroll, Init( 'Camello', 'Est† muy viejo y maltratado. Tiene las pezu§as llenas de arena.',
				    'Botella de vino', 'Las dos £ltimas letras del segundo nombre de la Hija del '+
                                    'Hechicero son "KA".', '≠Dame m†s!' )));
	Insert( new( PThing, Init( 'Bolsa de semillas', 'La bolsa est† llena de semillas de los †rboles que crecen '+
				    'en el valle.', 2 )));
      end;
    with rooms[38]^ do { Pico Negro }
      begin
	Insert( new( POpenLink, Init( 'Monta§as', 'Desde este lugar, las monta§as lucen como grades piedras envueltas'+
				       'en nubes.', 'Luego de varios d°as de camino usted regresa al valle.', rooms[37] )));
	Insert( new( PDangerLink, Init( 'Precipicio', 'Usted se inclina en el borde del precipicio, pero no '+
					 'consigue ver el fondo.', OpenDoor,
                                         'Usted logra sobreponerse al temblor de sus manos, se aferra al saltador '+
                                         'y se lanza al vac°o. Al tercer d°a de ca°da, el muelle del saltador rebota '+
                                         'suavemente en el suelo.', 'Saltador', rooms[40] )));
	Insert( new( POpenLink, Init( 'Ladera', 'La ladera desciende suavemente hasta un campo sembrado.',
				       'Usted desciende cuidadosamente hasta las tierras del Labrador.',
                                       rooms[42] )));
	Insert( new( PLinking, Init( 'Puerta de Madera', 'Es la entrada a la choza del Monje.', '',
				      'Usted entra a la choza del Monje.', rooms[39] )));
      end;
    with rooms[39]^ do { Monje }
      begin
	Insert( new( PLinking, Init( 'Puerta de Madera', 'Conduce a la cima del Pico Negro.', '',
				      'Usted sale de la choza del Monje.', rooms[38] )));
	Insert( new( PTroll, Init( 'Monje', 'Parece ser bastante joven.',
				    'Rosario', 'Para descender por el precipicio debes llevar '+
                                    'algo que amortigÅe el golpe al final.', 'El monje no le responde. Est† muy ocupado '+
                                    'recogiendo las cuentas del suelo.' )));
      end;
    with rooms[40]^ do { Ciudad }
      begin
	Insert( new( PThing, Init( 'Inscripci¢n', 'Dice:'#13'"Aqu° habitaron los horantes durante mucho tiempo, hasta que '+
				    'La Bestia ocup¢ el lugar. Ellos levantaron cada pared de la Fortaleza, solo ellos saben '+
				    'c¢mo salir."', 1 )));
	Insert( new( POpenLink, Init( 'T£nel', 'Conduce a las ruinas.', 'Usted camina hasta regresar a las ruinas.',
				       rooms[21] )));
	Insert( new( POpenLink, Init( 'Escalera', 'Usted se pregunta a d¢nde conducir†.', 'Usted sube hasta regresar '+
				       'al Valle.', rooms[37] )));
	Insert( new( PLinking, Init( 'Puerta de Hierro', 'Es la entrada de la casa del sabio.', '',
				      'Usted ha entrado a la casa del sabio.', rooms[41] )));
	Insert( new( PHidden, Init( 'Estatua de Cristal', 'Usted no logra descubrir quÇ representa.',
				     'Corta-Cristales', new( PTroll, Init( 'Horante', 'Es el £ltimo de los horantes.',
                                     'Mu§eco diab¢lico', 'Busca las dos mitades del Manuscrito de los Horantes y desc°fralo. '+
                                     'Luego coloca las marcas para abrir la Fortaleza.', 'El horante trata de articular algo'+
                                     ', pero un terrible dolor en su pierna derecha no lo deja.' )))));
      end;
    with rooms[41]^ do { Sabio }
      begin
	Insert( new( PLinking, Init( 'Puerta de Hierro', 'Conduce a la Ciudad Abandonada.', '',
				      'Usted regresa a la Ciudad Abandonada.', rooms[40] )));
	Insert( new( PTroll, Init( 'Sabio', 'Es sabio es un hombre peque§o. Lleva unos espejuelos que cubren casi todo su '+
				    'rostro', 'Esqueleto de MurciÇlago', 'De todas las cosas sobre la tierra, la que m†s me '+
                                    'fascina es la cinta de Moebius. Empiezas a recorrerla por adentro y cuando vienes a '+
                                    'ver... ≠est†s afuera!', 'El sabio est† muy distra°do haciendo un anillo de papel algo '+
                                    'torcido. ')));
	Insert( new( PThing, Init( 'Cinta de Moebius', 'Es una cinta de papel con una torcedura y ambos '+
				    'extremos pegados.', 1 )));
	Insert( new( PThing, Init( 'PÇndulo', 'El pÇndulo oscila levemente, colgado de un punto invisible del espacio.',3)));
      end;
    with rooms[42]^ do { Campo }
      begin
	Insert( new( POpenLink, Init( 'Ladera', 'Es por d¢nde £nico se puede subir al Pico Negro de este lado de la '+
				       'cordillera.', 'Usted asciende el Pico Negro.', rooms[38] )));
	Insert( new( PDangerLink, Init( 'R°o', 'La corriente es tan fuerte que arrastrar°a hasta la embarcaci¢n '+
					 'm†s pesada.', OpenDoor,
                                         'Usted lanza la soga con el garfio hasta la otra orilla y forma una especie '+
                                         'de cuerda floja. Luego cruza el r°o haciendo una impresionante demostraci¢n de '+
                                         'equilibrio.', 'Cuerda', rooms[43] )));
	Insert( new( PThing, Init( 'Tenazas', 'Parecen ser muy fuertes.', 2 )));
	Insert( new( PTroll, Init( 'Labrador', 'Es un hobre robusto y muy maltratado por el trabajo en el campo.',
				    'Bolsa de semillas', 'El Labrador lo mira y le dice:'#13+
                                    '"No siempre las cosas son lo que parecen. La realidad tiene muchas caras y nunca '+
                                    'sabemos si estamos mirando la verdadera. MantÇn tu mente abierta".',
                                    '≠QuÇ cansancio! Creo que es demasiada tierra para una sola persona.')));
      end;
    with rooms[43]^ do { Torre abajo }
      begin
	Insert( new( PDangerLink, Init( 'R°o', 'La corriente es tan fuerte que arrastrar°a hasta la embarcaci¢n '+
					 'm†s pesada.', OpenDoor,
                                         'Usted lanza la soga con el garfio hasta la otra orilla y forma una especie '+
                                         'de cuerda floja. Luego cruza el r°o haciendo una impresionante demostraci¢n de '+
                                         'equilibrio.', 'Cuerda', rooms[42] )));
	Insert( new( PHidden, Init( 'Ebano', 'Es muy alto.', 'NADA', nil )));
	Insert( new( PLinking, Init( 'Puerta de Hierro', 'Es la entrada a los calabozos.', '',
				      'Usted entra a los calabozos.', rooms[47] )));
	Insert( new( POpenLink, Init( 'Escalera de Caracol', 'Sube hasta el tope de la la Torre de Cristal.',
				       'Usted asciende durante varias horas.', rooms[44] )));
      end;
    with rooms[44]^ do { Torre arriba }
      begin
	Insert( new( POpenLink, Init( 'Escalera de Caracol', 'Conduce a la parte inferior de la Torre de Cristal.',
				       'Usted regresa a la orilla del r°o.', rooms[43] )));
	Insert( new( PHidden, Init( 'Esfera', 'Tiene aproximadamente tres metros de di†metro y parece ser de carne. Es '+
				     'algo realmente ins¢lito.', 'Marmidosa', new( PThing, Init( 'Tablilla de Madera',
                                     'Tiene las siguientes palabras grabadas:'#13#13+
                                     ' "A acsd o oatssn'#13+
                                     '  Oadaat lfnodllg'#13+
                                     '  Oed aot nl rlaousa'#13+
                                     '  Nocae lcat ehÇpds'#13+
                                     '  Lail lgd ut lÇao'#13+
                                     '  Suod qie nl iddd o oats'#13+
                                     '  Seod ahj e ehcr ns uro'#13+
				     '  Edl ne a¢ efmr"', 2 )))));
	Insert( new( PRiddleLink, Init( 'Puerta de Cristal', 'Es de un cristal muy grueso y opaco.',
		     '®Cu†l es el nombre completo de la hija del Hechicero?', 'Aura Srka',
                     'Usted entra a la alcoba.', rooms[45] )));
      end;
    with rooms[45]^ do { Alcoba de Aura }
      begin
	Insert( new( PLinking, Init( 'Puerta de Cristal', 'Es la salida de la alcoba.', '',
				      'Usted sale de la alcoba.', rooms[44] )));
	Insert( new( PHidden, Init( 'Carta', 'La carta dice:'#13+
				     '"Mi querido salvador:'#13+
                                     '®Por quÇ has demorado tanto? Hace mucho que mi padre me llev¢ '+
                                     'al Abismo Infranqueable. Ahora no podrÇ marcharme contigo. La £nico que puedes hacer '+
				     'para salir es matarlo con Marmidosa. Por favor, trata de que no sufra."', '',
				     new( PDangerLink, Init( 'Puerta Secreta', 'Es muy negra y tiene una tela de ara§a '+
				     'dibujada. Est† abierta.', OpenDoor, 'Usted atraviesa la puerta lentamente. '+
				     'Los pelos de la nuca se le erizan sin poder evitarlo.', 'Lienzo', rooms[46] )))));
	Insert( new( PThing, Init( 'Espejo', 'Est† roto.', 1 )));
      end;
    with rooms[46]^ do { Alcoba escondida }
      begin
	Insert( new( PLinking, Init( 'Puerta Secreta', 'Conduce a la alcoba.', OpenDoor,
				      'Usted regresa a la alcoba.', rooms[45] )));
	Insert( new( PDaugther, Init( 'Hija del Hechicero', 'Usted est† a punto de desmayarse. La hija del Hechicero no es '+
				       'exactamente como usted esperaba. En realidad se parece m†s a una serpiente de quince '+
                                       'metros y tres cabezas, con la piel llena de gruesas escamas.',
                                       'Usted clava fuertemente la aguja entre las escamas. '+
                                       'Las cabezas le miran llenas de ira y hay una que exclama: '+
                                       '"≠Mata a todos los que te mintieron si quieres salir!"',
                                       'Aguja' )));
      end;
    with rooms[47]^ do { Calabozos }
      begin
	Insert( new( PLinking, Init( 'Puerta de Hierro', 'Es la salida de los calabozos. Conduce a la orilla del r°o.', '',
				      'Usted regresa al r°o.', rooms[43] )));
	Insert( new( PLinking, Init( 'Reja', 'Conduce a la celda. Los barrotes son tan gruesos que la reja es '+
				      'pr†cticamente una puerta maciza.', 'Grifo', 'Usted estornuda. Ha entrado a la celda.',
				      rooms[48] )));
	Insert( new( PLinking, Init( 'Puerta Gris', 'Conduce a la sala de La Prueba.', '',
				      'Usted entra a la sala de La Prueba.', rooms[49] )));
	Insert( new( PGuard, Init( 'Carcelero', 'Parece un hombre rudo y cumplidor de sus deberes.',
				    'ARRRGG!!! ≠Te ser† muy dif°cil abrir la celda, porque la palabra m†gica '+
                                    'es el nombre de la primera criatura que viste al salir del cuarto de huÇspedes! '#13+
                                    'Usted sonr°e porque sabe que el problema es f†cil.',
                                    'Marmidosa' )));
      end;
    with rooms[48]^ do { Celda }
      begin
	Insert( new( PLinking, Init( 'Reja', 'Es la salida de la celda.', 'Grifo', 'Usted sale de la celda.',
				      rooms[47] )));
	Insert( new( PTroll, Init( 'Encapuchado', 'Es una criatura realmente asombrosa. Toda su anatom°a parece '+
				    'regida por el n£mero siete. Siete brazos, siete pies, siete dedos en cada una de las '+
                                    'siete manos.',
				    'Receta', 'El nombre de la hija del Hechicero tiene ocho letras, una est† repetida '+
                                    'tres veces y otra dos.',
                                    'Pareces haber estado viajando. Seguramente has visto algo que me pertenece por ah°... '+
                                    '®podr°as traÇrmelo?' )));
      end;
    with rooms[49]^ do { Sal¢n }
      begin
	Insert( new( PLinking, Init( 'Puerta Gris', 'Conduce a los calabozos.', '', 'Usted entra a los calabozos.',
				      rooms[47] )));
	Insert( new( PThing, Init( 'Inscripci¢n', 'Dice:'#13'"En este punto comienza la prueba de los anillos. Contin£a '+
				    'con el que hayas elegido y deja los dem†s."', 1 )));
	Insert( new( PThing, Init( 'Arco', 'Con este arco mataron a Hycrk, uno de los doce inmortales.', 5 )));
	Insert( new( PDangerLink, Init( 'T£nel', 'Parece ser muy largo. Usted no se atrever°a a cruzarlo sin el arco.',
					 OpenDoor,
                                         'Casi a mitad de camino usted es atacado por una bandada de murciÇlagos gigantes. '+
					 'Gracias al arco, usted logra ahuyentarlos.', 'Arco', rooms[14] )));
	Insert( new( PDangerLink2, Init( 'Puerta Verde', 'Es la primera puerta de la prueba. ',
					  OpenDoor, 'Usted cierra los ojos y cruza la puerta. Dejar el anillo de oro '+
					  'fue una idea excelente.', 'Anillo de oro', rooms[50])));
      end;
    with rooms[50]^ do { Sal¢n Verde }
      begin
	Insert( new( PDangerLink2, Init( 'Puerta Verde', 'Conduce al primer sal¢n.', OpenDoor,
		     'Usted atraviesa la puerta sin dificultades.', 'Anillo de oro', rooms[49])));
	Insert( new( PDangerLink2, Init( 'Puerta Azul', 'Es la segunda puerta de la prueba.',
					  OpenDoor, 'Usted piensa durante unos segundos antes de avanzar. Hizo bien en '+
					  'dejar el anillo de plata.', 'Anillo de plata', rooms[51])));
      end;
    with rooms[51]^ do { Sal¢n Azul }
      begin
	Insert( new( PDangerLink2, Init( 'Puerta Azul', 'Conduce al sal¢n verde.', OpenDoor,
		     'Usted atraviesa la puerta sin dificultades.', 'Anillo de plata', rooms[50])));
	Insert( new( PDangerLink2, Init( 'Puerta Blanca', 'Es la tercera puerta de la prueba.',
					  OpenDoor, 'Usted levanta los ojos buscando valor y da los primeros pasos. '+
					  'Usted se alegra de no haber tra°do el anillo de bronce.', 'Anillo de bronce',
                                          rooms[52])));
      end;
    with rooms[52]^ do { Sal¢n Blanco }
      begin
	Insert( new( PDangerLink2, Init( 'Puerta Blanca', 'Conduce al sal¢n azul.', OpenDoor,
		     'Usted atraviesa la puerta sin dificultades.', 'Anillo de bronce', rooms[51])));
	Insert( new( PDangerLink, Init( 'Puerta triangular', 'Es la £ltima puerta de la prueba.',
					 OpenDoor, 'Esta vez usted no se detiene a pensarlo y avanza decididamente. Todo '+
                                         'parece indicar que eligi¢ el anillo correcto: la cinta de Moebius.',
                                         'Cinta de Moebius', rooms[53])));
      end;
    with rooms[53]^ do { Muralla }
      begin
	Insert( new( PDangerLink, Init( 'Puerta triangular', 'Conduce al sal¢n blanco.', OpenDoor,
					 'Usted atraviesa la puerta sin dificultades y regresa al sal¢n blanco.',
                                         'Cinta de Moebius', rooms[52])));
	Insert( new( PDangerLink, Init( 'Puente', 'Est† hecho de madera y soga. Bajo Çl se abre, infinito, el '+
					 'Abismo Infranqueable. Del otro lado se divisa una pir†mide.', OpenDoor,
					 'Usted logra cruzar el puente gracias a la protecci¢n del grabado.', 'Grabado',
                                         rooms[54])));
	Insert( new( PHidden, Init( 'Muralla', 'Es la tercera muralla con que usted tropieza en su camino. '+
				     'algo le dice que tambiÇn es la £ltima.', 'NADA', nil )));
	Insert( new( PTroll, Init( 'Guardi†n', 'Est† muy viejo para vigilar algo. Probablemente alguien lo haya '+
				    'olvidado en este lugar. Est† muy quemado por el sol.', 'Sombrero',
                                    'El anciano le cuenta una historia incoherente sobre un hÇroe que derrota a una '+
                                    'serpiente gigante armado de una aguja.', '≠QuÇ calor!' )));
      end;
    with rooms[54]^ do { Pir†mide }
      begin
	Insert( new( PDangerLink, Init( 'Puente', 'De este lado se puede apreciar mejor lo fr†gil que es el puente y '+
					 'lo infinito que es el Abismo.', OpenDoor,
					 'Usted logra cruzar el puente gracias a la protecci¢n del grabado.', 'Grabado',
                                         rooms[53])));
	Insert( new( PHidden, Init( 'Columna de Hielo', 'Es una ancha estructura de hielo pegada a la pared.',
				     'Antorcha', new( PRiddleLink, Init( 'Puerta de Roble', 'Usted presiente que el '+
				     'Hechicero se encuentra detr†s de esa puerta.', '®QuiÇn invirti¢ el reloj de Caronte?',
                                     'Yo', 'Usted entra a las habitaciones del Hechicero.', rooms[55] )))));
      end;
    with rooms[55]^ do { Habitaciones }
      begin
	Insert( new( PLinking, Init( 'Puerta de Roble', 'Es de un roble tan s¢lido que mellar°a cualquier acero.',
				      '', 'Usted sale de las habitaciones del Hechicero.', rooms[54] )));
	Insert( new( PTroll, Init( 'Hechicero', 'Es un hombre inmenso, de barba blanca. Viste una t£nica negra y sostiene '+
				    'una vara con una caravela en su mano.', 'Marmidosa',
                                    'El Hechicero le sonr°e y le dice: '#13'"No soy tu enemigo. Es mi hija quien ha '+
                                    'elaborado este diab¢lico plan para eliminarnos. Rompe la carta que te dej¢ en la '+
                                    'Torre de Cristal y ocurrir† un milagro."', _Silence )));
      end;
  end;

procedure SuccessSound;
  var
    i : word;
  begin
    i := 10;
    repeat
      sound( i );
      delay( 2 );
      nosound;
      delay( 2 );
      inc( i, 10 );
    until i = 400;
    for i := 1 to 100 do
      begin
        sound( random( 500 ) );
        delay( 4 );
        nosound;
        delay( 3 );
      end;
    for i := 1 to 200 do
      begin
        sound( round(1000*abs(sin(i/50)) - random(500)) );
        delay( 4 );
        nosound;
        delay( 2 );
      end;
    for i := 1 to 300 do
      begin
        sound( random( 1000 ) );
        delay( 4 );
        nosound;
        delay( 3 );
      end;
    i := 100;
    repeat
      sound( i );
      delay( 2 );
      nosound;
      delay( 2 );
      inc( i, 100 );
    until i = 4000;
  end;

procedure DefeatSound;
  var
    i : word;
  begin
{    for i := 1 to 50 do
      begin
        sound( random( 400 ) );
        delay( 10 );
        nosound;
        delay( 5 );
      end;
}    for i := 400 downto 10 do
      begin
        sound( i );
        delay( 3 );
        nosound;
        delay( 1 );
      end
  end;

var
  rooms       : RoomsAr;
  i	      : byte;
  f	      : PFort;
  h	      : word;
  m	      : word;
  hh	      : word;
  mm	      : word;
  x	      : word;
  R	      : TRect;
  OldExitProc : pointer;

procedure MyExitProc; far;
  begin
    ExitProc := OldExitProc;
    dispose( f, done );
    dispose( Tele, done);
    dispose( manX, done);
  end;

begin
  if memavail < 90000
    then halt( 2 );

  OldExitProc := ExitProc;
  ExitProc := @MyExitProc;

  GetTime( hh, mm, x, x );

  for i := 1 to NRooms do
    rooms[i] := new( PRoom, Init( RoomAr[i].name, RoomAr[i].desc, succ(LWeight) ));

  R.Assign( 2, 2, 79, 24 );
  Tele := GetTTY( R );
  PHistTTY(Tele)^.SetHistory( PHistColl(f^.track) );

  ManX := new( PMan , Init( 'Indy', 'Sad' ));
  f    := new( PFort, Init( ManX, voc ));
  SetSpeed( 0 );

  if TrkName = ''
    then
      begin
	Presentation;
	i := Menu( 32, 12 );
	while i <> 1 do
          begin
	    case i of
	      2: Instructions;
	      3: Advices;
	      4: halt(0);
	    end;
	    i := Menu( 32, 10 );
          end;
      end;

  window( 1, 1, 80, 25 );
  textbackground( 0 );
  clrscr;

  Tele^.StartTransmition;
  Tele^.Sendln( 'Inicializando la fortaleza...' );
  Tele^.SetState( stThinking );
  for i := 1 to NRooms do
    f^.insert( rooms[i] );
  SetData( rooms );
  f^.Start;

  Tele^.Clear;
  Tele^.NewPaper;

  if TrkName <> ''
    then f^.ExecTrack( TrkName );
  VerboseExec := true;
  f^.Output( '' );

  if hh < 12
    then f^.Output( 'Buenos d°as.' )
    else
      if hh > 18
        then f^.Output( 'Buenas noches.' )
        else f^.Output( 'Buenas tardes.' );

  NormalCursor;
  while not((f^.Goal) or (f^.IsOver)) do
    begin
      f^.AskMan;
      f^.ClearWish;
      f^.MakeManWish;
    end;

  if f^.Goal
    then
      begin
        f^.Output( 'De repente las paredes comienzan a desvanecerse.'#13'Usted no quiere dar crÇdito a sus ojos: '#13+
                   '≠Ha logrado salir de la Fortaleza!' );
        SuccessSound;
        Tele^.Clear;
        Tele^.NewPaper;
        f^.Output( '                               EPILOGO' );
        f^.Output( '' );
        f^.Output( 'Usted mira al cielo agradecido y besa la tierra.' );
        f^.Output( 'DespuÇs de que la emoci¢n del primer momento hubo pasado usted se sienta sobre una '+
                   'piedra al borde de la carretera (recuerde que ha regresado a la civilizaci¢n) '+
                   'y comienza a pensar. "®Para quÇ sal°?", se pregunta, "si el exterior nunca me gust¢ tanto".' );
        f^.Output( 'Usted recuerda a la Doncella del Lago, y piensa en la vida que hubiera podido llevar junto a ella.' );
        f^.Output( 'Piensa tambiÇn en el Hechicero, un poderoso amigo, y en la remota y hermosa posibilidad de hacer '+
                   'renacer la civilizaci¢n de los horantes. Ahora, sin la Bestia y sin la Hija del Hechicero, la '+
                   'Fortaleza podr°a ser convertida en un verdadero para°so.' );
        f^.Output( '' );
        f^.Output( '®QuiÇn est† al otro extremo de los hilos que manejan al hombre?' );
        f^.Output( '®QuiÇn nos hace confundir lo que somos y lo que queremos ser?' );
        f^.Output( '®QuiÇn es el responsable de nuestros errores?' );
        f^.Output( '®QuiÇn sino nosotros mismos?' );
        f^.Output( '' );
        Tele^.SetState( stWaiting );
        readkey;
        Tele^.Clear;
        Tele^.NewPaper;
        f^.Output( 'Usted vuelve la cabeza hacia el lugar que ocup¢ la Fortaleza. Ahora lo comprende todo claramente, '+
                   'esta era la venganza de la Bestia: dejarlo vivir, pero fuera de la Fortaleza.' );
        f^.Output( '' );
        f^.Output( '®Quer°a un final feliz? Espere la pr¢xima versi¢n.' );
        f^.Output( '' );
        f^.Output( '' );
        f^.Output( '' );
        f^.Output( '                                                       M. Cepero' );
        f^.Output( '' );
        f^.Output( '' );
      end
    else
      begin
        DefeatSound;
        f^.Output( 'Su entierro se efectuar† el pr¢ximo domingo a las 3:00 am. Est† invitado.' );
      end;

  f^.Output( '' );
  f^.Output( '®Desea salvar su rastro (S/N)?' );
  if upcase(readkey) = 'S'
    then
      begin
	if TrkName = ''
	  then TrkName := _TrackF;
	f^.Output( 'Salvando rastro hacia ' + TrkName );
	f^.SaveTrack( TrkName );
      end;

end.