*  FILE NAME: p_zoekd.PRG
*  BY: 
*  NOTICE: 
*  DATE: 1/15/92
*  DESC:
*  CALLED BY:
*  DATA FILES:
PRIVATE old_col,old_sch,old_rec,tmp,old_ind
PUBLIC disk
disk =SPACE(5)
old_ind =indexord()
SELECT 1
SET ORDER TO 2
old_col =setcolor()
old_rec =RECNO()
setcolor(COLOR [6])
SAVE SCREEN TO old_sch
@12,29 CLEAR TO 14,49
@12,29 TO 14,49 double
@12,31 SAY "[ Disk - Zoek: ]"
@13,36 GET disk
SET CONFIRM ON 
SET cursor ON 
READ 
SET cursor OFF 
SET CONFIRM OFF 
IF lastkey()=27
   GO old_rec
ELSE 
   disk_seek()
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

FUNCTION disk_seek
PRIVATE old_row,old_col
SEEK alltrim(disk)
IF RECNO()=lastrec()+1
   GO BOTTOM 
ENDIF 
RETURN (.t.)







*Formatted by: dANALYST Gold (Clipper 5.x) V5.0 on 2/16/92 at 1:35 PM.

