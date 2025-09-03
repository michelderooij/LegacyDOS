#include "inkey.ch"
#include "config.ch"
#include "set.ch"
#include "box.ch"
#include "achoice.ch"

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*³ Procedure .......... : CREGEL
*³ Syntax ............. : CREGEL (ROW,TEKST)
*³ Parameters ......... : ROW    : REGEL WAAROP TEKST TE PLAATSEN
*³                        TEKST  : AF TE DRUKKEN TEKST
*³ Werking ............ : DRUKT TEKST GECENTREERD AF OP REGEL ROW
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

PROCEDURE cregel (RNO, TEKST)
LOCAL S := MAXCOL()/2-LEN(TEKST)/2
@RNO,S SAY TEKST
RETURN 

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*³ Functie ............ : SAVE_VIDEO
*³ Syntax ............. : V := SAVE_VIDEO(A)
*³                        A == (default) .F., vanaf line 1 (vanaf 0 is .T.)
*³ Geeft terug ........ : V      : HANDLER NAAR OUDE VIDEO-STATUS
*³ Werking ............ : SLAAT TIJDELIJK ALLE VIDEODATA OP IN V (ARRAY)
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

function save_video (a)
local items[5]
items[4] := pdef(a,.F.)
items[5] := {maxrow(),maxcol()}
if items[4]
   // save all
   items[1] := savescreen(0,0,items[5,1],items[5,2])
else
   // save all but line 0
   items[1] := savescreen(1,0,items[5,1],items[5,2])
endif
items[2] = setcolor()
items[3] = setcursor()
return (items)

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*³ Functie ............ : REST_VIDEO
*³ Syntax ............. : REST_VIDEO(V)
*³ Parameters ......... : V    : OUDE VIDEOSTATUS HANDLER
*³ Geeft terug ........ : NIL
*³ Werking ............ : IN COMBINATIE MET SAVE_VIDEO() GEBRUIKEN.
*³                        DUS : REST_VIDEO(SAVE_VIDEO()) IS OK.
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

function rest_video ( items )
if items[4]
   restscreen(0,0,items[5,1],items[5,2],items[1])
else
   restscreen(1,0,items[5,1],items[5,2],items[1])
endif
setcolor(items[2])
setcursor(items[3])
return NIL

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*³ Functie ............ : CLOSEWINDOW
*³ Syntax ............. : CLOSEWINDOW(W)
*³ Parameters ......... : W  : HANDLER NAAR WINDOW
*³ Geeft terug ........ : NIL
*³ Werking ............ : VERWIJDERT WINDOW, EN HERSTELT WAT ERONDER ZAT. DUS :
*³                        CLOSEWINDOW(OPENWINDOW(0,0)) IS OK.
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

