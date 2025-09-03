*  FILE NAME: p_prndsk.PRG
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
SET ORDER TO 2
filt =""
IF UPPER(prn_merk)="N"
   filt = FILT +"(programs->merk = .T.)"
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
PRINTER (l+"Diskettelijst gegenereerd met "+uid+" op "+DTOC(DATE())+" om "+TIME())
PRINTER ("")
PRINTER (l+"DISKNo"+ch2+" DISK  "+ch2+" No.DISKS "+ch2+" CATEGORIE           "+;
   ch2+" PROGRAMMA                     ")
PRINTER (l+REPLICATE(ch1,6)+ch4+REPLICATE(ch1,7)+ch4+REPLICATE(ch1,10)+;
   ch4+REPLICATE(ch1,21)+ch4+REPLICATE(ch1,31))
oud ="!@#$%"
oudarc =99999
DO WHILE .not. klaar
   SELECT 1
   f1 =programs->name
   f2 =programs->disknr
   IF f2 =oud
      f0 =SPACE(6)
      f2 =SPACE(5)
      f4 =SPACE(8)
      f5 =programs->catnr
      IF f5=oudarc
         f5=SPACE(20)
      ELSE 
         oudarc =f5
         SELECT 6
         SEEK f5
         f5 =category->category
      ENDIF 
   ELSE 
      oud =f2
      f0 =RIGHT("      "+alltrim(STR(n,6)),6)
      IF programs->disks =0
         n =n +1
         f3 =" 1"
      ELSE 
         n =n +disks
         f3 =STR(programs->disks,2)
      ENDIF 
      f5 =programs->catnr
      oudarc =f5
      SELECT 2
      SEEK f2
      f4 =disknrs->typenr
      SELECT 3
      SEEK f4
      f4 =f3+"x"+(typenrs->capacity)
      SELECT 6
      SEEK f5
      f5 =category->category
   ENDIF 
   PRINTER (l+f0+ch2+" "+f2+" "+ch2+" "+f4+" "+ch2+" "+f5+ch2+" "+f1)
   SELECT 1
   SKIP 1
   regel =regel+1
   IF regel =prn_pagelen -5
      PRINTER (l+REPLICATE(ch1,6)+ch3+REPLICATE(ch1,7)+ch3+REPLICATE(ch1,10)+;
         ch3+REPLICATE(ch1,21)+ch3+REPLICATE(ch1,31))
      PRINTER ("")
      PRINTER (l+"                                 Pagina "+alltrim(STR(pagenr)))
      PRINTER (CHR(12))
      PRINTER (l+"DISKNo"+ch2+" DISK  "+ch2+" No.DISKS "+ch2+" CATEGORIE           "+;
       ch2+" PROGRAMMA                     ")
      PRINTER (l+REPLICATE(ch1,6)+ch4+REPLICATE(ch1,7)+ch4+REPLICATE(ch1,10)+;
       ch4+REPLICATE(ch1,21)+ch4+REPLICATE(ch1,31))
      pagenr =pagenr +1
      regel =1
   ENDIF 
   f1 =INKEY()
   IF EOF() .or. lastkey()=27
      klaar =.t.
   ENDIF 
ENDDO 
IF lastkey()!=27 .and. regel !=1
   PRINTER (l+REPLICATE(ch1,6)+ch3+REPLICATE(ch1,7)+ch3+REPLICATE(ch1,10)+;
      ch3+REPLICATE(ch1,21)+ch3+REPLICATE(ch1,31))
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







*Formatted by: dANALYST Gold (Clipper 5.x) V5.0 on 2/16/92 at 1:35 PM.

