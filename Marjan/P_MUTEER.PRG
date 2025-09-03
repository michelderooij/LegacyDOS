*  FILE NAME: p_muteer.PRG
*  BY: 
*  NOTICE: 
*  DATE: 1/15/92
*  DESC:
*  CALLED BY:
*  DATA FILES:

PRIVATE veld[7],HEADING [7],dummy,old_col
old_col=setcolor()
dummy =""
HEADING [1]="PROGRAMMA"
HEADING [2]="DISKID"
HEADING [3]="DISKS"
HEADING [4]=" ARC."
HEADING [5]="CAT"
HEADING [6]="MERK"
HEADING [7]="WIS"
veld[1]="name"
veld[2]="disknr"
veld[3]="disks"
veld[4]="arcnr"
veld[5]="catnr"
veld[6]="merkit()"
veld[7]="delit()"
setcolor (COLOR [3])
@2,1 TO 18,78
@20,10 CLEAR TO 22,69
@20,10 TO 22,69
SELECT 1
SET ORDER TO 1
GO TOP 
setcolor (COLOR [2])

keybar (24,10,"~F2~ Index          ")
keybar (24,30,"~F4~ Zoeken ~Ins~ Nieuw ~Del~ Wis ~Spc~ Merk ")
setcolor (COLOR [3])
KEYBOARD CHR(31)
SET CONFIRM OFF 
IF lastrec()=0
   KEYBOARD CHR(22)
ENDIF 
DBEDIT (3,2,17,77,veld,"udf_muteer",dummy,HEADING )
SET CONFIRM ON 
setcolor(old_col)
rest_logo()
RETURN 

FUNCTION udf_muteer
PARAMETERS mode,nr
PRIVATE KEY ,old_rec,old_row,oc
key = lastkey()
old_row = ROW()
show_info()
show_order()
@old_row,0 SAY ""
DO CASE 
CASE KEY =27
   RETURN 0
CASE KEY =22 
   NEW_REC()
   SELECT 1
   IF lastrec()=0
      RETURN 0
   ENDIF 
   RETURN 2
CASE KEY =7 
   IF DELETED()
      RECALL 
   ELSE 
      DELETE 
   ENDIF 
CASE KEY =-1 
   call_index()
   RETURN 2
CASE KEY =-3 
   IF (nr=2)
      DO p_zoekd 
   ELSE 
      DO p_zoekf 
   ENDIF 
   RETURN 2
CASE KEY =32
   REPLACE programs->merk WITH .not. programs->merk
   COMMIT 
CASE KEY =13 .or. mode =4
   IF mode =4 .and. KEY >0 .and. KEY <>13
      SELECT 1
      tmp =indexord()
      SET ORDER TO 1
      SEEK UPPER(CHR(KEY ))
      IF RECNO()=lastrec()+1
         GO TOP 
      ENDIF 
      reset_index (tmp)
      RETURN 2
   ELSE 
      edit_rec(nr,"")
   ENDIF 
   SET cursor OFF 
   RETURN 2
ENDCASE 
IF nr > 5
   KEYBOARD (CHR(29)+REPLICATE(CHR(4),5-1))
ENDIF
IF mode =1 .or. mode =2
   tone (440,0)
   CLEAR TYPEAHEAD 
ENDIF 

SET cursor OFF 
RETURN 1


PROCEDURE edit_rec
PARAMETERS veld_nr,k
edit_item (ROW(),programs->name,programs->disknr,programs->disks,;
   programs->arcnr,programs->catnr,.f.,veld_nr,k)
RETURN 

PROCEDURE new_rec
SELECT 1
IF lastrec()>13
   scroll (5,2,17,77,1)
ENDIF 
@17,34 SAY "³"
@17,43 SAY "³"
@17,51 SAY "³"
@17,59 SAY "³"
@17,65 SAY "³"
@17,65+7 SAY "³"
edit_item (17,SPACE(30),SPACE(5),1,0,0,.t.,1,"")
RETURN 

