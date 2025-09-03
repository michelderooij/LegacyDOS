*  FILE NAME: p_help.PRG
*  BY: 
*  NOTICE: 
*  DATE: 1/15/92
*  DESC:
*  CALLED BY:
*  DATA FILES:
PRIVATE old_scr,old_col,helptekst,tmp,y,o_x,o_y,nl,bl,tl
PARAMETERS call_proc,call_line,call_invar
PRIVATE old_work
IF call_proc $"P_OPTIES|P_AFDRUK|P_INFO"
   call_proc ="P_MAIN"
ENDIF 
o_y =ROW()
o_x =COL()
old_work =SELECT()
SET KEY 28 TO 
SELECT 5
SEEK (call_proc)
IF FOUND()
   helptekst =RTRIM(helptext->tekst)
ELSE 
   helptekst ="Geen help-tekst aanwezig voor dit onderdeel ("+call_proc+")."
ENDIF 
SAVE SCREEN TO old_scr
old_col =setcolor()
setcolor (COLOR [4])
SET cursor OFF 
nl =mlcount(helptekst,59)
tmp =INT(nl/2)
nl =nl-tmp
tl =12-tmp
bl =11+nl
@tl-2,08 TO bl+2,72
@tl-1,09 CLEAR TO bl+1,71
@bl+2,61 SAY "[Esc]"
tmp =savescreen (tl,62,bl,64)
FOR y =2 TO 6 STEP 2
   tmp =STUFF(tmp,y,1,CHR(ASC(SUBSTR(tmp,y,1))+128))
NEXT y
restscreen (tl,62,bl,64,tmp)
CLEAR TYPEAHEAD 
KEYBOARD CHR(27)
MEMOEDIT(helptekst,tl,10,bl,70,.F.)
CLEAR TYPEAHEAD 
INKEY(0)
DO WHILE lastkey() != 27
   INKEY(0)
ENDDO
IF AT(call_proc,"EDIT_ITEM|P_ZOEK|EDIT_IARC|P_REMALL|P_ONDERH|SURE|P_PRNSET"+;
   "P_ZOEKF|P_ZOEKD|P_ULT3")>0
   SET cursor ON 
ENDIF 
SET KEY 28 TO p_help
SELECT (old_work)
setcolor(old_col)
@o_y,o_x SAY ""
RESTORE SCREEN FROM old_scr
RETURN 





*Formatted by: dANALYST Gold (Clipper 5.x) V5.0 on 2/16/92 at 1:33 PM.