function closewindow (w)
restscreen(w[1],w[2],w[3],w[4],w[5])
setcolor(w[6])
return nil

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*³ Functie ............ : OPENWINDOW
*³ Syntax ............. : OPENWINDOW(Y1,X1,[Y2],[X2],[HEADER],[ACOL],MayClose)
*³ Parameters ......... : Y1,X1 : COORDINAAT LINKSBOVEN
*³                        Y2    : Y-COORDINAAT RECHTSONDER. DEFAULT = 24
*³                        X2    : X-COORDINAAT RECHTSONDER. DEFAULT = 79
*³                                INDIEN X2==X1, OF Y2==Y1, DAN ALLEEN CLEAR
*³                                MET SCHADUW.
*³                        HEADER: TITEL WINDOW. DEFAULT = "". FORCEER LEGE
*³                                HEADER (IN Z'N KLEUR) : MAAK HEADER "@".
*³                                ANDERS LEGE HEADER => GEEN HEADER !
*³                        ACOL  : COLOR-ARRAY 1=text, 3=header
*³ Geeft terug ........ : HANDLER NAAR WINDOW
*³ Werking ............ : TEKENT WINDOW OP SCHERM, BEWAART ALLES WAT ERONDER ZAT
*³
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

function openwindow (y1,x1,y2,x2,header,kleur)
local winobj[6]
local st := sb := min(y2+1,maxrow()),sl := x1+1,sr := min(x2+1,maxcol())
winobj := {y1,x1,sb,sr,savescreen(y1,x1,sb,sr),setcolor()}
kleur=pdef(kleur,DIALOG_TEXT)
header=pdef(header,"")
setcolor(kleur[1])
@ y1,x1,y2,x2 BOX iif(y1==y2 .or. x1==x2,space(9),B_SINGLE+" ")
if (!empty(header) .or. header="@") .and. (diff(x2,x1)+1) > len(header)
   if header#"@"
      setcolor(kleur[3])
   else
      // Menu of zo, geen header->geen andere kleur
   endif
   @ y1,x1,y1,x2 box space(9)
   if header="@"
      header = ""
   endif
   @ y1,(x1+x2)/2-len(header)/2+1 say header
endif
shade(y1,x1,y2,x2)
setcolor(kleur[1])
RETURN (winobj)

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*³ Functie ............ : SAYKEYS
*³ Syntax ............. : SAYKEYS(REGEL,F)
*³ Parameters ......... : REGEL     : REGEL MET TOETS-BESCHRIJVINGEN
*³                        F         : Fill to the most-right column (def=.T.)
*³ Geeft terug ........ : .T.
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

function saykeys (st,f)
st := pdef(st,"")
f := pdef(f,.T.)
if f
   highlite(maxrow(),1,st,BACKGR[4],BACKGR[5],maxcol()) // Fill-Out
else
   highlite(maxrow(),1,st,BACKGR[4],BACKGR[5])
endif
return .t.

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*³ Function ........... : VERTMENU
*³ Syntax ............. : keuze := VERTMENU(y,x,choicelist,init,cls)
*³ Werking ............ : Toont verticaal menu, en laat kiezen
*³ choice = "@" = seperation line, "+..." = (sub-)submenu available,
*³          "?.. û" = On/Off state
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

function VertMenu (y,x,choicelist,init,cls)
local ey, ex, choice, maxlen := 0, selectable := {}, v, choose := {}, c := setcolor()
local i:=1, keus := {}
cls := pdef(cls,.T.)
selectable := afill(asize({},len(choiceList)),.T.)
aeval(choiceList,{|x| maxlen := max(iif("^"$x,len(x)-1,len(x)),maxlen)})
maxlen+=2
aeval(choiceList,{|x| aadd(choose," "+iif(left(x,1)=="+",padr(substr(x,2),maxlen-2)+"",;
                                      iif(left(x,1)=="?",padr(substr(x,2,len(x)-4),maxlen-4)+right(x,3),x)))})
aeval(choose, {| line | iif(" @"$line, aadd(keus,0), aadd(keus,i++))})
for i := 1 to len(choose)
    if (" @"$choose[i]) .and. init >= i
       init++
    endif
next
v := openWindow(y,x,1+y+len(choose),1+x+maxlen,"",MENU)
while (choice := ascan(choose," @")) > 0
       choose[choice] := replicate("Ä",maxlen)
       selectable[choice] := .F.
       ey := y+choice
       restscreen(ey,x,ey,x,transform(savescreen(ey,x,ey,x),"ÃX"))
       restscreen(ey,1+x+maxlen,ey,1+x+maxlen,transform(savescreen(ey,1+x+maxlen,ey,1+x+maxlen),"´X"))
end
init := min(init,len(choose))
choice := vSelection(y+1,x+1,x+maxlen,choose,selectable,init,MENU,cls)
if cls .or. choice==0
   closewindow(v)
else
   setcolor(c)
endif
setpos(y+choice,x+maxlen)
return iif(choice>0, keus[choice], 0)

function vSelection(y1,x1,x2,choices,active,init,cols,cls)
local choix := init, i, k, nextc, keys[0], w, p,c, shortcut[0], done := .F.
aeval(choices,{|x| aadd(keys,at("^",x))})
setcolor(cols[1])
for i := 1 to len(choices)
    if (p := keys[i]) > 0
       c := choices[i]
       w := lower(substr(c,p+1,1))
       aadd(shortcut,{asc(w),i})
       aadd(shortcut,{asc(upper(w)),i})
       choices[i] := left(c,p-1)+substr(c,p+1)
    else

    endif
    k := y1+i-1
    vPrompt(k, x1, x2, choices[i], keys[i],cols[1],cols[2])
next
asort(shortcut,,,{|x,y| x[1]<y[1]})
while .T.
      vPrompt(y1+choix-1, x1, x2, choices[choix], keys[choix],cols[3],cols[4])
      k := EventWait()
      vPrompt(y1+choix-1, x1, x2, choices[choix], keys[choix],cols[1],cols[2])
      do case
         case k == K_LEFT .or. k == K_RIGHT
              choix := 0
              exit
         case k == K_ESC
              choix := 0
              exit
         case k == K_UP
              nextc := choix-1
              while nextc > 0 .and. !active[nextc]
                    nextc--
              end
              if nextc > 0
                 choix := nextc
              else
                 if set(_SET_WRAP)
                    // WRAP
                    choix := last_active(active)
                 else
                    // No change
                 endif
              endif
         case k == K_DOWN
              nextc := choix+1
              while nextc <= len(active) .and. !active[nextc]
                    nextc++
              end
              if nextc <= len(active)
                 choix := nextc
              else
                 if set(_SET_WRAP)
                    // WRAP
                    choix := first_active(active)
                 else
                    // No change
                 endif
              endif
         case k == K_HOME .OR. k == K_PGUP
              choix := first_active(active)
         case k == K_END .OR. k == K_PGDN
              choix := last_active(active)
         case k == K_ENTER
              exit
         otherwise
              if (w := ascan(shortcut,{|x| x[1]==k})) > 0
                 choix := shortcut[w,2]
                 exit
              else

              endif
      endcase
end
if !cls
   for i := 1 to len(choices)
       vPrompt(y1+i-1, x1, x2, choices[i], 0,cols[1])
   next
endif
return (choix)

function first_active(a)
local i
for i := 1 to len(a)
    if a[i]
       return (i)
    endif
next
return 1

function last_active(a)
local i
for i := len(a) to 1 step -1
    if a[i]
       return (i)
    endif
next
return len(a)

function vPrompt(y,x,x2,pt,pk,cn,ck)
local c := setcolor()
setcolor(cn)
@ y, x say padr(pt,(x2-x)+1)
if pk > 0
   setcolor(ck)
   @ y, x+pk-1 say substr(pt,pk,1)
else

endif
setcolor(c)
return NIL


function message(t,h,c)
local y := maxrow()/2-2, x := maxcol()/2-len(t)/2-2, w
c := pdef(c,DIALOG_TEXT)
h := pdef(h,"Mededeling")
w := openwindow(y,x,y+3,x+len(charrem("~",t))+4,h,c)
highlite(y+2,x+2,t,c[1],c[2])
return (w)

function closemessage(w)
closewindow(w)
return nil

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*³ Functie ............ : ASKWINDOW
*³ Syntax ............. : ASKWINDOW(H,T,A,D,TC,OR,SY)
*³ Parameters ......... : H  : HEADER
*³                        T  : TEKST VOOR IN WINDOW. SCHEIDT REGELS MET ";"
*³                        A  : ARRAY MET MOGELIJKE KEUZES/ANTWOORDEN
*³                        D  : DEFAULT ANTWOORD. INDIEN ESC GEDRUKT, DAN
*³                             GEEFT ASKWINDOW D TERUG. DEFAULT = 1
*³                        TC : COLORARRAY 1=norm, 2=high("~x~"), 3=header
*³                        OR : Orientatie : 1 = hori, 2 = vert (default=1)
*³ Geeft terug ........ : POSITIE VAN GEKOZEN OPTIE/ANTWOORD IN ARRAY A.
*³                        INDIEN ESC, DAN D.
*³ Werking ............ : TOONT WINDOW (AUTO-SIZE) MET DAARIN GECENTREERD
*³                        DE TEKST UIT T, EN LAAT KIEZEN UIT ARRAY A.
*³                        Indien regel begint met << of >>, dan wordt deze
*³                        regel links/rechts uitgelijnd.
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

function askwindow (header,tekst,answers,defaultanswer,acol,ori,sx)
local c:=setcolor(),p,l,boxheight,boxwidth,x1,y1,x2,y2,w,mla:=0,mlt:=0,rval
local nline[0], keys := {}, posarr := {}, butt, kp, justify[0]
acol := pdef(acol,DIALOG_TEXT)
header=pdef(header,"")
defaultanswer=pdef(defaultanswer,1)
ori := pdef (ori,1)
// Zet strings uit gecombineerde string in een array ...
if !empty(tekst)
   tekst+=";"
   while (p := at(";",tekst)) > 0
      l := left(tekst,p-1)
      do case
         case left(l,2)=="<<" // Left justify
              l := substr(l,3)
              aadd(justify,-1)
         case left(l,2)==">>" // right justify
              l := substr(l,3)
              aadd(justify,1)
         otherwise
              aadd(justify,0)
      endcase
      mlt := max(mlt,len(l))
      aadd(nline,l)
      tekst = substr(tekst,p+1)
   end
else
   nline := {}
   mlt := 0
endif
boxheight := (len(nline)+iif(ori==1,5,1))
if ori == 2
   boxheight += 2*len(answers)+iif(len(nline)#0,2,1) // Tussenruimte
endif
for p := 1 to len(answers)
    if (l := at("^",answers[p])) > 0
       aadd(keys,{asc(lower(substr(answers[p],l+1,1))),p})
       aadd(posarr,{len(answers[p])+3,l+2+iif(ori==2,2,0)})
       answers[p] := " "+left(answers[p],l-1)+substr(answers[p],l+1)+" "
    else
       aadd(posarr,{len(answers[p])+4,0})
       answers[p] := " "+answers[p]+" "
    endif
    if ori == 1
       // horizontaal
       mla += posarr[p,1]
    else
       // verticaal
       mla := max(mla,posarr[p,1])
    endif
next
// mla+len(answers+1 zorgt zeker voor een lege positie rond de antwoorden
boxwidth := max(max((mla+len(answers)+1),mlt),len(header))+2
y1 := maxrow()/2-boxheight/2
x1 := pdef(sx,maxcol()/2-boxwidth/2)
if ori == 1
   y2 := y1+boxheight-2
else
   y2 := y1+iif(len(nline)>0,len(nline)+3,2)
endif
x2 := x1
w := openwindow(y1,x1,y1+boxheight,x1+boxwidth+1,header,acol)
for p := 1 to len(nline)
    do case
       case justify[p] == 0
            highlite(y1+p+1,x1+2,nline[p],acol[1],acol[2],boxwidth-2,1)
            //lightemup (y1+p+1,x1+2,padc(nline[p],boxwidth-2),acol[1],acol[2],.F.)
       case justify[p] < 0
            highlite(y1+p+1,x1+2,nline[p],acol[1],acol[2],boxwidth-2,0)
            //lightemup (y1+p+1,x1+2,padr(nline[p],boxwidth-2),acol[1],acol[2],.F.)
       case justify[p] > 0
            highlite(y1+p+1,x1+2,nline[p],acol[1],acol[2],boxwidth-2,2)
            //lightemup (y1+p+1,x1+2,padl(nline[p],boxwidth-2),acol[1],acol[2],.F.)
    endcase
next
// Bepaal ruimte voor tussen elk antwoord :
l := (boxwidth+2-mla)/(len(answers)+1)
butt := {}
if ori == 1
   for p := 1 to len(answers)
       x2 += l
       drawButton(y2,x2," "+answers[p]+" ",posarr[p,2],DIALOG_BUTTON[1],DIALOG_BUTTON[2])
       aadd(butt,{y2,x2})
       x2 += posarr[p,1]
   next
else
   for p := 1 to len(answers)
       answers[p] := padc(answers[p],boxwidth-5)
       if (l := rat("*",answers[p])) > 0
          answers[p] := stuff(answers[p],l,1,"")+""
       else

       endif
       drawButton(y2,x2+2," "+answers[p]+" ",posarr[p,2],DIALOG_BUTTON[1],DIALOG_BUTTON[2])
       aadd(butt,{y2,x2+2})
       y2+=2
   next
endif
rval := defaultAnswer
while .T.
      drawButton(butt[rval,1],butt[rval,2],""+answers[rval]+"",posarr[rval,2],DIALOG_BUTTON[3],DIALOG_BUTTON[4])
      k := EventWait()
      drawButton(butt[rval,1],butt[rval,2]," "+answers[rval]+" ",posarr[rval,2],DIALOG_BUTTON[1],DIALOG_BUTTON[2])
      do case
         case k == K_ESC
              rval := 0
              exit
         case k == K_LEFT .or. k == K_UP
              rval := iif(rval==1,len(answers),rval-1)
         case k == K_RIGHT .or. k == K_DOWN
              rval := iif(rval==len(answers),1,rval+1)
         case k == K_HOME
              rval := 1
         case k == K_END
              rval := len(answers)
         case k == K_ENTER
              exit
         otherwise
              if (k := ascan(keys,{|x| x[1]==k})) > 0
                 rval := keys[k,2]
                 exit
              else

              endif
      endcase
end
if rval # 0
   pressButton(butt[rval,1],butt[rval,2],""+answers[rval]+"",posarr[rval,2],DIALOG_BUTTON[3],DIALOG_BUTTON[4])
endif
closewindow(w)
setcolor(c)
// Return geen 0 : dan default ... (die kan wel 0 zijn door ESC, maar
// zet dit dan expliciet in defaultanswer...)
return iif((rval==0),defaultanswer,rval)

function shade(y1,x1,y2,x2)
local y := {y1+1,y2+1}, x := {x1+1,x2+1}
local k := iif(_VIDEO_#_MONO,"ß","Û")
local l := {y[2]-y1, x[2]-x1}, c
colfix(y[2],x[1],y[2],x[2],k)
if x2 # maxcol()
   if y1#y2
      colfix(y[1],x[2],y2,x[2],"Û")
   endif
   c := left(savescreen(y1,x[2],y1,x[2]),1)
   if c==k .OR. c=="Û"
      colfix(y1,x[2],y1,x[2],"Û")
   else
      if _VIDEO_#_MONO
         colfix(y1,x[2],y1,x[2],"Ü")
      endif
   endif
endif
return

static function colfix(y1,x1,y2,x2,c) // Makes FG-attribute black, evt. put c on screen
#define CHANGE_ATTRIBUTE(y,x,c)  clearwin(y,x,y,x,numand(getattr(y,x),240),c)
local i, j
if diff(y2,y1)<1
   for i := x1 to x2
       CHANGE_ATTRIBUTE(y1,i,c)
   next
else
   if diff(x2,x1)<1
      for i := y1 to y2
          CHANGE_ATTRIBUTE(i,x1,c)
      next
   else
      // big job
      for i := y1 to y2
          for j := x1 to x2
              CHANGE_ATTRIBUTE(i,j,c)
          next
      next
   endif
endif
return nil

function okButton(y,x)
drawButton(y,x,"  OK  ",3,DIALOG_BUTTON[3],DIALOG_BUTTON[4])
while ascan({K_ENTER,111,K_ESC},EventWait())==0
      // ZZZzzzzzz.....
end
pressButton(y,x,"  OK  ",0,DIALOG_BUTTON[3],DIALOG_BUTTON[4])
return

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*³ Function ........... : HORZMENU
*³ Syntax ............. : keuze := HORZMENU(y,x,choicelist,poslist,init)
*³ Werking ............ : Toont horizontaal menu, en laat kiezen
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

function HorzMenu (y,choicelist,poslist,init)
local choice
choice := hSelection(y,choicelist,poslist,init,MENU)
return iif(choice>0, choice, 0)

function hSelection(y,choices,poslist,init,cols)
local choix := init, i, k, keys[0], w, p,c, shortcut[0], k2
aeval(choices,{|x| aadd(keys,at("^",x))})
setcolor(cols[1])
for i := 1 to len(choices)
    if (p := keys[i]) > 0
       c := choices[i]
       w := lower(substr(c,p+1,1))
       aadd(shortcut,{asc(w),i})
       aadd(shortcut,{asc(upper(w)),i})
       choices[i] := left(c,p-1)+substr(c,p+1)
    else

    endif
    hPrompt(y, poslist[i], choices[i], keys[i],cols[1],cols[2])
next
asort(shortcut,,,{|x,y| x[1]<y[1]})
while .T.
      hPrompt(y, poslist[choix], choices[choix], keys[choix],cols[3],cols[4])
      k := EventWait()
      hPrompt(y, poslist[choix], choices[choix], keys[choix],cols[1],cols[2])
      do case
         case k == K_ESC
              choix := 0
              exit
         case k == K_LEFT
              choix--
              if choix==0
                 if set(_SET_WRAP)
                    choix := len(choices)
                 else
                    choix := 1
                 endif
              else

              endif
         case k == K_RIGHT
              choix++
              if choix>len(choices)
                 if set(_SET_WRAP)
                    choix := 1
                 else
                    choix := len(choices)
                 endif
              else

              endif
         case k == K_DOWN .OR. k == K_PGDN
              exit
         case k == K_ENTER
              exit
         otherwise
              if (w := ascan(shortcut,{|x| x[1]==k})) > 0
                 choix := shortcut[w,2]
                 exit
              else

              endif
      endcase
end
for i := 1 to len(choices)
    if i#choix
       hPrompt(y, poslist[i], choices[i], 0,cols[1])
    else
       hPrompt(y, poslist[i], choices[i], 0,cols[3])
    endif
next
return (choix)

function hPrompt(y,x,pt,pk,cn,ck)
setcolor(cn)
@ y, x say pt
if pk > 0
   setcolor(ck)
   @ y, x+pk-1 say substr(pt,pk,1)
else

endif
return NIL

function drawButton(y,x,t,p,n,h)
hPrompt(y,x,t,p,n,h)
shade(y,x,y,x+len(t)-1)
return

function pressButton(y,x,t,p,n,h)
local a := getattr(y+1,x), v := savescreen(y,x,y+1,x+len(t))
setattr(y,x,y+1,x+len(t),a," ")
hPrompt(y,x+1,t,p,n,h)
tune(TUNE_BUTTONPRESS)
// Small delay, otherwise we wouldn't even notice the FX
sound(0,30)
restscreen(y,x,y+1,x+len(t),v)
return

function save_keys
return savescreen(maxrow(),0,maxrow(),maxcol())

function rest_keys(v)
restscreen(maxrow(),0,maxrow(),maxcol(),v)
return

function ListWindow
parameters y,x,h,w,title,a,v,i,r, OwnUDF
private wh, topy, boty, keus, bars
private ex, ey, olde := 1
OwnUDF := pdef(OwnUDF,"")
if x==-1
   x := int(maxcol()/2-(w/2))
endif
if y==-1
   y := int(maxrow()/2-(h/2))
endif
ex := x+w-1
ey := y+h-1
v := pdef(v,.T.)
wh := openwindow(y,x,ey,ex,title,DIALOG_LIST)
setcolor(DIALOG_LIST[6])
topy := y+1
boty := y+h-2
ex := x+w-1
@ topy,ex say ""
@ boty,ex say ""
topy++
h := (boty-1)-(topy)+1
if len(a) > h
   bars := h/len(a)
   @ topy,ex,boty-1,ex box IND_V1
else
   bars := h-1
   @ topy,ex,boty-1,ex box IND_V2
endif
setcolor(DIALOG_LIST[5]+","+DIALOG_LIST[4])
clear typeahead
keyboard chr(K_RIGHT) // No active the "METER"
keus := achoice(topy-1,x+2,boty,ex-2,a,v,"ListWinUDF",i,r)
closewindow(wh)
return (keus)

function ListWinUDF (m,e,r)
local key := lastkey()
if !empty(OwnUDF)
   eval(OwnUDF)
else

endif
if m == AC_HITTOP .or. m == AC_HITBOTTOM
   beep()
else
   if len(a) > h
      show_meter(topy,ex,olde,IND_V1)
      show_meter(topy,ex,e,IND_V2)
      olde := e
   else
   endif
endif
do case
   case key == K_ENTER
        return (AC_SELECT)
   case key == K_ESC
        return (AC_ABORT)
   case key == K_HOME
        keyboard chr(K_CTRL_PGUP)
   case key == K_END
        keyboard chr(K_CTRL_PGDN)
endcase
return (AC_CONT)

// y,x = pos, p = percentage, c = char of box
static function show_meter(y,x,p,c)
local ny := y+int((p-1)*bars)
charwin(ny,x,ny+bars,x,c)
return

function EventWait()
k := inkeyTrap(0)
return (k)

function setvideomode(n)
return eval(SCREENMODES[n,3])

function highlite(y,x,tekst,norm,high,width,just)
local hat[0], p[2], occ := 1, ofs := 0
just := pdef(just,0)
while (p[1] := atnum("~",tekst,occ) ) > 0
      if (p[2] := atnum("~",tekst,occ+1) ) > 0
         aadd(hat,{p[1]-occ,p[2]-occ-2})
         occ+=2
      else
         exit
      endif
end
if occ # 1
   tekst := strtran(tekst,"~","",1,occ-1)
else

endif
width := pdef(width,len(tekst))
do case
   case just == 0
        print(y,x,padr(tekst,width),colorton(norm))
   case just == 1
        print(y,x,padc(tekst,width),colorton(norm))
        ofs := max(int((width-len(tekst))/2),0)
   case just == 2
        print(y,x,padl(tekst,width),colorton(norm))
        ofs := max(width-len(tekst),0)
endcase
if len(hat) > 0
   for occ := 1 to len(hat)
       colorwin(y,x+ofs+hat[occ,1],y,x+ofs+hat[occ,2],high)
   next
else

endif
return

