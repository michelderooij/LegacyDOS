*  FILE NAME: p_zoekf.PRG
*  BY: 
*  NOTICE: 
*  DATE: 1/15/92
*  DESC:
*  CALLED BY:
*  DATA FILES:
PRIVATE old_col,old_sch,old_rec,tmp,old_ind
PUBLIC naam
naam =SPACE(32)
old_ind =indexord()
SELECT 1
SET ORDER TO 1
old_col =setcolor()
old_rec =RECNO()
setcolor(COLOR [6])
SAVE SCREEN TO old_sch
@12,20 CLEAR TO 14,59
@12,20 TO 14,59 double
@12,31 SAY "[ File - Zoek: ]"
@13,23 GET naam
SET CONFIRM ON 
SET cursor ON 
READ 
SET cursor OFF 
SET CONFIRM OFF 
IF lastkey()=27
   GO old_rec
ELSE 
   type_seek()
   IF (RECNO()=lastrec()+1)
      tone(110,1)
      GO old_rec
   ENDIF 
ENDIF 
RESTORE SCREEN FROM old_sch
setcolor(old_col)
reset_index (old_ind)
KEYBOARD CHR(0)
tmp =INKEY()
RETURN 

FUNCTION type_seek
PRIVATE old_row,old_col
old_col=COL()
old_row=ROW()
SEEK UPPER(alltrim(naam))
IF RECNO()=lastrec()+1
   GO BOTTOM 
ENDIF 
RETURN (.t.)







*Formatted by: dANALYST Gold (Clipper 5.x) V5.0 on 2/16/92 at 1:35 PM.

