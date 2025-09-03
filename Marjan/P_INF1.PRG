*  FILE NAME: p_inf1.PRG
*  BY: 
*  NOTICE: 
*  DATE: 1/15/92
*  DESC:
*  CALLED BY:
*  DATA FILES:
PRIVATE keuze2,dagen[7],vandaag,info[10],klaar,tmp,info_str,ad,;
   keuze3,old_c,veld[6],HEADING [6]

SELECT 4
tmp =lastrec()
PRIVATE m_arcnr[tmp]
afill (m_arcnr,0)
a_a =tmp

SELECT 3
tmp =lastrec()
PRIVATE m_typenr[tmp]
afill (m_typenr,0)
a_t =tmp

SELECT 6
tmp =lastrec()
PRIVATE m_catnr[tmp]
afill (m_catnr,0)
a_c =tmp

old_col=setcolor()
SET KEY 28 TO 
setcolor (COLOR [3])
vandaag =DATE()
dagen[1]="Zon"
dagen[2]="Maan"
dagen[3]="Dins"
dagen[4]="Woens"
dagen[5]="Donder"
dagen[6]="Vrij"
dagen[7]="Zater"
@2,3 TO 11,76
@3,4 CLEAR TO 10,75
info_str =uid+" - info van "+dagen[DOW(vandaag)]+"dag, "+;
   DTOC(vandaag)+" om "+TIME()
@4,5 SAY info_str
@6,5 SAY "Analyseren databases "
setcolor(COLOR [7])
@6,26 SAY REPLICATE("°",40)

klaar =.f.
BEGIN sequence
   SELECT 1
   info[1]=lastrec()
   IF info[1]=0
      p_help ("EMPTY_BASE",0,"")
      rest_logo()
      setcolor (old_col)
      BREAK 
   ENDIF 
   SELECT 2
   REPLACE ALL disknrs->vlag WITH .F. && zet alle vlaggen op false,ivm check
   SELECT 1
   SET ORDER TO 0
   GO TOP 
   info[3]=0
   info[2]=0
   info[6]=0
   SET cursor ON 
   DO WHILE !EOF()
      IF programs->merk = .t.
         info[6]=info[6]+1
      ENDIF 
      IF DELETED()
         info[2]=info[2]+1
      ENDIF 
      tmp =programs->arcnr
      m_arcnr[1+tmp]=m_arcnr[1+tmp]+1
      tmp =programs->catnr
      m_catnr[1+tmp]=m_catnr[1+tmp]+1
      IF (programs->disks) > 0
         ad =programs->disks
         info[3]=info[3]+ad
         tmp =programs->disknr
         SELECT 2
         SEEK tmp
         tmp =disknrs->typenr
         m_typenr[tmp]=m_typenr[tmp]+ad
      ELSE 
         tmp =programs->disknr
         SELECT 2
         SEEK tmp
         IF disknrs->vlag = .f.
            REPLACE disknrs->vlag WITH .t.
            info[3]=info[3]+1
            tmp =disknrs->typenr
            m_typenr[tmp]=m_typenr[tmp]+1
         ENDIF 
      ENDIF 
      SELECT 1
      SKIP 1
      tmp =INT(RECNO()/lastrec()*39)
      IF tmp >39
         tmp =39
      ENDIF 
      @6,26+tmp SAY "²"
      IF INKEY()=27
         BREAK 
      ENDIF 
   ENDDO 
   @6,26 SAY REPLICATE("²",40)
   SET cursor OFF 
   tmp =kgv (info[1],info[3])
   info[4]=info[1]/tmp
   info[5]=info[3]/tmp
   info[7]=ROUND(info[5]/info[4],2)
   SET ORDER TO 1
   klaar =.t.
END 
IF !klaar
   RETURN 
