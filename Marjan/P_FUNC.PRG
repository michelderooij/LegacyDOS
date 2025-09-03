*  FILE NAME: p_func.PRG
*  BY:
*  NOTICE:
*  DATE: 1/15/92
*  DESC:
*  CALLED BY:
*  DATA FILES:

#include "error.ch"

FUNCTION sure
PRIVATE old_col,ans
SET KEY 28 TO 
CLEAR TYPEAHEAD 
old_col =setcolor(COLOR [3])
SAVE SCREEN 
@11,29 CLEAR TO 13,49
@11,29 TO 13,49 double
@12,31 SAY "Zeker weten J/N  "
SET CONFIRM OFF 
SET cursor ON 
ans ="N"
@12,47 GET ans PICTURE 'A'valid (ans$'JjNn')
READ 
SET CONFIRM ON 
ans =UPPER(ans)
RESTORE SCREEN 
setcolor(old_col)
SET KEY 28 TO p_help
RETURN (IIF(ans ="J",.t.,.f.))

FUNCTION kgv
PARAMETERS a,b
PRIVATE c,d,r
r =a %b
d =b
DO WHILE r > 0
   c =d
   d =r
   r =c %d
ENDDO 
RETURN d

PROCEDURE call_index
PRIVATE old_col,keuze[3],keuze3
old_col =setcolor()
SAVE SCREEN TO os2
setcolor (COLOR [6])
@7,31 TO 17,45 double
@8,32 CLEAR TO 16,44
@9,33 SAY "Kies index:"
@11,33 PROMPT "   GEEN    "
@12,33 PROMPT " PROGRAMMA "
@13,33 PROMPT "  DISK-ID  "
@14,33 PROMPT " CATEGORIE "
MENU TO keuze3
IF keuze3 <> 0
   SELECT 1
   SET ORDER TO (keuze3-1)
ENDIF 
setcolor (old_col)
RESTORE SCREEN FROM os2
show_order()
KEYBOARD CHR(0)
keuze3 =INKEY()
RETURN 

PROCEDURE reset_index
PARAMETERS num
SELECT 1
SET ORDER TO num
RETURN 

PROCEDURE PRINTER
PARAMETERS tekst
?tekst
RETURN 

PROCEDURE rest_logo
PRIVATE i
t = 1 - t
setcolor(COLOR [1])
IF t =0
   FOR i =1 TO 23
      scroll (1,0,23,79,1)
      IF (i > 4) .and. (i < 22)
         @23,0 SAY LOGOUT [i-4]
      ELSE 
         @23,0 SAY REPLICATE("°",80)
      ENDIF 
   NEXT i
ELSE 
   FOR i =1 TO 23
      scroll (1,0,23,79,-1)
      IF (i > 2) .and. (i < 20)
         @1,0 SAY LOGOUT [18-(i-2)]
      ELSE 
         @1,0 SAY REPLICATE("°",80)
      ENDIF 
   NEXT i
ENDIF 
RETURN 

FUNCTION prn_instel
ss =""
s =alltrim(prn_start)
DO WHILE LEN(s) > 1
   IF AT(LEFT(s,1),'0123456789ABCDEF')=0
      s =SUBSTR(s,2)
   ELSE 
      c =LEFT(s,2)
      _lo =AT(RIGHT(c,1),'0123456789ABCDEF')
      IF _lo > 0
         _lo =_lo-1
      ENDIF 
      _hi =AT(LEFT(c,1),'0123456789ABCDEF')
      IF _hi > 0
         _hi =_hi-1
      ENDIF 
      ss =ss +CHR(_lo+_hi*16)
      s =SUBSTR(s,3)
   ENDIF 
ENDDO 
PRINTER (ss)
RETURN (0)

FUNCTION Num2Eng
PRIVATE s,ts,i,j,k
PARAMETERS n
k =n
ts ="pnæm kMGT"
s =1
FOR i =1 TO 9
   j = n / (10^((i-5)*3))
   IF (j >= 1.0)
      s =i
      k =j
   ENDIF 
NEXT i
RETURN LTRIM((STR(k,5,1)+" "+alltrim(SUBSTR(ts,s,1))))



