*  FILE NAME: p_prncat.PRG
*  BY: 
*  NOTICE: 
*  DATE: 1/15/92
*  DESC:
*  CALLED BY:
*  DATA FILES:
PRIVATE FILT ,l,f1,f2,f3,f4,f5,pagenr,regel,oud,f0,oudarc
PRIVATE ch1,ch2,ch3,ch4
IF UPPER(prn_ibmgraf)="J"
   ch1 ="Ä"
   ch2 ="³"
   ch3 ="Á"
   ch4 ="Å"
ELSE 
   ch1 ="-"
   ch2 ="|"
   ch3 ="-"
   ch4 ="+"
ENDIF 
l =REPLICATE(" ",prn_leftmrg)
SELECT 1
SET ORDER TO 3
filt =""
IF UPPER(prn_merk)="N"
   filt =FILT +"(programs->merk = .T.)"
ENDIF 
IF UPPER(prn_norm)="N"
   filt =FILT +"(programs->merk = .F.)"
ENDIF 
SET FILTER TO &filt
GO TOP 
klaar =.f.
n =1
regel =1
pagenr =1
PRINTER (l+"Categori‰enlijst gegenereerd met "+uid+" op "+DTOC(DATE())+" om "+TIME())
PRINTER ("")
PRINTER (l+"CATNo."+ch2+" CATEGORIE            "+ch2+;
   " PROGRAMMA                     "+ch2+" DISK  "+ch2+"  DISKS   ")
PRINTER (l+REPLICATE(ch1,6)+ch4+REPLICATE(ch1,22)+ch4+REPLICATE(ch1,31)+ch4+;
   REPLICATE(ch1,7)+ch4+REPLICATE(ch1,9))
oud =999
DO WHILE .not. klaar
   SELECT 1
   f4 =programs->name
   f2 =programs->catnr
   f5 =programs->disknr
   SELECT 2
   SEEK f5
   f3 =disknrs->typenr
   SELECT 3
   SEEK f3
   IF programs->disks =0
      f3 =" 1"
   ELSE 
      f3 =STR(programs->disks,2)
   ENDIF 
   f1 =f3+"x"+(typenrs->capacity)
   IF f2 =oud
      f0 =SPACE(6)
      f2 =SPACE(20)
      f5 =programs->disknr
   ELSE 
      oud =f2
      SELECT 6
      SEEK f2
      f2 =category->category
      f0 ="  "+RIGHT("      "+alltrim(STR(programs->catnr,6)),2)+"  "
   ENDIF 
   PRINTER (l+f0+ch2+" "+f2+" "+ch2+" "+f4+ch2+" "+f5+" "+ch2+" "+f1)
   SELECT 1
   SKIP 1
   regel =regel+1
   IF regel =prn_pagelen -5
      PRINTER (l+REPLICATE(ch1,6)+ch3+REPLICATE(ch1,22)+ch3+REPLICATE(ch1,31)+ch3+;
         REPLICATE(ch1,7)+ch3+REPLICATE(ch1,9))
      PRINTER ("")
      PRINTER (l+"                                 Pagina "+alltrim(STR(pagenr)))
      PRINTER (CHR(12))
      PRINTER (l+"CATNo."+ch2+" CATEGORIE            "+ch2+;
         " PROGRAMMA                     "+ch2+" DISK  "+ch2+"  DISKS   ")
      PRINTER (l+REPLICATE(ch1,6)+ch4+REPLICATE(ch1,22)+ch4+REPLICATE(ch1,31)+ch4+;
         REPLICATE(ch1,7)+ch4+REPLICATE(ch1,9))
      pagenr =pagenr +1
      regel =1
   ENDIF 
   f1 =INKEY()
   IF EOF() .or. lastkey()=27
      klaar =.t.
   ENDIF 
ENDDO 
IF lastkey()!=27 .and. regel !=1
   PRINTER (l+REPLICATE(ch1,6)+ch3+REPLICATE(ch1,22)+ch3+REPLICATE(ch1,31)+ch3+;
      REPLICATE(ch1,7)+ch3+REPLICATE(ch1,9))
   DO WHILE regel !=prn_pagelen -5
      regel =regel +1
      PRINTER ("")
   ENDDO 
   PRINTER ("")
   PRINTER (l+"                                 Pagina "+alltrim(STR(pagenr)))
   PRINTER (CHR(12))
ENDIF 
SELECT 1
SET ORDER TO 1
SET FILTER TO 
RETURN 






*Formatted by: dANALYST Gold (Clipper 5.x) V5.0 on 2/16/92 at 1:36 PM.

