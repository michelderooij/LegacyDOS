*  FILE NAME: p_prnprg.PRG
*  BY: 
*  NOTICE: 
*  DATE: 1/15/92
*  DESC:
*  CALLED BY:
*  DATA FILES:
PRIVATE FILT ,l,f1,f2,f3,f4,f5,pagenr,regel
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
SET ORDER TO 1
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
n =0
regel =1
pagenr =1
PRINTER (l+"Programmalijst gegenereerd door "+uid+" op "+DTOC(DATE())+" om "+TIME())
PRINTER ("")
PRINTER (l+"RECNo."+ch2+" PROGRAMMA                     "+ch2+" DISK  "+;
   ch2+" No.DISKS "+ch2+" CATEGORIE           ")
PRINTER (l+REPLICATE(ch1,6)+ch4+REPLICATE(ch1,31)+ch4+REPLICATE(ch1,7)+ch4+;
   REPLICATE(ch1,10)+ch4+REPLICATE(ch1,21))

DO WHILE !klaar
   n =n +1
   SELECT 1
   f1 =programs->name
   f2 =programs->disknr
   f3 =programs->disks
   f5 =programs->catnr
   SELECT 2
   SEEK f2
   f4 =disknrs->typenr
   SELECT 3
   SEEK f4
   f4 =typenrs->capacity
   SELECT 6
   SEEK f5
   f5 =category->category
   PRINTER (l+RIGHT("       "+alltrim(STR(n,6)),6)+ch2+" "+f1+ch2+" "+f2+;
      " "+ch2+" "+STR(f3,2)+"x"+f4+" "+ch2+" "+f5)
   SELECT 1
   SKIP 1
   regel =regel+1
   IF regel =prn_pagelen -5
      PRINTER (l+REPLICATE(ch1,6)+ch3+REPLICATE(ch1,31)+ch3+REPLICATE(ch1,7)+ch3+;
         REPLICATE(ch1,10)+ch3+REPLICATE(ch1,21))
      PRINTER ("")
      PRINTER (l+"                                 Pagina "+alltrim(STR(pagenr)))
      PRINTER (CHR(12))
      PRINTER (l+"RECNo."+ch2+" PROGRAMMA                     "+ch2+" DISK  "+;
         ch2+" No.DISKS "+ch2+" CATEGORIE           ")
      PRINTER (l+REPLICATE(ch1,6)+ch4+REPLICATE(ch1,31)+ch4+REPLICATE(ch1,7)+ch4+;
         REPLICATE(ch1,10)+ch4+REPLICATE(ch1,21))
      
      pagenr =pagenr +1
      regel =1
   ENDIF 
   f1 =INKEY()
   IF EOF() .or. lastkey()=27
      klaar =.t.
   ENDIF 
ENDDO 
IF lastkey()!=27 .and. regel !=1
   PRINTER (l+REPLICATE(ch1,6)+ch3+REPLICATE(ch1,31)+ch3+REPLICATE(ch1,7)+ch3+;
      REPLICATE(ch1,10)+ch3+REPLICATE(ch1,21))
   DO WHILE regel !=prn_pagelen -5
      regel =regel +1
      PRINTER ("")
   ENDDO 
   PRINTER ("")
   PRINTER (l+"                                 Pagina "+alltrim(STR(pagenr)))
   PRINTER (CHR(12))
ENDIF 
SELECT 1
SET FILTER TO 
RETURN 






*Formatted by: dANALYST Gold (Clipper 5.x) V5.0 on 2/16/92 at 1:35 PM.

