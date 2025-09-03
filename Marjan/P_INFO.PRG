*  FILE NAME: p_info.PRG
*  BY: 
*  NOTICE: 
*  DATE: 1/15/92
*  DESC:
*  CALLED BY:
*  DATA FILES:
PRIVATE keuze2
old_col=setcolor()
setcolor (COLOR [2])
@1,01 CLEAR TO 5,13
@1,01 TO 5,13
@2,02 PROMPT " Databases "
@3,02 PROMPT " Systeem   "
@4,02 PROMPT " Marjan    "
MENU TO keuze2
IF keuze2 <>0
   DO CASE 
   CASE keuze2 =1
      DO p_inf1
   CASE keuze2 =2
      DO p_inf2
   CASE keuze2 =3
      DO p_help WITH "INFO_PRG",0,0
   ENDCASE 
ENDIF 
setcolor (old_col)
rest_logo()
RETURN 




*Formatted by: dANALYST Gold (Clipper 5.x) V5.0 on 2/16/92 at 1:33 PM.

