*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*³ Module ............. : ED
*³ Syntax ............. : r := ED(@TEKST,Y1,X1,Y2,X2,EDIT,PR,IMP,HEAD,LL,TC,HC,TS,TR,TC,WR,WC,WRAP,MSG
*³ Parameters ......... : @TEKST     : TE BEKIJKEN/WIJZIGEN TEKST (Call by reference!)
*³                        Y1,X1,Y2,X2: COORDINATEN VENSTER
*³                        EDIT       : .T. INDIEN MAG WIJZIGEN, .F. VOOR KIJKEN
*³                        PR         : MAG DE TEKST WORDEN AFGEDRUKT
*³                        IMP        : MAG ER IETS WORDEN GEIMPORTEERD
*³                        HEAD       : HEADER WINDOW
*³                        LL         : LENGTE REGELS
*³                        TC         : KLEUR TEKST
*³                        HC         : KLEUR HEADER
*³                        TS         : TABGROOTTE
*³                        TR,TC      : RELATIEVE POSITIE IN TEKST
*³                        WR,WC      : POSITIE IN WINDOW
*³                        WRAP       : AUTOMATISCHE WORDWRAP
*³                        MSGON      : MOGEN ER BERICHTEN WORDEN GETOOND
*³ Geeft terug ........ : r = .T. indien tekst op te slaan, .F. indien niet
*³ Omschrijving ....... : ED IS EEN VEREDELDE MEMOEDIT, MET EXTRA OPTIES
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

#include "set.ch"
#include "inkey.ch"
#include "setcurs.ch"
#include "memoedit.ch"
#include "config.ch"

#define F_PRINT  K_F3
#define F_IMPORT K_F4
#define F_ZOEK   K_F5
#define F_ZOEKV  K_F6
#define F_SAVE   K_F8
#define F_STOP   K_ESC
#define P_EMPTY  space(80) /* Leeg patroon voor zoeken */

parameters tekst, y1,x1,y2,x2, edit,print,import,header,linelen,tcol,hcol, ;
           tabsize, tbrow, tbcol, winrow, wincol,wrap,msgon
local editing := .t., key, ans, result := .F., g := getlist

// De volgende var in deze module houden, om ze vervolgens
// globaal te bewerken/op te vragen. Zijn niet globaal, alleen voor called by's

private tx, ty, ml, os, maxline, xdl, ydl, ccx, ccy, ;
        altered, oc, wrap2, temptext, tbrow, tbcol

// Zet zoekpatroon op niks :
patroon := P_EMPTY

// Variabele die aangeeft of we in de tekst hebben lopen wijzigen
altered := .f.

vh=save_video()
getlist := {}
// Default settings (parameters) indien parameter ontbreekt
y1=pdef(y1,0)
x1=pdef(x1,0)
y2=pdef(y2,24)
x2=pdef(x2,79)
edit=pdef(edit,.t.)
import=pdef(import,.f.)
print=pdef(print,.f.)
header=pdef(header,"")
hcol=pdef(hcol,DIALOG_TEXT[3])
linelen=pdef(linelen,80)
wrap=pdef(wrap,.T.)
msgon=pdef(msgon,.t.)
os = SET(_SET_SCOREBOARD,.F.)
oc = SET(_SET_CONFIRM,.F.)

// Teksts' upper-left corner
tx = x1+1
ty = y1+1

// De -5 is voor de lengte van de positie-indicator
xdl = x2-x1-4 - 4
ydl = y2-y1-3 - 5

// Dummy waarden om indicatoren te 'triggeren' :
ccx = x1+2.01
ccy = y1+3.01

openwindow(y1,x1,y2,x2,header,tcol,hcol)
edmsg("")
setcolor(DIALOG_LIST[6])
@ y1+1,x2 say ""
@ y2-1,x2 say ""
@ y2,x1+1 say ""
@ y2,x2-1 say "þ"
@ y2,x1+2,y2,x2-2 box IND_H1
@ y1+2,x2,y2-2,x2 box IND_V1
setcolor(DIALOG_TEXT[1])
keyline()

// Tijdelijke kopie maken, in geval van zoekacties e.d. waarbij we ook uit de
// memo terugkeren, maar er weer in  moeten met onze 'laatste' versie.
// Als we na deze actie op ESC drukken moeten we alsnog een
// ongewijzigde hebben.

temptext = tekst
maxline = mlcount(temptext,linelen,tabsize,wrap)
while editing
  // Edit tekst
  wrap2 := wrap
  setcolor(tcol)
  temptext = memoedit(temptext,ty,tx,y2-1,x2-1,edit,"udf_ed2000",linelen,tabsize,tbrow,tbcol,winrow,wincol)
  key := lastkey()
  // Controle op Exit-methode Memoedit(), ivm. functies in editor
  do case
  case key == F_STOP
      if !altered
         //Haal ALTIJD originele op!
         temptext = tekst
         editing = .f.
      else
       if edit
         ans = askwindow("Attentie","Tekst is niet opgeslagen.;Opslaan ?",{"^Ja","^Nee","^Verder"},3,DIALOG_TEXT)
         if ans = 3
            // Doe niks, we gaan verder editten
         else
            if ans == 1
               editing = .f.
               result := .T.
            else
               // Haal originele op.
               temptext = tekst
               editing = .f.
            endif
         endif
      endif
   endif
  case key == F_ZOEK
   zoek()
  case key == F_ZOEKV
   zoekv(1)
  case key == F_SAVE
   editing = .f.
   result = .T.
  otherwise

  endcase
end
rest_video(vh)
getlist := g
set(_SET_SCOREBOARD,os)
set(_SET_CONFIRM,oc)
tekst = rtrim(temptext)
return result

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*³ Procedure .......... : KEYLINE
*³ Werking ............ : TOONT ACTIEVE TOETSEN A.D.H.V. ED'S PARAMETERS
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

procedure keyline ()
local str := ""
str += "~F5~ Zoek "
str += "~F6~ ZoekV "
if edit
   str += "~F8~ Save "
endif
str += "~ESC~ Stop"
saykeys(ltrim(str))
return

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*³ Functie ............ : UDF_ED2000
*³ Parameters ......... : EDMODE    : MODUS EDITOR
*³                        EDLINE    : POSITIEREGEL IN TEKST
*³                        EDCOL     : POSITIEKOLOM IN TEKST
*³ Geeft terug ........ : ACTIE-NUMMER (Zie memoedit() in Ref.Guide)
*³ Werking ............ : USER-DEFINED FUNCTION, BEHORENDE BIJ ED ALLEEN
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

function udf_ed2000 (edmode, edline, edcol)
local key := lastkey(), t
tbrow := edline
tbcol := edcol
winrow := row()-ty
wincol := col()-tx
if edmode == ME_INIT
   // EdLine is standaard 1 te hoog (0 ipv 1) dus 1 eraf snoepen ...
   statmsg(edline-1,edcol)
   if wrap2
      wrap2 := .F.
      //return ME_TOGGLEWRAP
   endif
else
   if edmode == ME_IDLE
      if empty(setcursor())
         setcursor(if(readinsert(),SC_INSERT,SC_NORMAL))
      endif
      statmsg(edline-1,edcol)
   else
      if (edmode == ME_UNKEYX)
         altered := .t.
      endif
      do case
      case key == F_ZOEK
         return (K_CTRL_W)
      case key == F_ZOEKV
         return (K_CTRL_W)
      case key == F_SAVE .and. edit
         return (K_CTRL_W)
      case key == F_STOP
         return (K_CTRL_W)
      case key == K_CTRL_V
         setcursor(if(!readinsert(),SC_INSERT,SC_NORMAL))
         // Perform Ins-action (NIET RETURN 0!!!)
         return (key)
      otherwise

      endcase
   endif
endif
return (0)

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*³ Procedure .......... : STATMSG
*³ Syntax ............. : STATMSG (Y,X)
*³ Parameters ......... : Y : REGEL
*³                        X : KOLOM
*³ Werking ............ : TOONT M.B.V. INDICATOREN AAN WAAR WE IN DE TEKST ZIJN
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

procedure statmsg (y,x)
local bx := (xdl/linelen)
local by := (ydl/maxline)
local cmx := x1+x*bx+2
local cmy := y1+y*by+2
local wx1 := x2,wy1 := y2
setcolor(DIALOG_LIST[6])
if !edit
  if ccy != cmy
     @ ccy,wx1,ccy+4,wx1 box IND_V1
     @ cmy,wx1,cmy+4,wx1 box IND_V2
     ccy = cmy
  endif
else
  if ccy != cmy
     @ y1+2,wx1,y2-2,wx1 box IND_H2
  endif
endif
if ccx != cmx
   @ wy1,ccx,wy1,ccx+4 box IND_H1
   @ wy1,cmx,wy1,cmx+4 box IND_H2
   ccx = cmx
endif
setcolor(tcol)
return

*³ Functie ............ : ZOEK (STATIC)
*³ Werking ............ : ZOEKT IN MEMO NAAR OP TE GEVEN TEKST
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

static function zoek
local scr := savescreen (y2,x1+1,y2,x2-1)
// Voer eerst de te zoeken string in :
setcolor(DIALOG_INPUT[1]+","+DIALOG_INPUT[2])
@ y2,x1+2 say "Zoek :"
@ y2,x1+1+6 get patroon picture '@K@S'+LTRIM(STR(x2-9-x1+1))
NewRead()
if lastkey() != K_ESC .and. !empty(patroon)
   zoekv(0)
else
   patroon := P_EMPTY
   edmsg()
endif
restscreen(y2,x1+1,y2,x2-1,scr)
return nil

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*³ Functie ............ : ZOEKV (STATIC)
*³ Werking ............ : ZOEKT VERDER IN MEMO NAAR VORIG OPGEGEVEN TEKST
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

static function zoekv (x)
local nrow, pos, offset, newcol, a
if (!empty(patroon))
   nrow := tbrow
   pos := x+MLCToPos(temptext,linelen,tbrow,tbcol,tabsize,wrap2)
   offset := pos+at(upper(rtrim(patroon)),upper(substr(temptext,pos)))-1
   if (offset >= pos)
      a := MPosToLC(temptext,linelen,offset,tabsize,wrap2)
      tbrow := a[1]
      newcol := a[2]
      wincol := wincol + newcol - tbcol
      tbcol := newcol
      if (tbrow-nrow<1+y2-1-3-ty-winrow)
         winrow := winrow + tbrow - nrow
      endif
      edmsg ("Gevonden")
   else
      edmsg (iif(x=0,"Tekst niet gevonden","Tekst verder niet meer aanwezig"))
      if x = 0
         patroon = P_EMPTY
      else

      endif
      beep()
   endif
else
   zoek()
endif
return nil

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*³ Functie ............ : EDMSG
*³ Syntax ............. : EDMSG(TEKST)
*³ Parameters ......... : TEKST : TEKST VAN MEDEDELING
*³ Geeft terug ........ : NIL
*³ Werking ............ : TOONT A.D.H.V. MSG-FLAG (PARAMETER VAN ED)
*³                        EVT. EEN MEDEDELING
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

static function edmsg (tekst)
local m
if msgon
   askwindow("Mededeling",tekst,{"^OK"},1,DIALOG_TEXT)
endif
return nil
