unit EqString;

interface

  function Equals( s1, s2 : string ) : boolean;

implementation

  uses
    Lexic;

  type
    WordArr =
      record
        count : integer;
        arr   : array[1..10] of string[20];
      end;

  procedure Split( str : string ; var arr : WordArr );
    var
      i : integer;
      j : integer;
      p : integer;
    begin
      i := 1;
      p := 1;
      j := 0;
      for i := 1 to length(str) do
        if (str[i] = ' ') or (i = length(str))
          then
            begin
              inc(j);
	      arr.arr[j] := copy( str, p, i - p + ord(i = length(str)) );
	      p          := succ(i);
            end;
      arr.count := j
    end;

  function StrMatch( s1, s2 : string ) : boolean;
    begin
      StrMatch := s1 = s2
    end;

  function Equals( s1, s2 : string ) : boolean;
    var
      arr1, arr2 : WordArr;
      match      : integer;
      i, j       : integer;
    begin
      Split( s1, arr1 );
      Split( s2, arr2 );
      match := 0;
      i     := 1;
      j     := 1;
      while (match < arr2.count) and (i <= arr1.count) do
        begin
          while (match < arr2.count) and (j <= arr2.count) do
            begin
	      if StrMatch( arr1.arr[i], arr2.arr[j] )
                then inc( match );
              inc( j );
            end;
          inc( i );
          j := 1;
        end;
      Equals := (match >= arr2.count) and (arr2.count > 0)
    end;

end.