ELSE 
   setcolor(COLOR [3])
   
   @6,5 CLEAR TO 7,74
   info_str=;
      "De lijst bestaat uit "+LTRIM(STR(info[1],7,0))+" programma"+;
      (IIF(info[1]=1,"","'s"))+", waarvan er "+;
      LTRIM(STR(info[2],7,0))+" gewist "+(IIF(info[2]=1,"mag","mogen"))+;
      " worden, "+"en er "+LTRIM(STR(info[6],7,0))+" gemerkt "+;
      (IIF(info[6]=1,"is","zijn"))+". De programmatuur bezet in totaal "+;
      LTRIM(STR(info[3],7,0))+" disk"+(IIF(info[3]=1,"","s"))+"."+;
      IIF(kgv(info[1],info[3])=1,""," Dit in combinatie met het "+;
      "aantal programma's geeft een verhouding van "+;
      LTRIM(STR(info[4],7,0))+" programma"+(IIF(info[4]=1,"","'s"))+" op "+;
      LTRIM(STR(info[5],7,0))+" disk"+(IIF(info[5]=1,"","s"))+".")+;
      " Een programma gebruikt gemiddeld "+LTRIM(STR(info[7]))+" disk"+;
      IIF(info[7]=1,"","s")+"."
   KEYBOARD CHR(27)
   MEMOEDIT(info_str,6,5,10,74,.F.)
   SELECT 3
   GO TOP 
   tmp =1
   DO WHILE !EOF()
      m_typenr[tmp]=STR(9999999-m_typenr[tmp],7)+typenrs->media+" ³ "+;
         typenrs->capacity+" ³ "+STR(m_typenr[tmp],7)+" ("+;
         STR(m_typenr[tmp]/info[3]*100,5,1)+"%) "
      SKIP 1
      tmp =tmp +1
   ENDDO 
   asort(m_typenr)
   klaar =1
   FOR tmp =1 TO a_t
      IF VAL(SUBSTR(m_typenr[klaar],1,7))<9999999
         m_typenr[klaar]=SUBSTR(m_typenr[klaar],8)
         klaar =klaar +1
      ELSE 
         adel(m_typenr,klaar)
      ENDIF 
   NEXT t
   a_t =klaar-1
   SELECT 4
   GO TOP 
   tmp =1
   DO WHILE !EOF()
      m_arcnr[tmp]=STR(9999999-m_arcnr[tmp],7)+arcnrs->arcname+" ³ "+;
         STR(m_arcnr[tmp],7)+" ("+;
         STR(m_arcnr[tmp]/info[1]*100,5,1)+"%) "
      SKIP 1
      tmp =tmp +1
   ENDDO 
   asort(m_arcnr)
   klaar =1
   FOR tmp =1 TO a_a
      IF VAL(SUBSTR(m_arcnr[klaar],1,7))<9999999
         m_arcnr[tmp]=SUBSTR(m_arcnr[tmp],8)
         klaar =klaar+1
      ELSE 
         adel (m_arcnr,klaar)
      ENDIF 
   NEXT t
   a_a =klaar-1
   SELECT 6
   GO TOP 
   tmp =1
   DO WHILE !EOF()
      m_catnr[tmp]=STR(9999999-m_catnr[tmp],7)+;
         category->category+" ³ "+STR(m_catnr[tmp],7)+" ("+;
         STR(m_catnr[tmp]/info[3]*100,5,1)+"%) "
      SKIP 1
      tmp =tmp +1
   ENDDO 
   asort(m_catnr)
   klaar =1
   FOR tmp =1 TO a_c
      IF VAL(SUBSTR(m_catnr[klaar],1,7))<9999999
         m_catnr[klaar]=SUBSTR(m_catnr[klaar],8)
         klaar =klaar +1
      ELSE 
         adel(m_catnr,klaar)
      ENDIF 
   NEXT t
   a_c =klaar-1
   
   SET KEY 28 TO p_help
   SELECT 2
   SET RELATION TO typenr INTO typenrs
   SELECT 1
   SET RELATION ADDITIVE TO disknr INTO disknrs,TO arcnr INTO arcnrs,;
      TO catnr INTO category
   mtmp =1
   DO WHILE (mtmp <> 0)
      setcolor (COLOR [6])
      @11,28 CLEAR TO 17,52
      @11,28 TO 17,52 double
      @12,30 SAY " Bekijk info van :  "
      @13,29 TO 13,51
      @14,30 PROMPT "  Diskettesoorten   "
      @15,30 PROMPT " Archivering/Backup "
      @16,30 PROMPT "    Categorie‰n     "
      MENU TO mtmp
      IF mtmp <> 0
         SAVE SCREEN TO mani
         SET KEY -1 TO do_graph
         setcolor (COLOR [3])
         DO CASE 
         CASE mtmp =1
            typetabel()
         CASE mtmp =2
            arctabel()
         CASE mtmp =3
            cattabel()
         ENDCASE 
         RESTORE SCREEN FROM mani
      ENDIF 
   ENDDO 
