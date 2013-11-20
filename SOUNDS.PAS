unit Sounds;

interface

  uses
    Crt;

  procedure LaserShoot;
  procedure Step;
  procedure Ouch;
  procedure MiniRap;
  procedure Rap;
  procedure FunnyMusic;
  procedure Pause;
  procedure Thunder;


implementation

  procedure LaserShoot;
    var
      i : word;
    begin
      for i := 15 downto 0 do
        begin
          sound(300*i + random(10*i));
          delay(3);
          nosound;
          delay(1);
        end;
    end;

  procedure Step;
    var
      i : word;
    begin
      for i := 1 to 100 do
        sound( 300 + random(100) );
      nosound;
    end;

  procedure Ouch;
    var
      i : word;
    begin
      for i := 100 downto 1 do
        begin
          sound( 5*i );
          delay(random(4));
          nosound;
          delay(random(2));
        end;
      sound(20);
      delay(200);
      nosound;
    end;

  procedure MiniRap;
    begin
      LaserShoot;
      LaserShoot;
      sound(20);
      delay(100);
      LaserShoot;
      delay(100);
      Ouch;
      LaserShoot;
      sound( 50 );
      delay(200);
      LaserShoot;
      LaserShoot;
      LaserShoot;
      delay(100);
      Ouch;
      Ouch;
    end;

  procedure Rap;
    begin
      LaserShoot;
      LaserShoot;
      LaserShoot;
      Ouch;
      sound(100);
      delay(100);
      LaserShoot;
      Ouch;
      LaserShoot;
      delay(100);
      LaserShoot;
      Ouch;
      LaserShoot;
      sound(200);
      delay(100);
      nosound;
    end;

  procedure FunnyMusic;
    var
      i, j, f : word;
    begin
      for j := 4 downto 1 do
        begin
          f := 10 + random(100)*j;
          for i := 0 to 5 do
            begin
              sound( 20*f*i );
              delay( 20 );
              nosound;
              delay( 10 );
            end;
        end;
    end;

  procedure Pause;
    begin
      FunnyMusic;
      FunnyMusic;
      FunnyMusic;
      FunnyMusic;
      FunnyMusic;
      LaserShoot;
      LaserShoot;
      LaserShoot;
      Ouch;
    end;

  procedure Thunder;
    begin
      LaserShoot;
      LaserShoot;
      LaserShoot;
      LaserShoot;
      Ouch;
    end;

end.