PROCEDURE keybar
PARAMETERS y,x,str,i,j,o,c
o =setcolor()
c =0
i =AT("~",str)
DO WHILE i > 0
   setcolor (o)
   @y,x+c SAY LEFT(str,i-1)
   setcolor (COLOR [9])
   c =c +i -1
   str =SUBSTR(str,i+1)
   j =AT("~",str)
   IF j > 0
      @y,x+c SAY LEFT(str,j-1)
      str =SUBSTR(str,j+1)
      c =c +j -1
      i =AT("~",str)
   ELSE 
      i =0
   ENDIF 
ENDDO 
setcolor(o)
@y,x+c SAY str
RETURN 

PROCEDURE store_cfg
ERASE marjan.cfg
prn_col1 = COLOR [1]
prn_col2 = COLOR [2]
prn_col3 = COLOR [3]
prn_col4 = COLOR [4]
prn_col5 = COLOR [5]
prn_col6 = COLOR [6]
prn_col7 = COLOR [7]
prn_col8 = COLOR [8]
prn_col9 = COLOR [9]
SAVE TO marjan.cfg ALL LIKE prn_*
RETURN 

PROCEDURE retrieve_cfg
IF FILE("MARJAN.CFG")
   RESTORE FROM marjan.cfg ADDITIVE 
   prn2col()
ELSE 
   prn_ibmgraf ="J"
   prn_pagelen =60
   prn_leftmrg =0
   prn_merk ="J"
   prn_norm ="J"
   prn_start =SPACE(20)
   prn_tofile ="N"
   prn_filename =SPACE(20)
   IF ISCOLOR()
      getcolcol()
   ELSE 
      getbwcol()
   ENDIF 
   store_cfg()
ENDIF 
RETURN 

PROCEDURE prn2col
COLOR [1] = prn_col1
COLOR [2] = prn_col2
COLOR [3] = prn_col3
COLOR [4] = prn_col4
COLOR [5] = prn_col5
COLOR [6] = prn_col6
COLOR [7] = prn_col7
COLOR [8] = prn_col8
COLOR [9] = prn_col9
RETURN 

PROCEDURE getcolcol
COLOR [1]="n+/n"
COLOR [2]="n/bg ,w+ /b"
COLOR [3]="n/bg ,w+ /b"
COLOR [4]="w/r"
COLOR [5]=",w+/b,,,w/n"
COLOR [6]="n/w,w+/b"
COLOR [7]="r/n"
COLOR [8]="n+/n"
COLOR [9]="r/bg"
RETURN 

PROCEDURE getbwcol
COLOR [1]="w/n"
COLOR [2]="n/w,w+/n"
COLOR [3]="n/w,w+/n"
COLOR [4]="w+/n"
COLOR [5]=",w+/n,,,w/n"
COLOR [6]="n/w,w+/n"
COLOR [7]="n/w"
COLOR [8]="n/n"
COLOR [9]="W+/w"
RETURN 

PROCEDURE show_order
o=setcolor(COLOR [2])
@24,68 SAY "³ "+SUBSTR("Record    Programma Diskette  Categorie ",indexord()*10+1,10)
setcolor(o)
RETURN 

PROCEDURE init_kleuren
colname[ 1] = "N  "
colname[ 2] = "B  "
colname[ 3] = "G  "
colname[ 4] = "BG "
colname[ 5] = "R  "
colname[ 6] = "RB "
colname[ 7] = "GR "
colname[ 8] = "W  "
colname[ 9] = "N+ "
colname[10] = "B+ "
colname[11] = "G+ "
colname[12] = "BG+"
colname[13] = "R+ "
colname[14] = "RB+"
colname[15] = "GR+"
colname[16] = "W+ "
RETURN 

PROCEDURE nice_clear
cls
RETURN

FUNCTION cputype
PRIVATE t,n
t = cpu_type()
IF t > 5
   t = 0
ELSE
   t = t + 1
ENDIF
n=SUBSTR("Onbekend    8086/8088   80186/80188 "+;
   "80286       80386       80486       ",t*12+1,12)
RETURN RTRIM(n)

procedure errmsg (description, yn, category)
errorsys(category+" : "+description)
return

//function blisernum // Blinker will overrule when linking ...
//return ("R 999999 3.50a<Ongeregistreerd>")