ENDIF 
SET KEY -1 TO
SELECT 2
SET FILTER TO 
SET RELATION TO 
SELECT 1
SET FILTER TO 
SET RELATION TO 
SET cursor ON 
setcolor (old_col)
RETURN 


PROCEDURE no_rec
p_help("NO_REC",0,"")
RETURN 

PROCEDURE do_graph
PRIVATE o_screen,old_cr,or,oc
old_cr =setcolor()
SAVE SCREEN TO o_screen
SET KEY -1 TO
SET KEY 28 TO 
or =ROW()
oc =COL()

DO p_graph

SET cursor OFF 
RESTORE SCREEN FROM o_screen
setcolor(old_cr)
CLEAR TYPEAHEAD 
SET KEY -1 TO do_graph
SET KEY 28 TO p_help
@or,oc SAY ""
KEYBOARD CHR(0)
o_screen =INKEY()
RETURN 


PROCEDURE cattabel
klaar =.f.
DO WHILE .not. klaar
   CLEAR TYPEAHEAD 
   setcolor(COLOR [2])
   keybar(24,10,"~F2~ Grafiek  ~"+CHR(17)+"ÄÙ~ Tabel")
   setcolor(COLOR [6])
   @5,20 CLEAR TO 20,60
   @5,19 TO 20,61 double
   @6,21 SAY "Categorie               Aantal"
   @7,20 TO 7,60
   @7,19 SAY "Ç"
   @7,61 SAY "¶"
   keuze2 =3 
   SET KEY -1 TO do_graph
   keuze3 =achoice(8,21,19,59,m_catnr)
   SET KEY -1 TO
   IF lastkey()=27
      klaar =.t.
   ENDIF 
   IF lastkey()=13 .and. !klaar
      IF VAL(SUBSTR(m_catnr[keuze3],24))>0
         tmp ="(category->category='"+SUBSTR(m_catnr[keuze3],1,20)+"')"
         SET FILTER TO &tmp
         GO TOP 
         veld[1]="programs->name"
         veld[2]="programs->disknr"
         veld[3]="programs->disks"
         veld[4]="typenrs->media"
         veld[5]="typenrs->capacity"
         veld[6]=""
         HEADING [1]="Programma"
         HEADING [2]="Disk"
         HEADING [3]="Disks"
         HEADING [4]="Media"
         HEADING [5]="Cap."
         old_c =setcolor()
         setcolor(COLOR [3])
         SAVE SCREEN 
         @3,2 TO 22,77 double
         setcolor (COLOR [2])
         keybar(24,10,"~F2~ Index  ~F4~ Zoek    ")
         setcolor (COLOR [3])
         DBEDIT (4,3,21,76,veld,"udf_browse","",HEADING )
         setcolor (old_c)
         RESTORE SCREEN 
      ELSE 
         no_rec()
      ENDIF 
   ENDIF 
ENDDO 
RETURN 

