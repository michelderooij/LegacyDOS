*  FILE NAME: p_color.PRG
*  BY: Michel de Rooy                          
*  NOTICE: (c)1990,1991,1992                       
*  DATE: 1/20/92
*  DESC:
*  CALLED BY:
*  DATA FILES:
PRIVATE o,cc, kleur[15],oudecol[9]
PUBLIC tmpcol[13],chrmap[17],colmap[17]
o=setcolor(COLOR [2])
makemaps()
acopy(COLOR,oudecol,1,9,1)
keybar (24,10,"~"+CHR(17)+"ÄÙ~ Opslaan ~F2~ Kleur ~F3~ Mono "+;
   "~F5~/~F6~ Voorgrond ~F7~/~F8~ Achtergrond")
setcolor(COLOR [3])
@   5,03 CLEAR TO 19,34
@   5,03 TO 19,34
kleur[13]="Achtergrond                "
kleur[01]="Menu- & Statusbalk         "
kleur[02]="Menu- & Statusbalk Selectie"
kleur[04]="Algemeen                   "
kleur[05]="Algemeen Selectie & Invoer "
kleur[06]="Meldingen                  "
kleur[07]="Mutaties - Huidige veld    "
kleur[08]="Mutaties - Overige velden  "
kleur[09]="Tabel                      "
kleur[10]="Tabel Selectie             "
kleur[11]="Voortgangsmeters           "
kleur[12]="Schermrand (EGA/VGA)       "
kleur[ 3]="Toetsen statusbalk         "
show_chr()
col2tmp()
doallcol()
KEYBOARD CHR(4)
achoice (6,5,6+2+15,32,kleur,.T.,"udf_achoice",1,0)
IF lastkey() != 27
   tmp2col()
   store_cfg()
   overscan(attr(COLOR [8]))
ELSE
   acopy(oudecol,COLOR,1,9,1)
ENDIF 
setcolor(o)
RELEASE tmpcol
RELEASE chrmap
RELEASE colmap
RETURN 

PROCEDURE col2tmp
tmpcol[13]=colpair(COLOR [1],1)
tmpcol[ 1]=colpair(COLOR [2],1)
tmpcol[ 2]=colpair(COLOR [2],2)
tmpcol[ 4]=colpair(COLOR [3],1)
tmpcol[ 5]=colpair(COLOR [3],2)
tmpcol[ 6]=colpair(COLOR [4],1)
tmpcol[ 7]=colpair(COLOR [5],2)
tmpcol[ 8]=colpair(COLOR [5],5)
tmpcol[ 9]=colpair(COLOR [6],1)
tmpcol[10]=colpair(COLOR [6],2)
tmpcol[11]=colpair(COLOR [7],1)
tmpcol[12]=colpair(COLOR [8],1)
tmpcol[ 3]=colpair(COLOR [9],1)
RETURN 

PROCEDURE tmp2col
COLOR [ 1]=tmpcol[13]
COLOR [ 2]=tmpcol[ 1]+","+tmpcol[ 2]
COLOR [ 3]=tmpcol[ 4]+","+tmpcol[ 5]
COLOR [ 4]=tmpcol[ 6]
COLOR [ 5]=","+tmpcol[ 7]+",,,"+tmpcol[ 8]
COLOR [ 6]=tmpcol[ 9]+","+tmpcol[10]
COLOR [ 7]=tmpcol[11]
COLOR [ 8]=tmpcol[12]
COLOR [ 9]=tmpcol[ 3]
RETURN 

FUNCTION colpair
* c = colpair (s,x)
* Geeft terug kleuren-set nr.x uit de string s, uitgaande
* van attr() en "x/x,y/y..."
PARAMETERS str,num
PRIVATE n1
str=str+",,,,,,,,,,"
DO WHILE num > 1
   n1 = AT(",",str)
   str = SUBSTR(str,n1+1)
   num=num-1
ENDDO 
n1=AT(",",str)
RETURN LEFT(str,n1-1)

FUNCTION udf_achoice
PARAMETERS mode,c,r
PRIVATE KEY 
key = lastkey()
IF mode = 3
   DO CASE 
   CASE KEY = 13
      RETURN 1
   CASE KEY = 27
      RETURN 0
   CASE KEY = -1
      getcolcol()
      col2tmp()
      doallcol()
   CASE KEY = -2
      getbwcol()
      col2tmp()
      doallcol()
   CASE KEY = -4
      changecol(c,1,0)
      show_col(c)
   CASE KEY = -5
      changecol(c,-1,0)
      show_col(c)
   CASE KEY = -6
      changecol(c,0,1)
      show_col(c)
   CASE KEY = -7
      changecol(c,0,-1)
      show_col(c)
   ENDCASE 
ENDIF 
RETURN 2

PROCEDURE changecol
PARAMETERS colno, chngf, chngb
PRIVATE fg,bg,s
IF colno=12
   chngb = 0
