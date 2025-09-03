*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*³ Module ............. : ALGEMEEN
*³ Omschrijving ....... : ALGEMENE FUNCTIES/PROCEDURES
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

#include "inkey.ch"
#include "config.ch"
#include "fileio.ch"
#include "defaults.ch"

function perror(t)
return (askwindow("FOUT",t,{"^OK"},1,iif(len(_SETTINGS_)==0,{"W/N","W+/N","N/W"},ERROR)))

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*³ Functie ............ : DIFF
*³ Syntax ............. : V := DIFF(X1,X2)
*³ Parameters ......... : X1, X2 : NUMERIEKE WAARDEN, OF DATA
*³ Geeft terug ........ : VERSCHIL TUSSEN X1 EN X2 (ABS)
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

function diff (arg1, arg2)
return abs(arg1-arg2)

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*³ Functie ............ : BEEP
*³ Syntax ............. : BEEP()
*³ Parameters ......... : -
*³ Geeft terug ........ : SINUSSPANNING OP DE PC-SPEAKER
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

procedure beep
local i
if CONFIG_BEEPER
   for i := 0 to 2
       sound(700-i*200,1)
   next
endif
return

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*³ Functie ............ : NUM2ENG
*³ Syntax ............. : C := NUM2ENG(N)
*³ Parameters ......... : N : NUMERIEKE WAARDE
*³ Geeft terug ........ : KARAKTERSTRING
*³ Werking ............ : MAAKT VAN DE NUMERIEKE WAARDE EEN
*³                        WETENSCHAPPELIJKE NOTERING (k=KILO e.d.)
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

function Num2Eng (n)
local s := 1, ts := "pnæm kMGT", i, j, k := n
for i := 1 to 9
    j := n/(10^((i-5)*3))
    if (j >= 1.0)
       s := i
       k := j
    endif
next
return (ltrim(str(k,5,1)+alltrim(substr(ts,s,1))))

// Bepaalt van een aantal seconden de tijd (uur:min:sec)
function OnOffState (l)
return iif(l,"AAN","UIT")

function YesNoState (l)
return iif(l,"JA ","NEE")

procedure clockOn
keystat(.T.)
capstext (0,55,"CAPS",colorton(BACKGR[2]))
numtext  (0,60,"NUM",colorton(BACKGR[2]))
scrltext (0,64,"SCLK",colorton(BACKGR[2]))
showtime(0,71,.F.,BACKGR[2])
return

procedure clockOff
keystat(.F.)
showtime()
return

function Exec (dir, cmd, pause, msgon)
local curd, scr := save_video(.T.), NoFail, p := "", m := getscrmode()
  help_off()
  clockOff()
  curd := O_CurPath()
  setscrmode(OLD_MODE)
  if msgon
     p := chr(0)+"PROMPT=['EXIT':Terug naar "+PROGNAME+" | Path=$P]$_$G"
  endif
  clear typeahead
  if !empty(dir) .and. O_DirExist(dir)
     O_CD(dir)
  endif
  O_RestDir(.T.)
  restore screen from DOS_SCREEN[1]
  restcursor(DOS_SCREEN[2,1])
  setcolor(DOS_SCREEN[2,2])
  setblink(DOS_SCREEN[2,3])
  NoFail := Overlay(cmd, 0, GETENV("TEMP"),"OVERLAYED=Y"+p)
  save screen to DOS_SCREEN[1]
  DOS_SCREEN[2] := {savecursor(),setcolor(),setblink()}
  set cursor off
  if pause
     setcolor("N/W")
     scroll(0,0,maxrow(),maxcol(),1) // Make room for announcement
     @ maxrow(),0 say padc("Press any key to return to "+PROGNAME,maxcol()+1)
     inkey(0)
  endif
  O_CD(curd)
  setscrmode(m)
  setblink(.F.)
  rest_video(scr)
  ClockOn()
  if !NoFail
     askwindow("FOUT","Er is een fout opgetreden tijdens de DOS-sessie,;"+;
     "of tijdens het op disk aanmaken ;van het wisselbestand.",{"^OK"},ERROR)
  endif
  help_on()
return (NIL)

function sec2time(s)
local min := int(s/60), sec := s%60, l
return ntoc(min,10,iif(min > 99,3,2),"0")+":"+ntoc(sec,10,2,"0")

function labtext(y,x,label,tekst,labcol,tekstcol)
local c := setcolor()
labcol := pdef(labcol,DIALOG_TEXT[1])
tekstcol := pdef(tekstcol,DIALOG_TEXT[4])
setcolor(labcol)
@ y,(x-len(label)-1) say label
setcolor(tekstcol)
@ y,x say tekst
setcolor(c)
return (NIL)


function tune (n)
local t, f[2]
if CONFIG_BEEPER
   do case
      case n == TUNE_LASER
           f[1]:=900
           f[2]:=600
           for t := 0 to 4
               sound(f[1],1)
               sound(f[2],1)
               f[1]-=190
               f[2]-=90
           next
      case n == TUNE_RING
           for t := 1 to 10
              sound(988,1)
              sound(587,1)
           next
      case n == TUNE_BUTTONPRESS
           for t := 1 to 4
               sound (450-t*100,1)
           next
      case n == TUNE_NOTFOUND
           sound(240,8)
           sound(110,8)
   endcase
endif
return nil