PROCEDURE edit_item
PARAMETERS ed_row,m_name,m_disknr,m_disks,m_arcnr,m_catnr,new_rec,start,k
PRIVATE y,old_col,ds,tmp,oud_disknr
old_col =setcolor()
setcolor(COLOR [2])
keybar (24,20,"~F3~ Tabel")
setcolor(COLOR [5])
new_disk =-1
oud_disknr =m_disknr
@ed_row,3 GET m_name ;
   valid !EMPTY(m_name)
@ed_row,36 GET m_disknr PICTURE 'XXXXX';
   valid disk_exists(m_disknr)
@ed_row,48 GET m_disks PICTURE '99';
   valid (m_disks >=0)
@ed_row,56 GET m_arcnr PICTURE '99';
   valid arc_exists(m_arcnr)
@ed_row,62 GET m_catnr PICTURE '99';
   valid cat_exists(m_catnr)
SET cursor ON 
ds =""
IF k =CHR(13)
   k =""
ENDIF 
IF start >1
   FOR y =2 TO start
      ds =ds +CHR(24)
   NEXT y
ENDIF 
IF !EMPTY(ds+k)
   KEYBOARD ds+k
ENDIF 
SET KEY -2 TO call_tabel
READ 
SET KEY -2 TO
setcolor (COLOR [3])
@24,20 SAY "        "
SELECT 1
IF lastkey()<>27 .and. UPDATED()
   y =indexord()
   IF new_rec
      APPEND BLANK 
      REPLACE programs->merk WITH .f.
      ds =RECNO()
   ELSE 
      ds =RECNO()
      
      IF m_disks =0
         m_disks =1
      ENDIF 
      
      
      SET ORDER TO 2
      GO TOP 
      IF oud_disknr !=m_disknr
         SEEK oud_disknr
         
         IF programs->disks =0
            SKIP 1
            IF programs->disknr =oud_disknr
               SKIP 1
               IF programs->disknr !=oud_disknr
                  SKIP -1
                  IF RECNO()=ds
                     SKIP -1
                  ENDIF 
                  REPLACE programs->disks WITH 1
               ENDIF 
            ENDIF 
         ENDIF 
      ENDIF 
   ENDIF 
   
   
   GO ds
   SET ORDER TO 2
   SEEK m_disknr
   IF FOUND()
      IF ds =RECNO()
         SKIP 1
         IF m_disknr =programs->disknr
            IF m_disks >1
               p_help ("DOUBLE_PRG",0,"")
            ENDIF 
            IF programs->disks =0
               m_disks =0
            ELSE 
               m_disks =0
               REPLACE programs->disks WITH 0
            ENDIF 
         ENDIF 
      ELSE 
         IF m_disks >1
            p_help ("DOUBLE_PRG",0,"")
         ENDIF 
         IF programs->disks =0
            m_disks =0
         ELSE 
            m_disks =0
            REPLACE programs->disks WITH 0
         ENDIF 
      ENDIF 
   ENDIF 
   
   GO ds
   
   REPLACE programs->name WITH m_name
   REPLACE programs->disknr WITH m_disknr
   REPLACE programs->disks WITH m_disks
   REPLACE programs->arcnr WITH m_arcnr
   REPLACE programs->catnr WITH m_catnr
   COMMIT 
   IF new_disk >-1
      SELECT 2
      APPEND BLANK 
      REPLACE disknrs->disknr WITH m_disknr
      REPLACE disknrs->typenr WITH new_disk
   ENDIF 
   SELECT 1
   reset_index (y)
ENDIF 
SELECT 1
KEYBOARD CHR(0)
ds =INKEY()
setcolor(old_col)
RETURN 

PROCEDURE call_tabel
PARAMETERS call_proc,call_line,call_invar
PRIVATE old_col,old_s
SET KEY -2 TO
old_col =setcolor(COLOR [6])
SAVE SCREEN TO old_s
DO CASE 
CASE AT(call_invar,"M_ARCNR")!=0
   lookup_arc()
CASE AT(call_invar,"M_CATNR")!=0
   lookup_cat()
