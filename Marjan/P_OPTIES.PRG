*  FILE NAME: p_opties.PRG
*  BY: 
*  NOTICE: 
*  DATE: 1/15/92
*  DESC:
*  CALLED BY:
*  DATA FILES:
PRIVATE keuze2
old_col=setcolor()
setcolor (COLOR [2])
@1,29 CLEAR TO 8,56
@1,29 TO 8,56
@2,30 PROMPT " Onderhoud bestanden    "
@3,30 PROMPT " Archieflijst muteren   "
@4,30 PROMPT " Categorielijst muteren "
@5,30 PROMPT " Alles verwijderen      "
@6,30 PROMPT " Configuratie           "
@7,30 PROMPT " Kleuren instellen      "
MENU TO keuze2
IF keuze2 <>0
   DO CASE 
   CASE keuze2 =1
      DO p_onderh
   CASE keuze2 =2
      DO p_mutarc
   CASE keuze2 =3
      DO p_mutcat
   CASE keuze2 =4
      DO p_remall
   CASE keuze2 =5
      DO p_prnset
   CASE keuze2 =6
      DO p_color
   ENDCASE 
ENDIF 
setcolor (old_col)
rest_logo()
RETURN 






*Formatted by: dANALYST Gold (Clipper 5.x) V5.0 on 2/16/92 at 1:34 PM.

