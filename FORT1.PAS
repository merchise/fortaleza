program Fort1;

uses
  Util,
  Crt, Dos, Win, Objects, Vocabl, Castles, 
  CmdLine, Advic, Letters, Teletype, HistTTY, TTY, Present1, Instr1;

const
  NRooms  = 33;
  LRooms  = 19;
  CmmLN   = 20;
  _VictAt = 10;
  _TrackF = 'TRAVEL.TRK';

type
  HelpArr  = array[ 1..25 ] of string;
  RoomsAr  = array[ 1..50 ] of PRoom;
  RoomData = record
	       name : string[80];
               desc : string;
             end;

  PFort    = ^Fort;
  Fort     = object( Castle )
               function Goal : boolean; virtual;
             end;

function Fort.Goal : boolean;
  begin
    Goal := (PRoom( At(21) )^.Get( 'Centro del cerebro' ) = nil) and
            (PRoom( At(20) )^.Get( 'Centro del corazon' ) = nil) and
            (PRoom( At(19) )^.Get( 'Centro del estomago' ) = nil) and
            (PRoom( At(18) )^.Get( 'Centro de los pulmones' ) = nil) and
            (PRoom( At(11) )^.Get( 'Troll' ) = nil)
  end;

function DecodeLine( s : string ) : string;
  var
    i : byte;
  begin
    for i := 1 to length(s) do
      byte(s[i]) := byte(s[i]) - 20;
    DecodeLine := s;
  end;

  const
    key : array[ 1..47 ] of string[45+128] = (
'\u4‰‚4‚ƒv†y4…‰y4Šu‡4u4‚ywy‡}ˆu†4‰w|ƒN4f‰„y€‡ˆ}‚‡}‚B',
'Uv†yˆy4gy‡uƒ',
'U†}yˆy',
'auu',
'V‰‡wu4u4€u4xƒ‚wy€€u4u€4€uxƒ4xy€4y‡„y~ƒ4…‰y4†ƒ„y†´‡4wƒ‚4‰‚4|‰y‡ƒB4Y€€u4ˆy4x}†´4x¶‚xy4y‡ˆ´4y€4z}‚u€4xy4€u4Vy‡ˆ}uB',
'h†y}‚ˆu44‚‰yŠy',
'`u‚u',
'du†u4€€y{u†4u4€ƒ‡4„‰€ƒ‚y‡4xy4€u4Vy‡ˆ}u4xyvy‡4ˆy‚y†4y€4ˆu€}‡u‚4xy4u}†yB',
'du†u{‰u‡',
'Y‚4€u4v}v€}ƒˆywu4|u4‰‚4€}v†ƒ4…‰y4wƒ‚x‰wy4u€4~u†xµ‚B',
'\‰y‡ƒ4xy4{uˆƒ',
'4d‰yxy‡4„u‡u†@4€u4wƒ‚ˆ†u‡y¸u4y‡46bƒv‰‡4fƒ‡ˆƒy€u†}‡6',
'auu',
'bƒv‰‡4fƒ‡ˆƒy€u†}‡',
'`‰',
'i‡ˆyx4wuy4x‰†u‚ˆy4Šu†}ƒ‡4}‚‰ˆƒ‡4@4{†uw}u‡4u€4wu‚xy€uv†ƒ@4w‰u‚xƒ4ˆƒwu4y€4‡‰y€ƒ4‚ƒ4‡y4|uwy4xu¸ƒB4cy4‰‚u4Šƒ4…‰y4x}wyN46gyu4'+
'{y‚ˆ}€4wƒ‚4€u4xƒ‚wy€€u@4†y{´€y€y4‰‚u4z€ƒ†B6',
'Y‡w‰w|u4v}y‚@4|}~ƒB4W‰u‚xƒ4ˆy4x}{u‚46d†ƒ|}v}xƒ6@4}‚Šƒwu4€u4€‰B4fyw‰y†xu4…‰y4€u4„u€uv†u4w†yu4u4‡‰4‡}{‚}z}wuxƒB',
'\uw|u',
'dƒw}ƒ‚4„u†u4w†ywy†',
'du†u4uˆ†uŠyu†4„ƒ†4y€4y‡wu„u†uˆy4xy4€u4v†‰~u@4xyvy‡4€€yŠu†4‰‚4wu‚xy€uv†ƒB4m4u€4|uwy†€ƒ4Šu‡4u4wƒ‚ƒwy†4u€{ƒ4}„ƒ†ˆu‚ˆyB',
'dƒ€Šƒ4u{}wƒ',
'Y€4wƒ†u¶‚4xy4‰‚}wƒ†‚}ƒ4ˆy4„†ƒˆy{y†´4y‚4y€4wƒ†u¶‚4xy4€u4Vy‡ˆ}uB',
'f‰„y€‡ˆ}‚‡}‚',
'fƒ‡u',
'`u4·€ˆ}u4|uv}ˆuw}¶‚4y‡ˆ´4u€4„†}‚w}„}ƒB',
']‚‰‡4|‰}‡w‰ƒ€4†u‡ˆƒ}‡€u}‡554Wƒ‚4y‡ˆu4y‡u„uxu4uˆu†´‡4u4€ƒ‡4„‰€ƒ‚y‡4xy4€u4Vy‡ˆ}uB',
'Y‡„uxu',
'huu4xy4wuzy',
'U€4y‚ˆ†u†4u€4y‡ˆ¶u{ƒ@4€€yŠu4wƒ‚ˆ}{ƒ4‰‚4„u‡ˆy€B',
'hu€}‡u‚4xy4u}†y',
'du‡ˆy€4xy4wy†yu‡',
'Y‡„uxu',
'`uˆ}{ƒ',
'Xu{u',
'i‡ˆyx4|u4xy‡ˆ†‰}xƒ4€ƒ‡4„‰€ƒ‚y‡54gƒ€ƒ4wƒ‚4‰‚4€´ˆ}{ƒ4„ƒx†´‡4xy‡ˆ†‰}†4y€4y‡ˆ¶u{ƒB',
'i‡ˆyx4|u4xy‡ˆ†‰}xƒ4y€4y‡ˆ¶u{ƒ54gƒ€ƒ4wƒ‚4‰‚u4xu{u4„ƒx†´‡4xy‡ˆ†‰}†4y€4wƒ†u¶‚B',
'i‡ˆyx4|u4xy‡ˆ†‰}xƒ4y€4wƒ†u¶‚54V‰‡wu4y€4wy†yv†ƒ4xy4€u4vy‡ˆ}u4€y~ƒ‡4xy4u…‰µB4gƒ€ƒ4y€4z‰y{ƒ4„‰yxy4xy‡ˆ†‰}†€ƒB',
'U‚ˆƒ†w|u',
'¼auˆu‡ˆy4u€4h†ƒ€€S',
'd}yx†u4z}€ƒ‡ƒzu€',
'W‰}xuxƒ4wƒ‚4y€4ˆ·‚y€44€u4„‰y†ˆu4xy4ˆy€uB4gƒ€ƒ4wƒ‚x‰wy‚4u4€u4‰y†ˆyB',
'U{‰u',
'‚uxu',
'UUUffff[[[[55554`u4„u€uv†u4´{}wu4y‡46U{‰u6B',
'U†wƒ',
'au…‰}‚u4xy€4ˆ}y„ƒ',
'gƒ€ƒ4wƒ‚4‰‚u4xu{u4„ƒx†´‡4uˆu†4y€4wƒ†u¶‚B' );


    RoomAr : array[ 1..NRooms ] of RoomData =
     (( name: 'el exterior de la fortaleza';
	desc: 'Las paredes son muy negras y al parecer, no tienen ventanas. Usted trata de ver el final de las torres, pero '+
	      'las nubes no se lo permiten.' ),
      ( name: 'el Sal¢n de recepciones';
	desc: 'Parece hecho para criaturas cientos de veces m s grandes que los humanos. Est  desierto, pero usted '+
	      'siente que es observado.' ),
      ( name: 'la Sala de juegos';
	desc: 'Usted trata de imagainar c¢mo eran los juegos del sal¢n. Hay doce mesas y cada una tiene doce erizos.' ),
      ( name: 'el Patio interior';
	desc: 'El patio tiene forma de caracol. Cada uno o dos pasos se levanta una columna de m rmol negro y se confunde '+
	      'en la altura con los  rboles. Usted siente el crujido de las hojas secas bajo sus zapatos.' ),
      ( name: 'el Cuarto de espejos';
	desc: 'Hay tantos espejos que no puede reconocer si usted es real o es una imagen de s¡ mismo.' ),
      ( name: 'la Biblioteca';
	desc: 'Hay miles de libros en este lugar. Todos tienen alguna hoja marcada con una servilleta.' ),
      ( name: 'Pasillo';
	desc: 'Tiene tres puertas al lado y una al final.' ),
      ( name: 'la Alcoba de la bruja';
	desc: 'Hasta un ciego descubrir¡a que aqu¡ habita una bruja. '+
	      'El cuarto tiene una ventana, pero usted no recuerda haberla visto desde afuera.' ),
      ( name: 'el Cuarto del guerrero';
	desc: 'El cuarto est  muy ordenado. A usted le sorprende que no hayan armas.' ),
      ( name: 'el Laboratorio de la Bestia';
	desc: 'Hay muchos frascos. A usted le llaman la atenci¢n los £ltimos: est n llenos de hom£nculos.' ),
      ( name: 'la Sala de armas';
	desc: 'Este lugar parece salido del sue¤o de un guerrero.' ),
      ( name: 'los Ba¤os de la Bestia';
	desc: 'El ba¤o es tan grande que usted no puede ver las paredes que lo limitan' ),
      ( name: 'el Jard¡n';
	desc: 'Se podr¡an construir varias ciudades en su interior.' ),
      ( name: 'la Alcoba de la doncella';
	desc: 'Es una habitaci¢n muy peque¤a y h£meda.' ),
      ( name: 'la Sala de infusiones';
	desc: 'Hay varias mesas regadas por el suelo. Usted tiene la impresi¢n de que ning£n humano ha '+
	      'estado en ese lugar anteriormente.' ),
      ( name: 'los Calabozos';
	desc: 'Son tan h£medos que usted no resistir¡a ni unas horas detro de ellos.' ),
      ( name: 'Boca de la Bestia';
	desc: 'Es como una boca humana, pero del tama¤o de una casa.' ),
      ( name: 'Interior de la Bestia';
	desc: 'Usted puede sentir los latidos del coraz¢n de la Bestia, al igual que su respiraci¢n '+
	      'o el ruido de los l¡quidos revueltos en su est¢mago.' ),
      ( name: 'Pulmones de la Bestia';
	desc: 'Sopla un aire tan fuerte que usted se ha tirado al suelo.' ),
      ( name: 'el Est¢mago de la Bestia';
	desc: 'Hay varios esqueletos humanos.' ),
      ( name: 'el Coraz¢n de la Bestia';
	desc: 'Todo palpita r¡tmicamente. Usted siente c¢mo los latidos se adue¤an del lugar, '+
	      'especialmente de su propio coraz¢n.' ),
      ( name: 'el Cerebro de la Bestia';
	desc: 'Es como un tarjetero gigante. Cada idea est  escrita en una tarjeta y, cuando es '+
	      'necesario, la tarjeta es sacada por una mano invisible y le¡da al resto de la Bestia.' ),
      ( name: 'los Almacenes de la Fortaleza';
	desc: 'Est n llenos de carne humana. Usted aparta el cad ver de una mujer para poder observar bien el lugar.' ),
      ( name: 'un extenso p ramo';
	desc: 'Hay muy poca vegetaci¢n y el suelo es pantanoso. Usted nunca imagin¢ que el interior de la fortaleza '+
	      'fuera tan grande.' ),
      ( name: 'Sal¢n de cristal';
	desc: 'Es como un caleidoscopio gigante. Cada varios segundos las paredes cambian de color y usted siente como '+
	      'si lo hubieran trasladado a otro lugar.' ),
      ( name: 'celda peque¤a';
	desc: 'No hay forma alguna de salir.' ),
      ( name: 'un puente de m rmol';
	desc: 'Es muy largo y estrecho.' ),
      ( name: 'la Antesala del Laberinto';
	desc: 'Es una habitaci¢n muy confortable, pero usted siente algo malvado flotando en el aire.' ),
      ( name: 'la cueva del Minotauro';
	desc: 'Hay siete antorchas.' ),
      ( name: 'el Sal¢n de los elegidos';
	desc: 'Usted se enorgullece: muy pocas personas han llegado hasta este sal¢n. El cerebro de la Bestia est  '+
	      'detr s de la puerta.' ),
      ( name: 'un pasillo del Laberinto';
	desc: 'El techo est  tan pegado al suelo que usted tiene que andar agachado. Hay tres puerta sim‚tricas.' ),
      ( name: 'un pasillo del Laberinto';
	desc: 'Hay una puerta que le conducir  a la antesala del Laberinto.' ),
      ( name: 'el Jard¡n';
	desc: 'Se podr¡an construir varias ciudades en su interior.' ));

