*  FILE NAME: p_inf2.PRG
*  BY: 
*  NOTICE: 
*  DATE: 1/15/92
*  DESC:
*  CALLED BY:
*  DATA FILES:
old_col=setcolor()
setcolor (COLOR [3])
@03,22 CLEAR TO 21,56
@03,22 TO 21,56
@04,24 SAY "şÄÄÄÄÄÄÄÄ Drive: ÄÄÄÄÄÄÄÄÄÄÄÄÄ"
@05,24 SAY "ù Huidige drive....: "+"" && CHR(65+GetDisk())+":"
@06,24 SAY "ù Totale ruimte....: "+"" && Num2Eng(DiskTotal(0))+"b"
@07,24 SAY "ù Vrije ruimte.....: "+Num2Eng(DISKSPACE(0))+"b"
@09,24 SAY "şÄÄÄÄÄÄÄ Machine: ÄÄÄÄÄÄÄÄÄÄÄÄ"
@10,24 SAY "ù Dos versie.......: "+Alltrim(STR(O_DOSVer()/100,10,2))
@11,24 SAY "ù Processor........: "+Cputype()
@12,24 SAY "ù ROM BIOS datum...: "+"" && DTOC(RomDate())
@14,24 SAY "şÄÄÄÄÄÄÄ Geheugen: ÄÄÄÄÄÄÄÄÄÄÄ"
@15,24 SAY "ù Totaal geheugen..: "+Num2Eng(TOTMEM()*1000)+"b"
@16,24 SAY "ù Vrij geheugen....: " // +Num2Eng(BLIMEMAVL(0))+"b"
@18,24 SAY "şÄÄÄÄÄÄÄÄÄ Video: ÄÄÄÄÄÄÄÄÄÄÄÄ"
@19,24 SAY "ù Video-kaart......: "+SUBSTR("????????????????HerculesCGA monoCGA col.EGA     VGA     ",(adapter-1)*8+1,8)
@21,50 SAY "[Esc]"
CLEAR TYPEAHEAD 
INKEY(0)
DO WHILE lastkey() != 27
   INKEY(0)
ENDDO
setcolor (old_col)
RETURN 




*Formatted by: dANALYST Gold (Clipper 5.x) V5.0 on 2/16/92 at 1:35 PM.

