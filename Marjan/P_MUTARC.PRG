*  FILE NAME: p_mutarc.PRG
*  BY: 
*  NOTICE: 
*  DATE: 1/15/92
*  DESC:
*  CALLED BY:
*  DATA FILES:
PRIVATE old_col,old_sch,veld[1],HEADING [1]
KEYBOARD CHR(31)
veld[1]="arcnrs->arcname"
HEADING [1]="Archief-prg."
SELECT 4
GO TOP 
old_col =setcolor(COLOR [2])
keybar (24,10,"~Ins~ Nieuw")
setcolor(COLOR [3])
SAVE SCREEN TO old_sch
@4,27 TO 20,51 double
dbedit (5,28,19,50,veld,"udf_mutarc","",HEADING )
setcolor(old_col)
RESTORE SCREEN FROM old_sch
SELECT 1
RETURN 

FUNCTION udf_mutarc
PARAMETERS mode,nr
PRIVATE KEY 
key =lastkey()
DO CASE 
CASE KEY =27
   RETURN 0
CASE KEY =22 .and. lastrec()<99
   new_arc()
   SET cursor OFF 
   RETURN 2
CASE KEY =13 .or. mode =4
   IF mode =4 .and. KEY >0
      edit_arc(nr,CHR(KEY ))
   ELSE 
      edit_arc(nr,"")
   ENDIF 
   SET cursor OFF 
   RETURN 1
ENDCASE 

IF mode =1
   tone (440,0)
   CLEAR TYPEAHEAD 
ENDIF 

IF mode =2
   tone (440,0)
   CLEAR TYPEAHEAD 
ENDIF 

SET cursor OFF 
RETURN 1

PROCEDURE new_arc
IF lastrec()>12
   scroll (7,28,19,50,1)
ENDIF 
edit_iarc (19,SPACE(20),"",.t.)
RETURN 

PROCEDURE edit_arc
PARAMETERS veld_nr,k
edit_iarc (ROW(),(arcnrs->arcname),k,.f.)
RETURN 

PROCEDURE edit_iarc
PARAMETERS ed_row,a_name,k,n_a
PRIVATE old_col,tmp
old_col =setcolor()
setcolor(COLOR [5])
@ed_row,29 GET a_name
SET cursor ON 
IF k =CHR(13)
   k =""
ENDIF 
KEYBOARD k
READ 
setcolor (COLOR [3])
IF lastkey()<>27 .and. UPDATED()
   SELECT 4
   IF n_a =.t.
      APPEND BLANK 
   ENDIF 
   tmp =RECNO()-1
   REPLACE arcnrs->arcnr WITH tmp
   REPLACE arcnrs->arcname WITH a_name
   COMMIT 
ENDIF 
KEYBOARD CHR(0)
ds =INKEY()
setcolor(old_col)
RETURN 







*Formatted by: dANALYST Gold (Clipper 5.x) V5.0 on 2/16/92 at 1:36 PM.

