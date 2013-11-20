unit Instr2;

interface

  procedure Instructions;

implementation

  uses
    Crt, Win, Scroller;

  const
    Inst : array[ 1..32 ] of string[80] = (
'',
'Bien, esta es la primera secuela de La Fortaleza. Pudi‚ramos llamarla "El re-',
'greso de la  Fortaleza" por ser  una segunda parte  (¨nunca fueron buenas?) y',
'porque su misi¢n no es otra que regresar al mundo exterior.',
'',
'Ante todo haremos un peque¤o resumen de la primera parte, para que los que no',
'tuvieron la buena (o mala) fortuna de adentrarse en ella:',
'',
'Usted, un pobre terr¡cola sumido en el anonimato, fue elegido para eliminar a',
'la Bestia, una de las criaturas m s horribles y temidas del universo.',
'La Bestia habitaba la Fortaleza de una forma muy singular. Estaba embotada en',
'la Fortaleza misma, en cada pared, en cada  habitaci¢n, en el aire y en la',
'luz. Su misi¢n era eliminar a la Bestia.',
'',
'Hasta aqu¡ el resumen. Veamos que tiene que hacer ahora.',
'',
'Si bien  en la  primera parte  usted deb¡a acabar  con una  vida, ahora est ',
'obligado a salvar otra: la suya.',
'',
'La Bestia hab¡a planeado una  venganza terrible. En el mismo instante en que',
'usted la  destruy¢, ella  ech¢ a andar  su diab¢lico  plan. Usted qued¢ pro-',
'fundamente dormido mientras la Fortaleza  cambiaba. Cada  cosa se descompuso',
'en un caudal £nico y luego, a  partir de esa  masa gigantesca, reapareci¢ la',
'Fortaleza.',
'',
'Usted despierta en un cuarto, habiendo perdido toda noci¢n de tiempo y espa-',
'cio, y debe tratar de salir. La Bestia ha dejado una persona (si se le puede',
'llamar as¡) encargada de que usted perezca irremediablemente.',
'',
'Mantenga la mente abierta.',
'',
'' );

  procedure Instructions;
    begin
      window( 1, 1, 80, 25 );
      textcolor( 7 );
      textbackground( 0 );
      clrscr;
      writechar( 1,  1, 80, ' ', $70 );
      writestr( 40 - length('Introducci¢n') div 2, 1, 'Introducci¢n', $70 );
      writechar( 1,  25, 80, ' ', $70 );
      writestr( 2, 25, '³  ³  ³ PgUp PgDn ³  ³ Home End ³  ³ ESC ³', $70 );
      ScrollText( Inst, 32 );
    end;

end.