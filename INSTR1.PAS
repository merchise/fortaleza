unit Instr1;

interface

  procedure Instructions;

implementation

  uses
    Crt, Win, Scroller;

  const
    Inst : array[ 1..41 ] of string[80] = (
'',
'Usted es un hombre com£n, sumergido en una vida rutinaria y mediocre. D¡a',
'tras d¡a espera que algo interesante aparezca en su camino. Una ma¤ana, luego',
'de haber le¡do el peri¢dico, encuentra una carta junto a la puerta. Desde la',
'sala se acerca un ruido de tacones. Usted rompe el sobre y guarda',
'nerviosamente la carta en un bolsillo. Su mujer acaba de pasar.',
'Ahora est  solo. Usted despliega el papel y comienza a leer.',
'',
' "Estimado se¤or:',
'  Tengo el alto honor de comunicarle que usted ha sido designado para cumplir',
'  una de las misiones m s importantes de la historia del hombre: Eliminar a',
'  la Bestia.',
'',
'Usted levanta los ojos y se pregunta "¨Qui‚n ser  la Bestia esa? Debe ser',
'alg£n presidiario que ha escapado, o un narcotraficante". Usted contin£a',
'leyendo.',
'',
' "La Bestia es una de las criaturas m s temidas y misteriosas del universo.',
'  Seg£n varios informes que nos han llegado £ltimamente, habita un lugar',
'  llamado la Fortaleza, aunque hay quienes dicen que la Bestia y la',
'  Fortaleza son una misma cosa. Nadie ha visto a la Bestia (quienes lo',
'  hicieron no pudieron contarlo nunca). Solo sabemos que la Fortaleza',
'  aparece todos los martes 24 de abril en los a¤os bisiestos, o sea,',
'  casi nunca.',
'  Su misi¢n es: adentrarse en la Fortaleza y matar a la Bestia. Nada m s.',
'',
'  Tenga preparada una muda de ropa (ropa de trabajo preferiblemente) para',
'  cuando vayamos a buscarlo.',
'',
'',
'                                            General X',
'                                 Jefe de la Oficina de Casualidades"',
'',
'',
'Usted guarda el papel lentamente. No puede creer lo que est  ocurriendo.',
'¨Por qu‚ yo?, se pregunta.',
'Hay que ver las vueltas que da la vida. Varios minutos antes usted estaba',
'ansioso de que ocurriese algo especial. Deb¡a estar satisfecho.',
'Uno no sabe con cu l se gana y con cu l se pierde.',
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
      ScrollText( Inst, 41 );
    end;

end.