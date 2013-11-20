unit TTY;

interface

  uses
    Objects, HistTTY;

  const
    UseEGA: boolean = true;

  function GetTTY( R : TRect ) : PHistTTY;
  function IsEGA               : boolean;

implementation

  uses
    EgaTTY, CgaTTY;

  function IsEGA : boolean; assembler;
    asm
	cmp	UseEGA, 0
	je	@NotEGA
	mov	bl,10h
	mov	ah,12h
	int	10h
	cmp	bl,10h
	je	@NotEGA
	mov	al, 1
	jmp	@Exit
  @NotEGA:
	xor	al, al
  @Exit:
    end;

  function GetTTY( R: TRect ): PHistTTY;
    begin
      if IsEGA
	then GetTTY := new( PEgaTTY, Init( R ))
	else GetTTY := new( PCgaTTY, Init( R ))
    end;

end.