ENDCASE 
RESTORE SCREEN FROM old_s
SELECT 1
setcolor(old_col)
SET KEY -2 TO call_tabel
RETURN 

PROCEDURE lookup_arc
PRIVATE dummy,HEADING [1],veld[1]
dummy =""
HEADING [1]="Archief"
veld[1]="arcnrs->arcname"
tmp =programs->arcnr
SELECT 4
SEEK tmp
IF !FOUND()
   GO TOP 
ENDIF 
@2,52 TO 22,77 double
dbedit(3,53,21,76,veld,dummy,dummy,HEADING )
IF lastkey()!=27
   KEYBOARD CHR(25)+STR(arcnrs->arcnr,2)+;
      IIF(arcnrs->arcnr <10,CHR(13),"")
ENDIF 
RETURN 

PROCEDURE lookup_cat
PRIVATE dummy,HEADING [1],veld[1]
dummy =""
HEADING [1]="Categorie"
veld[1]="category->category"
tmp =programs->catnr
SELECT 6
SEEK tmp
IF !FOUND()
   GO TOP 
ENDIF 
@2,52 TO 22,77 double
dbedit(3,53,21,76,veld,dummy,dummy,HEADING )
IF lastkey()!=27
   KEYBOARD CHR(25)+STR(category->catnr,2)+;
      IIF(category->catnr <10,CHR(13),"")
ENDIF 
RETURN 



FUNCTION disk_exists
PARAMETERS disk
IF EMPTY(disk)
   RETURN .f.
ENDIF 
PRIVATE old_sch,old_col,tmp
SELECT 2
SEEK disk
IF !FOUND()
   SET KEY -2 TO
   tone (110,1)
   SAVE SCREEN TO old_sch
   old_col =setcolor()
   setcolor (COLOR [6])
   @6,27 TO 20,51
   @7,28 CLEAR TO 19,50
   @8,29 SAY "Nieuwe disk : "+disk+""
   @9,29 SAY "Kies het type disk:"
   SELECT 3
   tmp =lastrec()
   PRIVATE m_type[tmp]
   GO TOP 
   tmp =1
   DO WHILE !EOF()
      m_type[tmp]="   "+typenrs->media+" - "+typenrs->capacity+"    "
      SKIP 1
      tmp =tmp+1
   ENDDO 
   tmp =achoice(11,29,19,49,m_type)
   RESTORE SCREEN FROM old_sch
   setcolor (old_col)
   SET KEY -2 TO call_tabel
   IF lastkey()=27
      new_disk =-1
      RETURN .f.
   ELSE 
      new_disk =tmp
   ENDIF 
ENDIF 
RETURN .t.

FUNCTION cat_exists
PARAMETERS cat
SELECT 6
SEEK cat
IF !FOUND()
   tone (110,1)
   call_tabel("EDIT_ITEM","","M_CATNR")
   RETURN .f.
ENDIF 
RETURN .t.

FUNCTION arc_exists
PARAMETERS arc
SELECT 4
SEEK arc
IF !FOUND()
   tone (110,1)
   call_tabel("EDIT_ITEM","","M_ARCNR")
   RETURN .f.
ENDIF 
RETURN .t.

FUNCTION merkit
PARAMETERS merk
RETURN (IIF(merk,"û"," "))

FUNCTION delit
RETURN (IIF(DELETED(),"û"," "))

PROCEDURE show_info
PRIVATE tmp,tmp2,tmp3
tmp =programs->disknr
tmp2 =programs->arcnr
tmp3 =programs->catnr
SELECT 2
SEEK tmp
tmp =disknrs->typenr
SELECT 3 
SEEK tmp

SELECT 4 
SEEK tmp2
SELECT 6 
SEEK tmp3

@21,13 SAY typenrs->media
@21,21 SAY typenrs->capacity
@21,29 SAY arcnrs->arcname
@21,49 SAY category->category
SELECT 1
RETURN 





*Formatted by: dANALYST Gold (Clipper 5.x) V5.0 on 2/16/92 at 1:34 PM.

