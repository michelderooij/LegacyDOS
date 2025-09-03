*  FILE NAME: p_graph.PRG
*  BY: 
*  NOTICE: 
*  DATE: 1/15/92
*  DESC:
*  CALLED BY:
*  DATA FILES:
PRIVATE i,deel,r,klaar,labels[16],posx,posy,RESTORE ,c,p,ca,min
ca =.t.
IF !ISCOLOR()
   ca =.f.
ENDIF 
p =66
maxitem=15
r =sethires (0)
r =clrscreen()
r =datareset()
r =datapc (80)
posx =24
DO CASE 
CASE keuze2 =1
   posy =1000-p
   min =IIF(a_t>maxitem,maxitem,a_t)
   FOR i =1 TO min
      deel =VAL(SUBSTR(m_typenr[i],26,5))*10
      c =IIF(ca=.t.,i,7)
      saystring (posx,posy,0,0,7,IIF(i=maxitem,"Overigen", ;
         SUBSTR(m_typenr[i],1,5)+" ("+;
         SUBSTR(m_typenr[i],9,5)+")"))
      boxfill (posx-20,posy,16,40,i,c)
      r =datastore (deel,i,IIF(i=1,1,0),c)
      posy =posy -p
   NEXT i
CASE keuze2 =2
   posy =1000-p
   min =IIF(a_a>maxitem,maxitem,a_a)
   FOR i =1 TO min
      deel =VAL(SUBSTR(m_arcnr[i],26,5))*10
      c =IIF(ca=.t.,i,7)
      saystring (posx,posy,0,0,7,IIF(i=maxitem,"Overigen", ;
         SUBSTR(m_arcnr[i],1,20)))
      boxfill (posx-20,posy,16,40,i,c)
      r =datastore (deel,i,IIF(i=1,1,0),c)
      posy =posy -p
   NEXT i
CASE keuze2 =3
   posy =1000-p
   min =IIF(a_c>maxitem,maxitem,a_c)
   FOR i =1 TO min
      deel =VAL(SUBSTR(m_catnr[i],26,5))*10
      c =IIF(ca=.t.,i,7)
      saystring (posx,posy,0,0,7,IIF(i=maxitem,"Overigen", ;
         SUBSTR(m_catnr[i],1,20)))
      boxfill (posx-20,posy,16,40,i,c)
      r =datastore (deel,i,IIF(i=1,1,0),c)
      posy =posy -p
   NEXT i
   
ENDCASE 
piechart (800,500,350)
CLEAR TYPEAHEAD 
INKEY(0)
settext ()
IF ISCOLOR()
   overscan (attr(COLOR [8]))
ENDIF 
RETURN 




*Formatted by: dANALYST Gold (Clipper 5.x) V5.0 on 2/16/92 at 1:37 PM.