function rewind(h)
if valtype(h) == "N"
   return (fseek(h,0,SEEK_SET))
else
   perror("Function ~REWIND~ called with non-numerical parameter.")
   exit(1)
endif
return (-1)

function save_config
local m := message("Bewaren instellingen")
if save_array(CONFIG_NAME, _SETTINGS_)
   // OK
else
   // error
   perror("Fout tijdens schrijven instellingenbestand")
endif
closemessage(m)
return

function restore_config(n)
local m[2], c := if(empty(_SETTINGS_),{"W/N","W+/N","N/W"},DIALOG_TEXT) // due to startup in DOS
m[1]:= message("Lezen instellingenbestand",,c)
_SETTINGS_ := restore_array(CONFIG_NAME)
if errorlevel()#0
   m[2] := Message("Fout tijdens lezen instellingenbestand : Standaard instellingen actief.",,c)
   _SETTINGS_ := default_config()
   CFG_CHANGED := .T.
   if iscolor()
      CONFIG_COLORSET := 2
   else
      CONFIG_COLORSET := 1
   endif
   inkey(2)
   closeMessage(m[2])
else
   // OK, restored the shit.
endif
closeMessage(m[1])

// Voor 'toekomstige' versie : volgende regels overrulen 'default system'
CONFIG_DBF_PATH := strTran(truename(dirname())+"\", "\\", "\")
return

function save_array (n, a)
local h, i
if valtype(a)=="A"
   h := fcreate(n, FC_NORMAL)
   if h # -1
      store_element(h, a)
   else
      return .F.
   endif
   fclose(h)
else
   // error
   perror("Function ~SAVE_ARRAY~ called with non-array element.")
   exit(1)
endif
return .T.

function store_element(h,x)
local v := {0,0,valtype(x)}, p
do case
   case v[3]=="C"
        v[1]:=charpack(x)
        v[2]:=len(x)
        if v[2] <= len(v[1]) // Compression has no effect
           fwrite(h,"S",1)
           fwriteint(h,v[2])
           fwrite(h,x)
        else
           fwrite(h,"P",1)
           fwriteint(h,len(v[1]))
           fwriteint(h,v[2])
           fwrite(h,v[1])
        endif
   case v[3]=="N"
        if x >= 0
           if x < 65536 .and. x==int(x)
              if x < 256 .and. x==int(x)
                 fwrite(h,"B",1)
                 fwritebyte(h,x)
              else
                 fwrite(h,"W",1)
                 fwriteint(h,x)
              endif
           else
              fwrite(h,"N"+xtoc(x)) // NT250 : Num -> 8 chars
           endif
        else
           fwrite(h,"N"+xtoc(x)) // NT250 : Num -> 8 chars
        endif
   case v[3]=="L"
        fwrite(h,"L",1)
        fwritebyte(h,iif(x,1,0))
   case v[3]=="D"
        v[1] := val(dtos(x))
        fwrite(h,"D",1)
        fwritelong(h,v[1])
   case v[3]=="A"
        v[1] := len(x) // max.size of array = 2^16=65536 elements
        fwrite(h,"A",1)
        fwriteint(h,v[1])
        for v[2] := 1 to v[1]
            store_element(h,x[v[2]])
        next
   case v[3]=="U"
        fwrite(h," ",1)
   otherwise
endcase
return

function restore_array(n)
local h := fopen(n, FO_READ), a
errorlevel(0)
if h # -1
   // Here goes nothing ...
   if read_element(h,@a)
      // Reading went OK
   else
      errorlevel(1)
      return {}
   endif
else
   errorlevel(1)
   return {}
endif
return (a) // Bitte ...

// Call 'a' by reference, like FREAD() !!!
function read_element(h,a)
local v[2], x, w := space(1)
w := chr(freadbyte(h))
do case
   case w=="S"
        v[1] := freadint(h)
        a := space(v[1])
        fread(h,@a,v[1])
   case w=="P"
        v[1] := freadint(h)
        v[2] := freadint(h)
        x := space(v[2])
        fread(h,@x,v[1])
        a := charunpack(x)
   case w=="N"
        x := space(8)
        fread(h,@x,8)
        a := ctof(x)
   case w=="B"
        a := freadbyte(h)
   case w=="W"
        a := freadint(h)
   case w=="L"
        a := iif(freadbyte(h)==0,.F.,.T.)
   case w=="D"
        x := str(freadlong(h),8)
        a := stod(x) // NT250 function
   case w=="A"
        a := {}
        v[1] := freadint(h)
        for v[2] := 1 to v[1]
            if !read_element(h,@x) // Insert (recursive)
               exit
            else
               aadd(a,x)
            endif
        next
   case w==" "
        a := NIL
   otherwise
        errorlevel(1)
        return .F.
endcase
return .T.

function default_config()
local a := {DEF_CONFIG} // Not at once, Preprocessor doesn't like long #define's
local c := {DEF_MONOSET, DEF_COLORSET, DEF_REDSET, DEF_BLUESET, DEF_GREENSET}, i
aadd(a,c)
return (a)

function NULLFUNC
return

function keyPut(k)
keyboard chr(k)
return .T.

function NewRead
local old := {setkey(K_TAB,{||keyPut(K_DOWN)}), setkey(K_SH_TAB,{||keyPut(K_UP)})}
set cursor on
read
set cursor off
setkey(K_TAB,old[1])
setkey(K_SH_TAB,old[2])
return
