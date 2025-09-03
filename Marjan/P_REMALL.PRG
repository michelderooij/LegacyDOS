*  FILE NAME: p_remall.PRG
*  BY: 
*  NOTICE: 
*  DATE: 1/15/92
*  DESC:
*  CALLED BY:
*  DATA FILES:
PRIVATE old_col,_ans,tmp,prog,x,rn,rd,todel,delrec,last
old_col=setcolor()
setcolor (COLOR [3])
SAVE SCREEN 
@6,9 TO 18,70
@7,10 CLEAR TO 17,69
_ans ="J"
SET cursor ON 
SET CONFIRM OFF 
@8,12 SAY "þ Tevens disks verwijderen ? ";
   GET _ans PICTURE "!"valid (_ans $"jnJN")
READ 
SET CONFIRM ON 
IF lastkey()<>27
   @9,12 SAY "þ Waarschuwing : Na deze actie zijn alle programma's"
   @10,12 SAY "  voorgoed verdwenen. Doorgaan ?"
   IF sure()
      SET KEY 28 TO 
      @7,10 CLEAR TO 17,69
      @9,12 SAY "þ Verwijderen records ..."
      SELECT 1
      ZAP 
      IF UPPER(_ans)="J"
         SELECT 2
         ZAP 
      ENDIF 
      @11,12 SAY "Klaar met actie. Druk een toets voor menu ..."
      SET cursor ON 
      SELECT 1
      INKEY(0)
   ENDIF 
ENDIF 
SELECT 1
RESTORE SCREEN 
setcolor (old_col)
SET KEY 28 TO p_help
RETURN 








*Formatted by: dANALYST Gold (Clipper 5.x) V5.0 on 2/16/92 at 1:36 PM.

