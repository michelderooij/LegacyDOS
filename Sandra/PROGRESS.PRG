*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*³ Module ............. : PROGRESS
*³ Omschrijving ....... : BEVAT ROUTINES VOOR HET AFHANDELEN VAN
*³                        PROGRESSIEMETERS (Class)
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

#include "config.ch"
#include "fileio.ch"

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*³ Functie ............ : prog_init
*³ Syntax ............. : m = prog_init(x1,x2,header,tekst,totaal,tc,hc,mc,y)
*³ Parameters ......... : x1,x2   : Coordinaten
*³                        header  : kopregel window
*³                        tekst   : begeleidende tekst
*³                        totaal  : totaal af te werken
*³                        col     : array[1..3] kleuren
*³                        y       : eventueel y-pos. default = centered
*³ Geeft terug ........ : Handler naar progressiemeter
*³ Werking ............ : Constructor Progressiemeter-object
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

function prog_init (x1,x2,header,tekst,totaal,col,ey)
local y := pdef(ey,maxrow()/2-3)
declare meter[9]
totaal=pdef(totaal,100)
header=pdef(header,"Progress")
w := openwindow(y,x1,y+5,x2,header,col)
* 8 = Eerste call ivm init.100% */
* 9 = 100, ivm. het vermijden van het op dezelfde plaats neerzetten van
*     karakters op het scherm, want een vergelijking kost minder tijd dan
*     scherm I/O
meter = {y,x1,(x2-x1-3),totaal,col[1],col[2],w,1,9999}
prog_tekst(meter,tekst)
return (meter)

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*³ Functie ............ : PROG_FULL
*³ Syntax ............. : PROG_FULL(P)
*³ Parameters ......... : P      : DE PROGRESSIEMETER
*³ Geeft terug ........ : ""
*³ Werking ............ : TOONT EEN VOLLE METER (100%)
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

function prog_full (p)
prog_supdate(p,p[4])
return ""

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*³ Functie ............ : prog_supdate
*³ Syntax ............. : prog_supdate(p,deel)
*³ Parameters ......... : p       : te wijzigen progressiemeter
*³                        deel    : nieuw aantal afwerkingen
*³ Geeft terug ........ : ""
*³ Werking ............ : Werkt progressiemeter bij (Voor str-expr)
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

function prog_supdate (p,deel)
local c := setcolor(p[6])
local perc:=iif(p[8]==1,0,deel/p[4])
local f := int(perc*p[3])
local e := p[3]-f
if p[9] != f .and. p[8] != 2
   @ p[1]+3,p[2]+2 say replicate("Û",f)+replicate(" ",e)
   setcolor(p[5])
   @ p[1]+2,p[2]+p[3]-2 say padl(str(perc*100,3,0),3)+"%"
   setcolor(c)
   p[9] = f
endif
p[8] = 3
return ""

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*³ Functie ............ : prog_nupdate
*³ Syntax ............. : prog_nupdate(p,deel)
*³ Parameters ......... : p       : te wijzigen progressiemeter
*³                        deel    : nieuw aantal afwerkingen
*³ Geeft terug ........ : 0
*³ Werking ............ : Werkt progressiemeter bij (Voor num-expr)
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

function prog_nupdate (p,deel)
prog_supdate(p,deel)
return 0

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*³ Functie ............ : prog_tekst
*³ Syntax ............. : prog_tekst(p,tekst)
*³ Parameters ......... : p         : te wijzigen progressiemeter
*³                        tekst     : nieuwe tekst
*³ Geeft terug ........ : ""
*³ Werking ............ : wijzigt tekst bij meter
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

function prog_tekst(p,tekst)
local c := setcolor(p[5])
tekst=pdef(tekst,"")
@ p[1]+2,p[2]+2 say padr(tekst,p[3]-4)
setcolor(c)
return ""


*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*³ Functie ............ : prog_close
*³ Syntax ............. : prog_close(p)
*³ Parameters ......... : p         : de te sluiten progressiemeter
*³ Geeft terug ........ : ""
*³ Werking ............ : sluit een progressiemeter(window)
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

function prog_close (p)
closewindow(p[7])
return ""

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*³ Functie ............ : purify
*³ Syntax ............. : purify(n)
*³ Parameters ......... : n         : de te wijzigen indexfile
*³ Geeft terug ........ : ""
*³ Werking ............ : haalt de aanroep van prog_update uit een
*³                        indexexpressie van index n, zodat expressie
*³                        ook vanuit bv. dbu geldig is.
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

function purify (n)
local h, b, e, w
e = space(256)
h = fopen(n,FO_READWRITE)
fseek(h,22,FS_SET)
fread(h,@e,256)
e = trim(e)
w = at("+prog_",e)
// indien aanwezig (anders wordt indexexpressie=="" !!!!! no match => w:=0...)
if w > 0
   fseek(h,22,FS_SET)
   fwrite(h,left(e,w-1)+chr(0))
endif
fclose(h)
return ""

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*³ Functie ............ : prog_renew
*³ Syntax ............. : prog_renew(p)
*³ Parameters ......... : p          : De te 'vernieuwen' progressiemeter
*³ Geeft terug ........ : nil
*³ Werking ............ : reset de vlag die aangeeft of meter al gestart
*³                        is. Gebruik voor bv. 1 proces wat uit meerdere bestaat (accumulatief)
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

function prog_renew (p)
p[8] := 2
return nil