PROCEDURE typetabel
klaar =.f.
DO WHILE .not. klaar
   CLEAR TYPEAHEAD 
   setcolor(COLOR [2])
   keybar(24,10,"~F2~ Grafiek  ~"+CHR(17)+"ÄÙ~ Tabel")
   setcolor(COLOR [6])
   @5,20 CLEAR TO 20,60
   @5,19 TO 20,61 double
   @6,21 SAY "Disksoort       Aantal"
   @7,20 TO 7,60
   @7,19 SAY "Ç"
   @7,61 SAY "¶"
   keuze2 =1 
   SET KEY -1 TO do_graph
   keuze3 =achoice(8,21,19,59,m_typenr)
   SET KEY -1 TO
   IF lastkey()=27
      klaar =.t.
   ENDIF 
   IF lastkey()=13 .and. !klaar
      IF VAL(SUBSTR(m_typenr[keuze3],17))>0
         tmp ="(typenrs->media='"+SUBSTR(m_typenr[keuze3],1,5)+"') .and. ";
            +"(typenrs->capacity='"+SUBSTR(m_typenr[keuze3],9,5)+"')"
         SET FILTER TO &tmp
         GO TOP 
         veld[1]="programs->name"
         veld[2]="programs->disknr"
         veld[3]="programs->disks"
         veld[4]="category->category"
         veld[5]=""
         veld[6]=""
         HEADING [1]="Programma"
         HEADING [2]="Disk"
         HEADING [3]="Disks"
         HEADING [4]="Categorie"
         HEADING [5]=""
         old_c =setcolor()
         setcolor(COLOR [3])
         SAVE SCREEN 
         @3,2 TO 22,77 double
         setcolor (COLOR [2])
         keybar(24,10,"~F2~ Index  ~F4~ Zoek    ")
         setcolor (COLOR [3])
         DBEDIT (4,3,21,76,veld,"udf_browse","",HEADING )
         setcolor (old_c)
         RESTORE SCREEN 
      ELSE 
         no_rec()
      ENDIF 
   ENDIF 
ENDDO 
RETURN 

PROCEDURE arctabel
klaar =.f.
DO WHILE !klaar
   CLEAR TYPEAHEAD 
   setcolor(COLOR [2])
   keybar(24,10,"~F2~ Grafiek  ~"+CHR(17)+"ÄÙ~ Tabel")
   setcolor(COLOR [6])
   @5,20 CLEAR TO 20,60
   @5,19 TO 20,61 double
   @6,21 SAY "Archiver/Backup         Aantal"
   @7,20 TO 7,60
   @7,19 SAY "Ç"
   @7,61 SAY "¶"
   keuze2 =2 
   SET KEY -1 TO do_graph
   keuze3 =achoice(8,21,19,59,m_arcnr)
   SET KEY -1 TO
   IF lastkey()=27
      klaar =.t.
   ENDIF 
   IF lastkey()=13 .and. !klaar
      IF VAL(SUBSTR(m_arcnr[keuze3],24))>0
         tmp ="(arcnrs->arcname='"+SUBSTR(m_arcnr[keuze3],1,20)+"')"
         SET FILTER TO &tmp
         GO TOP 
         veld[1]="programs->name"
         veld[2]="programs->disknr"
         veld[3]="programs->disks"
         veld[4]="category->category"
         veld[5]="typenrs->media"
         veld[6]="typenrs->capacity"
         HEADING [1]="Programma"
         HEADING [2]="Disk"
         HEADING [3]="Disks"
         HEADING [4]="Categorie"
         HEADING [5]="Media"
         HEADING [6]="Cap."
         old_c =setcolor()
         setcolor(COLOR [3])
         SAVE SCREEN 
         @3,2 TO 22,77 double
         setcolor (COLOR [2])
         keybar(24,10,"~F2~ Index  ~F4~ Zoek    ")
         setcolor (COLOR [3])
         DBEDIT (4,3,21,76,veld,"udf_browse","",HEADING )
         setcolor (old_c)
         RESTORE SCREEN 
      ELSE 
         no_rec()
      ENDIF 
   ENDIF 
ENDDO 
RETURN 

FUNCTION udf_browse
PARAMETERS mode,nr
PRIVATE KEY 
key =lastkey()
setcolor(COLOR [3])
DO CASE 
CASE KEY =27
   RETURN 0
CASE KEY =-1 
   call_index()
   setcolor(COLOR [3])
   RETURN 2
CASE KEY =-3 
   IF (nr=2)
      DO p_zoekd 
   ELSE 
      DO p_zoekf 
   ENDIF 
   setcolor(COLOR [3])
   RETURN 2
ENDCASE 

IF mode =1 .or. mode =2
   tone (440,0)
   CLEAR TYPEAHEAD 
ENDIF 

SET cursor OFF 
RETURN 1





*Formatted by: dANALYST Gold (Clipper 5.x) V5.0 on 2/16/92 at 1:35 PM.

