*  FILE NAME: p_afdruk.PRG
*  BY: 
*  NOTICE: 
*  DATE: 1/15/92
*  DESC:
*  CALLED BY:
*  DATA FILES:

PRIVATE klaar,s,c,n
SELECT 1
IF lastrec()=0
   p_help ("EMPTY_BASE",0,"")
   rest_logo()
   RETURN 
ENDIF 
klaar =.f.
s =0
DO WHILE !klaar
   s =s +1
   IF s =249
      klaar =.t.
   ENDIF 
   IF prn_status(0)=144
      klaar =.t.
   ENDIF 
ENDDO 
PRIVATE keuze2
old_col=setcolor()
setcolor (COLOR [2])
@1,20 CLEAR TO 5,46
@1,20 TO 5,46
@2,21 PROMPT " Programmalijst         "
@3,21 PROMPT " Diskettelijst          "
@4,21 PROMPT " Categorielijst         "
MENU TO keuze2
IF keuze2 <>0
   IF prn_tofile ="N"
      IF prn_status(0)!=144 
         p_help ("NO_PRINT",0,"")
         rest_logo()
         RETURN 
      ENDIF &
   ENDIF 
   prn_init(0)
   IF lastkey()!=27
      SET KEY 28 TO 
      setcolor (COLOR [3])
      s =0
      @10,9 TO 14,70
      @11,10 CLEAR TO 13,69
      IF prn_tofile ="N"
         @12,12 SAY "Positioneer papier en druk op een toets. [Esc] = Terug"
         s =INKEY(0)
      ENDIF 
      IF s !=27 .or. prn_tofile ="J"
         @12,12 SAY "Bezig met printen. [Esc] breekt printen af ...        "
         SET CONSOLE OFF 
         SET PRINT ON 
         IF prn_tofile ="J"
            SET PRINTER TO &prn_filename
         ENDIF 
         prn_instel()
         DO CASE 
         CASE keuze2 =1
            DO p_prnprg
         CASE keuze2 =2
            DO p_prndsk
         CASE keuze2 =3
            DO p_prncat
         ENDCASE 
         IF lastkey()!=27
            tone (440,1)
            tone (220,1)
            tone (660,1)
         ENDIF 
         SET CONSOLE ON 
         SET PRINT OFF 
      ENDIF 
   ENDIF 
ENDIF 
setcolor (old_col)
rest_logo()
SET KEY 28 TO p_help
RETURN 








*Formatted by: dANALYST Gold (Clipper 5.x) V5.0 on 2/16/92 at 1:34 PM.