ENDIF
s = attr(tmpcol[c])
fg = s % 16
bg = INT(s/16)
fg = (fg + chngf+16) % IIF(colno=12,8,16)
bg = (bg + chngb+8) % 8
tmpcol[c]=chcol(INT(fg+bg*16))
RETURN 

FUNCTION colpos
PARAMETERS x
x = LEFT(alltrim(UPPER(x))+"   ",3)
RETURN (ascan(colname,x)-1)

FUNCTION poscol
PARAMETERS x
RETURN (colname[(INT(x)%16)+1])

FUNCTION chcol
PARAMETERS x
PRIVATE b,f
b = INT(x/16)
f = x % 16
RETURN (poscol(f)+"/"+poscol(b))

FUNCTION attr
PARAMETERS colstr
i =AT("/",colstr)
IF (i > 1)
   f =LEFT(colstr,i-1)
   b =SUBSTR(colstr,i+1,3)
ELSE 
   f = "W"
   b = "N"
ENDIF 
RETURN INT(colpos(b)*16+colpos(f))

PROCEDURE makemaps
chrmap[ 1]="ÕÍÍÍÍÍÍÍÍµ Voorbeeld ÆÍÍÍÍÍÍÍÍÍ¸"
chrmap[ 2]="³ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ³"
chrmap[ 3]="³utatie   Afdruk   Opties   DOS³"
chrmap[ 4]="³°°°°°°°°ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿°°°°°°³"
chrmap[ 5]="³°°°ÛÛÛÛÛ³ ÚÄÄÄÄÄÄ´ Algemeen ÃÄ³"
chrmap[ 6]="³°°ÛÛÛÛÝ ÚÄÄÄ´ Edit ÃÄÄ¿       ³"
chrmap[ 7]="³°ÛÚÄ´ Melding ÃÄ¿     ³DISKS A³"
chrmap[ 8]="³ÛÛ³ Eerste hulp ³C Ú´ Tabel Ã¿³"
chrmap[ 9]="³ÛÛÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙÄÂ³   CAT   ³³"
chrmap[10]="³ÛÝ ÛÛÛÝ°³ 10  ³ 2 ³³ÄÄÄÄÄÄÄÄÄ³³"
chrmap[11]="³Ý °ÛÛÛÝ°³  5  ³ 1 ³³Games    ³³"
chrmap[12]="³ °°ÛÛÛÝ°³  7Ú´ Meter Ã¿lities³³"
chrmap[13]="³°°ÛÛÛÛÛÝÀÄÄÄ³²²²²°°°°°³ÄÄÄÄÄÄÙ³"
chrmap[14]="³°°°     ° ÀÄÀÄÄÄÄÄÄÄÄÄÙÄÄÄÄÄÄÄ³"
chrmap[15]="³°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°³"
chrmap[16]="³F1 Help                       ³"
chrmap[17]="ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ"

colmap[ 1]="dddddddddddddddddddddddddddddddd "
colmap[ 2]="dccccccccccccccccccccccccccccccd "
colmap[ 3]="d111111112222222221111111111111d "
colmap[ 4]="ddddddddd1111111111111111ddddddd "
colmap[ 5]="ddddddddd1144444444444444444444d "
colmap[ 6]="ddddddddd4444444444444444444444d "
colmap[ 7]="ddd6666666666666664444445555544d "
colmap[ 8]="ddd6666666666666664499999999999d "
colmap[ 9]="ddd6666666666666664499999999999d "
colmap[10]="ddddddddd4477444484499999999999d "
colmap[11]="ddddddddd448844448449aaaaaaaaa9d "
colmap[12]="ddddddddd4488444444444449999999d "
colmap[13]="ddddddddd44444bbbbbbbbb49999999d "
colmap[14]="ddddddddddd44444444444444444444d "
colmap[15]="dddddddddddddddddddddddddddddddd "
colmap[16]="d331111111111111111111111111111d "
colmap[17]="dddddddddddddddddddddddddddddddd "
RETURN 

PROCEDURE show_chr
FOR i = 1 TO 17
   @ 3+i,40 SAY chrmap[i]
NEXT 
RETURN 

PROCEDURE doallcol
FOR z = 1 TO 13
   show_col(z)
NEXT z
RETURN 

PROCEDURE show_col
PARAMETERS charno
PRIVATE c,w,x,l,o,s,d
c = SUBSTR("123456789abcdef0",charno,1)
o=setcolor(tmpcol[charno])
FOR i = 1 TO 17
   d = colmap[i]
   w = AT(c,d)
   x = 0
   DO WHILE (w > 0)
      s = w
      DO WHILE (SUBSTR(d,w,1)=c)
         w = w + 1
      ENDDO 
      @ 3+i,40+x+s-1 SAY SUBSTR(chrmap[i],x+s,w-s)
      x = x + w - 1
      d = SUBSTR(d,w)
      w = AT(c,d)
   ENDDO 
NEXT 
setcolor(o)
RETURN 


*Formatted by: dANALYST Gold (Clipper 5.x) V5.0 on 2/16/92 at 1:37 PM.