procedure SetData( var rooms : RoomsAr );
  begin
    with rooms[1]^ do { Exterior }
      begin
	insert( new( PThing, Init( 'Roble', 'Est  completamente seco y lleno de mordiscos. Tiene las siguientes '+
					      'palabras talladas en el tronco: "Las palabras m gicas para abrir la '+
					      'puerta son obvias."', 200 )));
	insert( new( PThing, Init( 'Maza', 'Es muy pesada.', pred(LWeight) )));
	insert( new( PThing, Init( 'Pastel de cerezas', '¨Qu‚ hace un pastel de cerezas en un lugar como este?', 2 )));
	insert( new( PTroll, Init( 'Llamador de bronce', 'Parece de carne, y tiene forma de murci‚lago.', 'Cigarro',
				    decodeLine(key[1]),
                                    '¨Me puede regalar un cigarro?' )));
	insert( new( PLinking, Init( 'Puerta principal', 'Inmensa y oprimente.', decodeLine(key[2]),
				      'Su sombra desaparece lentamente al cruzar la puerta.' +
				      ' Siente c¢mo el miedo se le enreda en los zapatos.', rooms[2] )));
	insert( new( POpenLink, Init( 'T£nel', 'Parece muy largo.',
				       'El olor de la carne descompuesta lo golpea. Usted siente ganas de vomitar.',
                                       rooms[4] )));
	insert( new( PHidden, Init( 'Pared solitaria', 'Usted no puede imaginar con qu‚ motivo fue colocada ah¡.',
				     decodeLine(key[3]), new( PDangerLink, Init( 'Puerta secreta',
				     'Usted se pregunta a d¢nde conducir .', '', 'Usted atraviesa la puerta.',
				     'Antorcha', rooms[27] )))));
      end;
    with rooms[2]^ do { Salon de recepciones }
      begin
	insert( new( PHidden, Init( 'Monolito de m rmol', 'Es muy oscuro, pero a usted le parece que'+
				     ' hay algo vivo en su interior.',
				     decodeLine(key[4]),  new( PTroll, Init( 'Trebol', 'Tiene cinco hojas.', 'Vaso de agua',
					       decodeLine(key[5]),
                                               'Dame agua, por favor...' )))));
	insert( new( PLinking, Init( 'Puerta principal', 'Inmensa y oprimente.', decodeLine(key[2]),
				      'Usted se siente de regreso a la vida. Ha salido de La Fortaleza.', rooms[1] )));
	insert( new( PLinking, Init( 'Puerta negra', 'Es muy negra.', '',
				      'Usted atraviesa la puerta sin dificultades.', rooms[3] )));
	insert( new( PThing, Init( 'Retrato', 'Es de Hitchcock (un anacronismo). Usted recuerda instintivamente ' +
						'algunas pel¡culas que le erizaron la piel: Psicosis, V‚rtigo y ' +
						'Los treinta y nueve escalones.', 1 )));
      end;
    with rooms[3]^ do  { Sala de juegos }
      begin
	insert( new( PThing, Init( 'Escoba', 'Es una escoba voladora.', 1 )));
	insert( new( PRiddleLink, Init( 'Escalera', 'La escalera est  detr s de una puerta de cristal. Usted trata '+
					 'de ver cu ntos escalones tiene, pero no puede.',
                                         '¨Cu ntos pelda¤os tiene la escalera?', decodeLine(key[6]),
                                         'Usted sube por la escalera. No se explica c¢mo, siendo tan larga, solo ' +
					 'tiene '+decodeLine(key[6])+' escalones.', rooms[5] )));
	insert( new( PThing, Init( 'Inscripci¢n', 'Dice: "Cuando hayas llegado casi al final, tendr s que ' +
				    'regresar, a no ser que hayas hablado con el murci‚lago.', 10 )));
	insert( new( PLinking, Init( 'Puerta negra', 'Es muy negra.', '',
				      'Usted atraviesa la puerta sin dificultades.', rooms[2] )));
	insert( new( PLinking, Init( 'Puerta azul', 'Esta puerta conduce al patio interior.', '',
				      'Usted atraviesa la puerta sin dificultades.', rooms[4] )));
	insert( new( PThing, Init( 'Hilo de Ariadna', 'Debe tener varios kil¢metros de largo.', 1 )));
      end;
    with rooms[4]^ do  { Patio interior }
      begin
	insert( new( PLinking, Init( 'Puerta azul', 'Esta puerta conduce a la sala de juegos.', '',
				      'Usted atraviesa la puerta sin dificultades.', rooms[3] )));
	insert( new( PLinking, Init( 'Puerta verde', 'Esta puerta conduce a la biblioteca.', '',
				      'Usted atraviesa la puerta sin dificultades.', rooms[6] )));
	insert( new( PTroll, Init( 'Estatua de Atenea', 'Fue hecha por Fidias, siete a¤os despu‚s de su muerte. '+
				    'Le falta la lanza.', decodeLine(key[7]),
                                    decodeLine(key[8]),
                                    '­Sal de mi presencia, est£pido mortal!' )));
	insert( new( PTroll, Init( 'Estatua de Hermes', 'Desde el techo caen gotas continuamente sobre su cabeza.',
				    decodeLine(key[9]), decodeLine(key[10]),
                                    'La humedad me destruye.' )));
	Insert( new( PThing, Init( 'Balanza', 'La balanza tiene el plato en forma de mano. La aguja es muy '+
				    'delgada, hecha con varios bigotes de gato trenzados entre s¡. ', 1 )));
      end;
    with rooms[5]^ do  { Cuarto de espejos }
      begin
	insert( new( PThing, Init( 'Hueso de gato', 'Este es un hueso de gato (o de la imagen de un gato).', 1 )));
	insert( new( PLinking, Init( 'Escalera', 'Usted trata de ver hasta d¢nde llega, pero no puede. Est  detr s de una '+
				     'puerta de cristal.', 'treinta y nueve',
				     'Usted se sorprende: La escalera tiene ahora muchos escalones m s.', rooms[3] )));
	insert( new( PHidden, Init( 'Espejo opaco', 'En realidad, usted no tiene idea de por qu‚ es un espejo. '+
				     'Hay algo muy extra¤o en ‚l.',
				     decodeLine(key[11]), new( PLinking, Init( 'Puerta oculta',
				     'Parece formada por diminutos '+
				     'fragmentos de cristal.', '',
				     'Su imagen regresa al atravesar la puerta.', rooms[14] )))));
      end;
    with rooms[6]^ do  { Biblioteca }
      begin
	insert( new( PLinking, Init( 'Puerta verde', 'Esta puerta conduce al patio interior.', '',
				      'Usted atraviesa la puerta sin dificultades.', rooms[4] )));
	insert( new( PThing, Init( 'Vaso de agua', 'Por un momento cree ver un bote en el vaso.', 1 )));
	insert( new( PThing, Init( 'Candelabro', 'La llama en su extremo est  inm¢vil, como si fuera de cera.', 1 )));
	insert( new( PLinking, Init( 'Libro', 'Es un libro normal.', '',
				     '­Usted ha atravesado el libro!', rooms[13] )));
	insert( new( PGuard, Init( 'C¡clope', 'Parece estar cuidando la puerta.', '­Arrrggghhhh! ­Me has matado!'+
				    decodeLine(key[12]), decodeLine(key[13]))));
	insert( new( PLinking, Init( 'Puerta', 'Es una puerta para gigantes.', decodeLine(key[14]),
				     'Usted se encuentra del otro lado de la puerta.', rooms[7] )));
      end;
    with rooms[7]^ do  { Pasillo }
      begin
	insert( new( PThing, Init( 'Antorcha', 'La llama parece bailar en su propia luz.', 1 )));
	insert( new( PLinking, Init( 'Puerta', 'Es una puerta para gigantes.', decodeLine(key[14]),
				     'Usted se encuentra del otro lado de la puerta.', rooms[6] )));
	insert( new( PLinking, Init( 'Puerta vieja', 'Es la puerta de las habitaciones de una bruja.', '',
				     'Usted ha entrado.', rooms[8] )));
	insert( new( PLinking, Init( 'Puerta roja', 'Es la puerta del guerrero.', '',
				     'Usted se encuentra del otro lado de la puerta.', rooms[9] )));
	insert( new( PLinking, Init( 'Puerta prohibida', 'Esta puerta est  prohibida para los humanos.', decodeLine(key[15]),
				     'Usted se encuentra del otro lado de la puerta.', rooms[10] )));
	insert( new( PLinking, Init( 'Puerta gris', 'Esta puerta conduce a la sala de las infusiones.', '',
				     'Usted se encuentra del otro lado de la puerta.', rooms[15] )));
      end;
    with rooms[8]^ do  { Alcoba de la bruja }
      begin
	insert( new( PLinking, Init( 'Puerta vieja', 'Da al pasillo.', '', 'Usted ha salido.', rooms[7] )));
	insert( new( PThing, Init( 'Polvo m gico', 'Puede hacer invisible a cualquiera.', 1 )));
	insert( new( PThing, Init( 'Poci¢n para crecer', 'Tiene un olor muy repugnante.', 5 )));
	insert( new( PDangerLink, Init( 'Escaparate', 'Tiene las puertas llenas de ara¤azos.', '',
                                     decodeLine(key[16]), 'Candelabro',
                                     rooms[14] )));
	insert( new( PTroll, Init( 'Bruja', 'Parece tener mil a¤os.', 'Escoba',
				    decodeLine(key[17]),
                                    'Tr eme mi escoba y te dar‚ un consejo.' )));
      end;
    with rooms[9]^ do  { Cuarto del soldado }
      begin
	insert( new( PLinking, Init( 'Puerta roja', 'Da al pasillo.', '', 'Usted est  en el pasillo nuevamente.', rooms[7])));
	insert( new( PThing, Init( 'Vendajes', 'Est n manchados de sangre.', 3 )));
	insert( new( PHidden, Init( 'Cama', 'Es tan fuerte que solo con un hacha podr¡a romperla.',
				     decodeLine(key[18]), new( PLinking, Init( 'Puerta', 'Est  en el suelo.', '',
				     'Usted entra a la armer¡a.', rooms[11] )))));
	insert( new( PThing, Init( 'Grabado', 'En el grabado est  usted, hablando con una muchacha.', 3 )));
      end;
    with rooms[10]^ do  { Laboratorio }
      begin
	insert( new( PLinking, Init( 'Puerta prohibida', 'Esta puerta est  prohibida para los humanos.', decodeLine(key[15]),
				     'Usted se encuentra en el otro lado de la puerta.', rooms[7] )));
	insert( new( PTroll, Init( 'Hom£nculo', 'Parece que escap¢ de alg£n frasco. '+
				    'Es tan peque¤o que usted se arrodilla para verlo.', 'Poci¢n para crecer',
                                    decodeLine(key[20]),
                                    '­Quiero crecer!' )));
	insert( new( PThing, Init( 'Piedra filosofal', 'Usted es el primer humano en ver la quinta escencia.', 10 )));
	insert( new( PThing, Init( 'M quina del tiempo', 'Es muy parecida a una m quina de moler carne.', 3 )));
      end;
    with rooms[11]^ do  { Sala de Armas }
      begin
	insert( new( PThing, Init( 'Espada', 'Es muy brillante.', 5 )));
	insert( new( PThing, Init( 'Lanza', 'Est  hecha de piedra.', 10 )));
	insert( new( PThing, Init( 'Arco', 'Es el arco de Odiseo.', 5 )));
	insert( new( PThing, Init( 'Daga', 'Es afilada como la lengua de la serpiente b¡blica.', 3 )));
	insert( new( PThing, Init( 'Ariete', 'Demasiado grande y pesado.', LWeight - 10 )));
	insert( new( PThing, Init( 'L tigo', 'Parece una culebra.', 2 )));
	insert( new( PLinking, Init( 'Puerta', 'Est  en el techo.', '','Usted regresa al cuarto del guerrero.', rooms[9] )));
      end;
    with rooms[12]^ do  { Ba¤os de la Bestia }
      begin
	insert( new( PLinking, Init( 'Puerta verde', 'Conduce al jard¡n.', '', 'Usted entra al jard¡n.', rooms[13] )));
	insert( new( PThing, Init( 'Rosa', 'Es m s hermosa que todas las doncellas que usted no ha visto.', 1 )));
	insert( new( PThing, Init( 'Inscripci¢n', 'Dice: '#13'­Mate al Troll!'#13'Y no haga sus necesidades '+
				    'en el suelo.', 2 )));
	insert( new( PThing, Init( 'Espejo', 'Usted se ve a s¡ mismo entreg ndole unos polvos al Troll.', 20 )));
	insert( new( PTroll, Init( 'Troll', 'Est  mir ndose en un espejo. Tiene una figura tan repulsiva que usted'+
				    ' aparta la vista.', 'Polvo m gico',
                                    decodeLine(key[22]),
                                    'No me mates, por favor. Haz que nadie pueda ver mi fealdad.' )));
      end;
    with rooms[13]^ do  { Jard¡n }
      begin
	insert( new( PThing, Init( 'Inscripci¢n', 'Es un buen lugar para instalar una tienda de campa¤a ¨no cree?', 1 )));
	insert( new( PThing, Init( 'Cedro', 'Le faltan algunas ramas. Al parecer, alguien las cort¢ '+
				    'para hacerse una cama.', succ(LWeight) )));
	insert( new( PLinking, Init( 'Puerta verde', 'Conduce a los ba¤os de la Bestia.', '',
				      'Usted sale del jard¡n.', rooms[12] )));
	insert( new( PLinking, Init( 'Puerta azul', 'Debe haber algo hemoso detr s de esta puerta.', '',
				      'Usted sale del jard¡n.', rooms[14] )));
	insert( new( PLinking, Init( 'Puerta amarilla', 'Conduce a la sala de infusiones.', '',
				      'Usted sale del jard¡n.', rooms[15] )));
	insert( new( PLinking, Init( 'Puerta de hierro', 'Conduce los calabozos.', '', 'Usted entra a los calabozos.',
				      rooms[16] )));
	insert( new( PLinking, Init( 'Puerta de madera', 'Conduce al almac‚n.', '',
				      'Usted sale del jard¡n.', rooms[23] )));
      end;
    with rooms[14]^ do  { Alcoba de la doncella }
      begin
	insert( new( PLinking, Init( 'Puerta azul', 'Debe haber algo hermoso detr s de esta puerta.', '',
				      'Usted sale al jard¡n.', rooms[13] )));
	insert( new( PLinking, Init( 'Puerta oculta', 'Parece formada por diminutos fragmentos de cristal.', '',
				      'Su imagen regresa al atravesar la puerta.', rooms[5] )));
	insert( new( PThing, Init( 'Cuadro', 'Est  completamente pintado de negro.', 10 )));
	insert( new( PThing, Init( 'Coraz¢n de unicornio', 'A£n late.', 1 )));
	insert( new( PLinking, Init( 'Escaparate', 'Las puertas son doradas.', '',
                                     'Usted sube durante varios minutos hasta llegar al escaparate de la bruja.', rooms[8] )));
	insert( new( PTroll, Init( 'Doncella', 'Nunca antes hab¡a contemplado tanta hermosura. Usted est  como hipnotizado.',
				    decodeLine(key[24]), decodeLine(key[25]),
                                    '­Qu‚ brusco! Un caballero debe dirigirse a una dama de otra forma.' )));
      end;
    with rooms[15]^ do  { Sala de infusiones }
      begin
	insert( new( PLinking, Init( 'Puerta gris', 'Da al pasillo.', '',
				     'Usted se encuentra del otro lado de la puerta.', rooms[7] )));
	insert( new( PLinking, Init( 'Puerta amarilla', 'Conduce al jard¡n.', '', 'Usted sale al jard¡n.', rooms[13] )));
	insert( new( PThing, Init( 'Taza de caf‚', 'Humea.', 1 )));
	insert( new( PThing, Init( 'Cigarro', 'Est  encendido.', 1 )));
	insert( new( PGuard, Init( 'Arp¡a', 'Est  desayunando. Usted recuerda a su suegra sin darse cuenta.',
				    decodeLine(key[26]), decodeLine(key[27]))));
      end;
    with rooms[16]^ do  { Calabozos }
      begin
	insert( new( PLinking, Init( 'Puerta de hierro', 'Conduce al jard¡n.', '', 'Usted sale al jard¡n.', rooms[13] )));
	insert( new( PThing, Init( 'Paraguas', 'Est  cerrado.', 2 )));
	insert( new( PThing, Init( 'Talism n de aire', 'Est  hecho de cinco vientos amarrados con un cord¢n negro.', 1 )));
	insert( new( PTroll, Init( 'Esqueleto', 'Debe tener varios siglos.',
				    'Taza de caf‚', decodeLine(key[29]),
                                    'Dame algo para calentarme la barriga, por favor.' )));
      end;
    with rooms[17]^ do  { Boca }
      begin
	insert( new( PLinking, Init( 'Puerta triangular', 'Tiene forma de un tri ngulo de siete lados.', '',
				      'Usted sale de la boca de la Bestia.', rooms[25] )));
	insert( new( POpenLink, Init( 'Garganta', 'Es roja y carnosa.',
				      'Usted atraviesa por la garganta de la Bestia.', rooms[18] )));
      end;
    with rooms[18]^ do  { Interior }
      begin
	insert( new( PThing, Init( 'Inscripci¢n', 'No contin£e si no est  protegido.', 10 )));
	insert( new( PLinking, Init( 'Garganta', 'Es roja y carnosa.', OpenDoor,
				      'Usted atraviesa por la garganta de la Bestia.', rooms[17] )));
	insert( new( PDangerLink, Init( 'Traquea', 'Luce igual que en los libros de biolog¡a que hab¡a en su escuela.',
					 OpenDoor,
                                         'Usted atraviesa por la tr quea de la Bestia.', decodeLine(key[30]), rooms[19] )));
	insert( new( PDangerLink, Init( 'Esofago', 'Parece un t£nel.', OpenDoor,
					 'Usted atraviesa por el es¢fago de la Bestia.', decodeLine(key[31]), rooms[20] )));
	insert( new( PDangerLink, Init( 'Arteria principal', 'Conduce al coraz¢n seguramente.', OpenDoor,
					 'Usted atraviesa por la arteria principal de la Bestia.', 'Corazon de unicornio',
                                         rooms[21] )));
      end;
    with rooms[19]^ do  { Pulmones }
      begin
	insert( new( PLinking, Init( 'Tr quea', 'Luce igual que en los libros de biolog¡a que hab¡a en su escuela.',
				      OpenDoor, 'Usted atraviesa por la tr quea de la Bestia.', rooms[18] )));
	insert( new( PGuard, Init( 'Centro de los pulmones', 'De aqu¡ surge la vida de los pulmones.',
				    decodeLine(key[35]),
                                    decodeLine(key[32]))));
      end;
    with rooms[20]^ do  { Est¢mago }
      begin
	insert( new( PLinking, Init( 'Es¢fago', 'Parece un t£nel.', OpenDoor,
				      'Usted atraviesa por el es¢fago de la Bestia.', rooms[18] )));
	insert( new( PGuard, Init( 'Centro del estomago', 'De aqu¡ surge la vida del est¢mago.',
				    '­Usted ha matado al centro del est¢mago!',
                                    decodeLine(key[33]))));
      end;
    with rooms[21]^ do  { Coraz¢n }
      begin
	insert( new( PLinking, Init( 'Arteria principal', 'Conduce al coraz¢n seguramente.', OpenDoor,
				      'Usted atraviesa por la arteria principal de la Bestia.', rooms[18] )));
	insert( new( PGuard, Init( 'Centro del coraz¢n', 'De aqu¡ surge la vida del coraz¢n.',
				    decodeLine(key[37]), decodeLine(key[34]))));
      end;
    with rooms[22]^ do  { Cerebro }
      begin
	insert( new( PThing, Init( 'Inscripci¢n', decodeLine(key[39]), 10 )));
	insert( new( PGuard, Init( 'Centro del cerebro', '­Usa la antorcha!', 'XVBCZXV XBVCZX BVZXC!!!!! ',
	decodeLine(key[38]))));
      end;
    with rooms[23]^ do  { Almac‚n }
      begin
	insert( new( PThing, Init( 'Hacha', 'Est  muy afilada.', 10 )));
	insert( new( PLinking, Init( 'Puerta de madera', 'Conduce al jard¡n.', '',
				      'Usted sale del almac‚n.', rooms[13] )));
	insert( new( PLinking, Init( 'Puerta verde', 'Usted presiente que hay algo muy grande detr s de ella.', '',
				      'Usted entra al p ramo.', rooms[24] )));
	insert( new( PTroll, Init( 'Rat¢n', 'Tiene puesto un delantal de alquimista.',
				    decodeLine(key[40]), decodeLine(key[41]),
                                    'No tengo tiempo para atenderte. Llevo medio siglo buscando la quinta escencia.' )));
      end;
    with rooms[24]^ do  { P ramo }
      begin
	insert( new( PLinking, Init( 'Puerta verde', 'Conduce al almac‚n.', '',
				      'Usted sale del p ramo.', rooms[23] )));
	insert( new( PLinking, Init( 'Puerta de cristal', 'Es muy delgada.', decodeLine(key[42]),
				      'Usted sale del p ramo.', rooms[25] )));
	insert( new( POpenLink, Init( 'Pozo', 'Es muy profundo.',
				      'Usted cae vertiginosamente por el pozo y, antes de que pueda darse cuenta, est  en el '+
                                      'exterior de la fortaleza.', rooms[1] )));
	insert( new( PDangerLink, Init( 'T£nel', 'Parece m s acogedor que el t£nel del exterior de la fortaleza.', OpenDoor,
					 '', decodeLine(key[43]), rooms[24] )));
	insert( new( PGuard, Init( 'Lobo', 'Es del tama¤o de un ternero. La £nica forma de pasar por la '+
				    'puerta de cristal es mat ndolo.', decodeLine(key[44]),
				    'Latigo' )));
      end;
    with rooms[25]^ do  { Sala de cristal }
      begin
	insert( new( PLinking, Init( 'Puerta de cristal', 'Es muy delgada.', decodeLine(key[42]),
				      'Usted sale al p ramo.', rooms[24] )));
	insert( new( PLinking, Init( 'Puerta de tela', 'Es una puerta normal, pero de tela.', '',
				      'Usted sale del sal¢n de cristal.', rooms[26] )));
	insert( new( PRiddleLink, Init( 'Puerta triangular', 'Tiene forma de un tri ngulo de siete lados.',
					 '¨Cu l es el nombre del duende?', decodeLine(key[23]),
                                         'Usted entra a la boca de la Bestia.', rooms[17] )));
	insert( new( PTroll, Init( 'Bailarina', 'Es muy joven.', 'M quina del tiempo',
				    decodeLine(key[47]), 'Quiero ser joven para siempre.' )));
      end;
    with rooms[26]^ do  { Celda }
      begin
	insert( new( PThing, Init( 'Inscripci¢n', 'Dice que usted pasar  en esta celda el resto de sus d¡as.',
		succ(LWeight) )));
      end;
    with rooms[27]^ do  { Puente }
      begin
	insert( new( PTroll, Init( 'Ara¤a', 'Es un poco mayor que usted.', 'Hilo de Ariadna',
				    'Busca al Minotauro y m talo con la espada.', '­Pssssssss!' )));
	insert( new( PThing, Init( 'Martillo', 'Tiene dos mangos y tres cabezas.', 2 )));
	insert( new( PDangerLink, Init( 'Puerta secreta', 'Conduce al exterior de la fortaleza.', '',
					 'Usted atraviesa la puerta.', 'Antorcha', rooms[1] )));
	insert( new( PHidden, Init( 'Estatua de Satan s', 'Es infinitamente negra.',
				     'Cuadro', new( PLinking, Init( 'Puerta oculta', 'Conduce a la antesala del laberinto.',
				     '', 'Usted atraviesa la puerta.', rooms[28] )))));
	insert( new( PDangerLink2, Init( 'Puerta', 'Conduce a la antesala del Laberinto.', '',
					 'Usted atraviesa la puerta.', 'Espada', rooms[28] )));
      end;
    with rooms[28]^ do  { Antesala del Laberinto }
      begin
	insert( new( PLinking, Init( 'Puerta', 'Conduce al puente.', '', 'Usted atraviesa la puerta.', rooms[27] )));
	insert( new( PTroll, Init( 'Crunch', 'Es muy similar a una boca con patas.', 'Pastel de cerezas',
				    'El 12 te guiar  en el Laberinto. Luego solo debes dar un paso.', '­Qu‚ hambre!' )));
	insert( new( PHidden, Init( 'Columna de Cristal', 'Es muy alta.',
				     'Antorcha 3',
				     new( PHidden, Init( 'Puerta de madera', 'Parece muy fr gil.', 'Martillo',
				     new( PLinking, Init( 'Puerta negra', 'Conduce al Jard¡n',
				     '', 'Usted entra al Jard¡n.', rooms[50] )))))));
	insert( new( POpenLink, Init( 'Puerta verde', 'Conduce al Laberinto.', 'Usted atraviesa la puerta.', rooms[31])));
	insert( new( PTroll, Init( 'D‚dalo', 'Parece haber sido herido por el cuerno de un toro gigante.', 'Vendajes',
				    'Solo el hierro te proteger  contra las flores.', 'Me muero...' )));
      end;
    with rooms[29]^ do  { Minotauro }
      begin
	insert( new( POpenLink, Init( 'Puerta', 'Conduce al Laberinto.', 'Usted atraviesa la puerta.', rooms[47] )));
	insert( new( PThing, Init( 'Antorcha 1', 'Es muy brillante.', 2 )));
	insert( new( PThing, Init( 'Antorcha 2', 'Es muy brillante.', 2 )));
	insert( new( PThing, Init( 'Antorcha 3', 'Es muy brillante.', 2 )));
	insert( new( PThing, Init( 'Antorcha 4', 'Es muy brillante.', 2 )));
	insert( new( PThing, Init( 'Antorcha 5', 'Es muy brillante.', 2 )));
	insert( new( PThing, Init( 'Antorcha 6', 'Est  apagada.', 2 )));
	insert( new( PThing, Init( 'Antorcha 7', 'Es muy brillante.', 2 )));
	insert( new( PGuard, Init( 'Minotauro', 'Est  sentado en un enorme trono de rocas.',
				    '­Me has matado! Coge la antorcha del n£mero divino y rompe la columna de cristal.',
                                    'Espada')));
      end;
    with rooms[30]^ do  { Salon de los escogidos }
      begin
	insert( new( PRiddleLink, Init( 'Puerta dorada', 'Es de oro macizo.', 'Invente un alfabeto (el mayor que pueda) con '+
                                         'el que no pueda crearse a la Bestia.',
                                         'cdfghjklmnopqruvwxyz',
                                         '­Usted ha entrado al Cerebro de la Bestia!', rooms[22] )));
      end;
    with rooms[31]^ do  { l }
      begin
	insert( new( POpenLink, Init( 'Puerta 1', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[32])));
	insert( new( POpenLink, Init( 'Puerta 2', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[28])));
	insert( new( POpenLink, Init( 'Puerta 3', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[38])));
      end;
    with rooms[32]^ do  { l }
      begin
	insert( new( POpenLink, Init( 'Puerta 1', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[31])));
	insert( new( POpenLink, Init( 'Puerta 2', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[33])));
	insert( new( POpenLink, Init( 'Puerta 3', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[44])));
      end;
    with rooms[33]^ do  { l }
      begin
	insert( new( POpenLink, Init( 'Puerta 1', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[26])));
	insert( new( POpenLink, Init( 'Puerta 2', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[32])));
	insert( new( POpenLink, Init( 'Puerta 3', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[34])));
      end;
    with rooms[34]^ do  { l }
      begin
	insert( new( POpenLink, Init( 'Puerta 1', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[35])));
	insert( new( POpenLink, Init( 'Puerta 2', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[41])));
	insert( new( POpenLink, Init( 'Puerta 3', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[33])));
      end;
    with rooms[35]^ do  { l }
      begin
	insert( new( POpenLink, Init( 'Puerta 1', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[34])));
	insert( new( POpenLink, Init( 'Puerta 2', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[36])));
	insert( new( POpenLink, Init( 'Puerta 3', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[46])));
      end;
    with rooms[36]^ do  { l }
      begin
	insert( new( POpenLink, Init( 'Puerta 1', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[49])));
	insert( new( POpenLink, Init( 'Puerta 2', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[35])));
	insert( new( POpenLink, Init( 'Puerta 3', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[37])));
      end;
    with rooms[37]^ do  { l }
      begin
	insert( new( POpenLink, Init( 'Puerta 1', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[29])));
	insert( new( POpenLink, Init( 'Puerta 2', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[31])));
	insert( new( POpenLink, Init( 'Puerta 3', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[36])));
      end;
    with rooms[38]^ do  { l }
      begin
	insert( new( POpenLink, Init( 'Puerta 1', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[26])));
	insert( new( POpenLink, Init( 'Puerta 2', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[39])));
	insert( new( POpenLink, Init( 'Puerta 3', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[31])));
      end;
    with rooms[39]^ do  { l }
      begin
	insert( new( POpenLink, Init( 'Puerta 1', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[31])));
	insert( new( POpenLink, Init( 'Puerta 2', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[38])));
	insert( new( POpenLink, Init( 'Puerta 3', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[40])));
      end;
    with rooms[40]^ do  { l }
      begin
	insert( new( POpenLink, Init( 'Puerta 1', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[31])));
	insert( new( POpenLink, Init( 'Puerta 2', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[26])));
	insert( new( POpenLink, Init( 'Puerta 3', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[39])));
      end;
    with rooms[41]^ do  { l }
      begin
	insert( new( POpenLink, Init( 'Puerta 1', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[33])));
	insert( new( POpenLink, Init( 'Puerta 2', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[34])));
	insert( new( POpenLink, Init( 'Puerta 3', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[42])));
      end;
    with rooms[42]^ do  { l }
      begin
	insert( new( POpenLink, Init( 'Puerta 1', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[32])));
	insert( new( POpenLink, Init( 'Puerta 2', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[43])));
	insert( new( POpenLink, Init( 'Puerta 3', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[41])));
      end;
    with rooms[43]^ do  { l }
      begin
	insert( new( POpenLink, Init( 'Puerta 1', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[26])));
	insert( new( POpenLink, Init( 'Puerta 2', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[42])));
	insert( new( POpenLink, Init( 'Puerta 3', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[44])));
      end;
    with rooms[44]^ do  { l }
      begin
	insert( new( POpenLink, Init( 'Puerta 1', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[45])));
	insert( new( POpenLink, Init( 'Puerta 2', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[32])));
	insert( new( POpenLink, Init( 'Puerta 3', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[31])));
      end;
    with rooms[45]^ do  { l }
      begin
	insert( new( POpenLink, Init( 'Puerta 1', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[44])));
	insert( new( POpenLink, Init( 'Puerta 2', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[32])));
	insert( new( POpenLink, Init( 'Puerta 3', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[31])));
      end;
    with rooms[46]^ do  { l }
      begin
	insert( new( POpenLink, Init( 'Puerta 1', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[47])));
	insert( new( POpenLink, Init( 'Puerta 2', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[33])));
	insert( new( POpenLink, Init( 'Puerta 3', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[35])));
      end;
    with rooms[47]^ do  { l }
      begin
	insert( new( POpenLink, Init( 'Puerta 1', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[46])));
	insert( new( POpenLink, Init( 'Puerta 2', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[34])));
	insert( new( POpenLink, Init( 'Puerta 3', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[48])));
      end;
    with rooms[48]^ do  { l }
      begin
	insert( new( POpenLink, Init( 'Puerta 1', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[31])));
	insert( new( POpenLink, Init( 'Puerta 2', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[49])));
	insert( new( POpenLink, Init( 'Puerta 3', 'Es id‚ntica a las otras dos.', 'Usted atraviesa la puerta.', rooms[47])));
      end;
    with rooms[49]^ do  { l }
      begin
	insert( new( POpenLink, Init( 'Salida', 'Conduce a la entrada del laberinto.',
				       'Usted regresa a la entrada del Laberinto.', rooms[28])));
      end;
    with rooms[50]^ do  { Jard¡n }
      begin
	insert( new( PThing, Init( 'Inscripci¢n', '­Cuidado! Este no es el Jard¡n verdadero.', 1 )));
	insert( new( PThing, Init( 'Cedro', 'Le faltan algunas ramas. Al parecer, alguien las cort¢ '+
				    'para hacerse una cama.', succ(LWeight) )));
	insert( new( POpenLink, Init( 'Puerta verde', 'Conduce a los ba¤os de la Bestia.',
				       'Usted sale del jard¡n.', rooms[26] )));
	insert( new( POpenLink, Init( 'Puerta azul', 'Debe haber algo hemoso detr s de esta puerta.',
				      'Usted sale del jard¡n.', rooms[26] )));
	insert( new( POpenLink, Init( 'Puerta amarilla', 'Conduce a la sala de infusiones.',
				       'Usted sale del jard¡n.', rooms[26] )));
	insert( new( PRiddleLink, Init( 'Puerta de hierro', 'Conduce los calabozos.',
                                         '¨Cu ntas antorchas iluminan al Minotauro?',
                                         'Seis', 'Usted entra al sal¢n de los elegidos.', rooms[30] )));
	insert( new( POpenLink, Init( 'Puerta de madera', 'Conduce al almac‚n.', 'Usted sale del jard¡n.', rooms[26] )));
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
{
    for i := 1 to 50 do
      begin
        sound( random( 400 ) );
        delay( 10 );
        nosound;
        delay( 5 );
      end;
}
    for i := 400 downto 10 do
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
  if memavail < 80000
    then halt(2);

  OldExitProc := ExitProc;
  ExitProc := @MyExitProc;

  GetTime( hh, mm, x, x );

  textcolor( 2 );
  clrscr;

  for i := 1 to 30 do
    rooms[i] := new( PRoom, Init( RoomAr[i].name, RoomAr[i].desc, succ(LWeight) ));
  for i := 31 to 48 do
    rooms[i] := new( PRoom, Init( RoomAr[31].name, RoomAr[31].desc, succ(LWeight) ));
  rooms[49] := new( PRoom, Init( RoomAr[32].name, RoomAr[32].desc, succ(LWeight) ));
  rooms[50] := new( PRoom, Init( RoomAr[33].name, RoomAr[33].desc, succ(LWeight) ));

  ManX := new( PMan, Init( 'Indy', 'Sad' ));
  f    := new( PFort, Init( ManX, voc ));
  R.Assign( 2, 2, 79, 24 );
  Tele := GetTTY( R );
  PHistTTY(Tele)^.SetHistory( PHistColl(f^.track) );
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
    then f^.Output( 'Buenos d¡as.' )
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
        SuccessSound;
        Tele^.Clear;
        Tele^.NewPaper;
        f^.Output( 'Usted ha vencido a la Bestia.' );
        f^.Output( 'Parece ser una persona persistente y eso es un m‚rito muy grande.' );
        f^.Output( 'La persistencia es indispensable para los que luchan por el bien, ' +
                   'sobre todo porque los que luchan por el mal son muy persistentes tambi‚n.' );
        f^.Output( 'Veremos si en la pr¢xima versi¢n de La Fortaleza tiene igual suerte.' );
        f^.Output( '' );
        f^.Output( '                                             Un servidor:' );
        f^.Output( '                                             M. Cepero' );
        f^.Output( '' );
      end
    else
      begin
        DefeatSound;
        f^.Output( 'Su entierro se efectuar  el pr¢ximo domingo a las 3:00 am. Est  invitado.' );
      end;

  f^.Output( '' );
  f^.Output( '¨Desea salvar su rastro (S/N)?' );
  if upcase(readkey) = 'S'
    then
      begin
	if TrkName = ''
	  then TrkName := _TrackF;
	f^.Output( 'Salvando rastro hacia ' + TrkName );
	f^.SaveTrack( TrkName );
      end;

end.
