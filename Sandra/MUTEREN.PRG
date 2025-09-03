#include "config.ch"
#include "box.ch"
#include "inkey.ch"
#include "help.ch"

#define RX            0
#define RY           14
#define OPX          25
#define EX           78
#define WID          (EX-RX-1)

#define CURR          1
#define TOPR          2

#define ALB_DATA      1
#define REC_DATA      2
#define COM_DATA      3

#define ONE_REC       1
#define MIX_BEG       2
#define MIX_PART      3
#define MIX_END       4

#define TYPEREC       {" ","","Ã","À"}

#define REC_RECNR      1
#define REC_TIME       2
#define REC_ISAMIX     3
#define REC_MULTIART   4
#define REC_DISKNR     5
#define REC_CDID       6
#define REC_ASIZE     (6)

#define COM_INREC      1
#define COM_SONGNR     2
#define COM_ARTNR      3
#define COM_VERSION    4
// RECNO is used for tracking the text that is searched for ...
#define COM_RECNO      5
#define COM_ASIZE     (5)

#define ALB_ORDNR     1
#define ALB_ALTNR     2
#define ALB_VOLUME    3
#define ALB_YEAR      4
#define ALB_DOP       5
#define ALB_MEDNR     6
#define ALB_GENNR     7
#define ALB_COMNR     8
#define ALB_MULTIART  9
#define ALB_PRIJS    10

#define ALB_NRALBS   11
// Totale duur CD('s)
#define ALB_TOTTIME  12
#define ALB_ASIZE   (12)

// Following items are for reference purposes only
#define ALB_TITLE    13
#define ALB_MEDIA    14
#define ALB_ITEMS    15
#define ALB_GENRE    16
#define ALB_LABEL    17


// Keys :

#define ALB_NEXT     K_RIGHT
#define ALB_PREV     K_LEFT
#define ALB_MENU     K_F4
#define ALB_FIRST    K_CTRL_HOME
#define ALB_LAST     K_CTRL_END

#define REC_NEXT     K_DOWN
#define REC_PREV     K_UP
#define REC_INS      K_INS
#define REC_DEL      K_DEL
#define REC_EDIT     K_ENTER
#define REC_LAST     K_END
#define REC_FIRST    K_HOME
#define REC_PAGEUP   K_PGUP
#define REC_PAGEDOWN K_PGDN

#define EXIT         K_ESC
#define INIT         -1
#define DUMMY        -2

#define Head1   padr("CD NR.",6)+"  "+padr("Titel",30)+" "
#define Head2   " "+padr("Duur",5)

local v := save_keys(), key, i, buffer, action, t, newalb, newrec, item
local cfts, gezocht, nrec

SEARCH_BUFFER := ""

for i := 1 to len(DBF_STRUX)
    if !sysUse(i,.T.)
       // ERROR OPENING FILE
       return
    else

    endif
next

w1 := openwindow(3,RX,10,EX,"Album",DIALOG_TEXT,.T.)
w2 := openwindow(RY-2,RX,maxrow()-2,EX,"Inhoud",DIALOG_LIST)

@maxrow()-2,OPX-14 say "´ Opmerking : "+space(VERSIONLEN)+" Ã"

saykeys("~"+KEY_SEARCH[2]+"~ Zoek ~F3~ Verder ³ ~F4~ Album ³ ~Ins~ Nieuw ~Del~ Wis ~Ù~ Wijzig")

albums->(dbgotop())
t := tBrowseNew(RY,RX+2,maxrow()-3,EX-2)

t:headsep := TB_COLSEP[1]
t:colsep  := TB_COLSEP[2]

t:colorSpec := DIALOG_LIST[1]+","+;
               DIALOG_LIST[5]+","+DIALOG_LIST[4]+;
               ","+DIALOG_SELECT1[1]+","+DIALOG_SELECT1[2] // For 'copy/paste,cut'

c := TBColumnNew(Head1+space(30)+Head2,{||RecRow(buffer, item)})
c:defColor := {2,3}
t:addColumn(c)

t:goBottomBlock := {|| item := len(buffer[COM_DATA])}
t:goTopBlock := {|| item := 1}
t:skipBlock := {|x| changeItem(@item, x, buffer[COM_DATA])}

newalb := .T.
newrec := .T.
item := 1    // Current song-nr. in browsetable

if file(CFTS_NAME(1,1))
   cfts := cfts_open(CFTS_NAME(1,1),16,set(_SET_EXCLUSIVE))
else
   perror("Indexbestanden incompleet. Selecteer ~Onderhoud~ uit het menu;"+;
          "~Bestand~ om deze te genereren.")
   closeWindow(w1)
   closeWindow(w2)
   rest_keys(v)
   return
endif
gezocht := .F.

while .T.
      if newalb
         buffer := get_data()
         if len(buffer[COM_DATA])==0 .and. len(buffer[REC_DATA]) > 0
            // Er iets goed mis ...
            perror("Database inconsistent (~1~).")
            closeWindow(w1)
            closeWindow(w2)
            rest_keys(v)
            return
         else

         endif
         a_show_all(buffer[ALB_DATA])
         a_show_time(buffer[ALB_DATA, ALB_TOTTIME])
         a_show_art(buffer[ALB_DATA])
         t:goTop()
         t:refreshAll()
         newAlb := .F.
      else

      endif
      if Gezocht
         Gezocht := .F.
         item := ascan(buffer[COM_DATA],{|x| x[2,COM_RECNO] == nrec})
      else

      endif
      if newrec
         newRec := .F.
      else

      endif
      while (!t:stabilize())
         action := inkeytrap()
         if (action # 0)
            exit
         else

         endif
      end
      if (t:stable)
         if (t:hitTop .or. t:hitBottom)
            beep()
         else

         endif
         show_version(iif(len(buffer[COM_DATA])>0,buffer[COM_DATA,item,2,COM_VERSION],""),;
                      buffer[ALB_DATA,ALB_MULTIART])
         action := EventWait()
      else
         // action is now filled
      endif
      do case
         case action == KEY_SEARCH[1]
              if (nrec := tekst_zoek(cfts)) # 0
                 newAlb := .T.
                 Gezocht := .T.
              else

              endif
         case action == K_F3
              if (nrec := zoek_volgend(cfts)) # 0
                 newAlb := .T.
                 Gezocht := .T.
              else

              endif
         case action == ALB_MENU
              albumMenu(buffer[ALB_DATA]) // This baby stores new/altered data
              newalb := .T.               // ... so reread it ...
         case action == REC_INS

         case action == REC_DEL

         case action == REC_EDIT
              rec_edit(t:rowPos, @buffer, item)
         case action == REC_PAGEDOWN
              t:pageDown()
         case action == REC_PAGEUP
              t:pageUp()
         case action == REC_LAST
              t:goBottom()
         case action == REC_FIRST
              t:goTop()
         case action == REC_PREV
              t:up()
         case action == REC_NEXT
              t:down()
         case action == ALB_NEXT
              albums->(dbskip(1))
              if albums->(eof())
                 albums->(dbgoTop())
                 newalb := .T.
              else
                 newalb := .T.
              endif
         case action == ALB_PREV
              albums->(dbskip(-1))
              if albums->(bof())
                 albums->(dbgoBottom())
                 newalb := .T.
              else
                 newalb := .T.
              endif
         case action == ALB_FIRST
              albums->(dbgoTop())
              newalb := .T.
         case action == ALB_LAST
              albums->(dbgoBottom())
              newalb := .T.
         case action == EXIT
              exit
        endcase
        
end
close databases
if cfts#0
   cfts_close(cfts)
else

endif
closeWindow(w1)
closeWindow(w2)
rest_keys(v)
return


function RecRow(buffer, item)
local s := space(80), b, r, p, pre, post
pre := post := ""
if len(buffer[REC_DATA])>0
   b := buffer[COM_DATA,item]
   s:=TYPEREC[b[1]]
   s+=song(b[2,COM_SONGNR])
   p := ascan(buffer[REC_DATA],{|x| x[REC_RECNR] == b[2,COM_INREC]})
   if p > 0
      s+=" "+iif(buffer[ALB_DATA,ALB_MULTIART] .or. (b[1]<=MIX_BEG .and. buffer[ALB_DATA,ALB_MULTIART]),artist(b[2,COM_ARTNR]),space(30))
      r := buffer[REC_DATA,p]
      if b[1] <= MIX_BEG
         if buffer[ALB_DATA,ALB_NRALBS] == 1
            pre := "  "
         else
            pre := " "+str(r[REC_DISKNR],1)
         endif
         pre +=" "+str(r[REC_CDID],3)
         post := sec2time(r[REC_TIME])
      else
         pre := "      "
         post := "     "
      endif
   else
      s += " "+artist(b[2,COM_ARTNR])
      perror("Inconsistentie in opslag liederen en componenten.")
      pre := " ? ???"
      post := "??:??"
   endif
else
   return("Geen titels ingevoerd.")
endif
return(pre+" "+s+" "+post)


function changeItem (i,x, b)
local o := i
i += x
if i > 0
   if i <= len(b)
      // ok
      return(x)
   else
      i := len(b)
   endif
else
   i := 1
endif
return(i-o)

function a_show_all(a)
local c := setcolor()
setcolor(DIALOG_TEXT[1])
if (empty(a[ALB_VOLUME]))
   labtext(5,75,"      ","")
   @ 5,75 say space(3)
else
   labtext(5,75,"Volume",a[ALB_VOLUME])
endif
labtext(5,37,"Titel",title(a[ALB_ALTNR]))
labtext(5,10,"Bestel#",a[ALB_ORDNR])
labtext(7,48,"Medium",media(a[ALB_MEDNR])+iif(a[ALB_NRALBS]>1,"("+str(a[ALB_NRALBS],1)+")","   "))
labtext(7,64,"Genre",genre(a[ALB_GENNR]))
labtext(9,08,"Label",company(a[ALB_COMNR]))
labtext(9,41,"Jaar",str(a[ALB_YEAR],4))
labtext(9,54,"Gekocht",dtoc(a[ALB_DOP]))
labtext(9,69,"Prijs",a[ALB_PRIJS])
setcolor(c)
return nil

function a_show_time(t)
labtext(9,29,"Duur",padl(sec2time(t),6))
return

function a_show_art(a)
if a[ALB_MULTIART]
   labtext(7,10,"Artiest",padr(DIVERSEN,30))
else
   records->(occures(a[ALB_ORDNR]))
   composed->(occures(str(records->recnr,7)))
   artists->(occures(composed->artnr))
   labtext(7,10,"Artiest",iif(records->ordnr==a[ALB_ORDNR],artists->name,padr("Onbekend",30)))
endif
return

function get_data
local rec_dat[REC_ASIZE]
local tmp := {{},{},{}}, old_com, i
asize(tmp[ALB_DATA],ALB_ASIZE)

// Haal eerst de data van het album-record op :
tmp[ALB_DATA,ALB_ORDNR]      := albums->ordnr
tmp[ALB_DATA,ALB_ALTNR]      := albums->altnr
tmp[ALB_DATA,ALB_VOLUME]     := albums->volume
tmp[ALB_DATA,ALB_YEAR]       := albums->year
tmp[ALB_DATA,ALB_DOP]        := albums->dop
tmp[ALB_DATA,ALB_MEDNR]      := albums->mednr
tmp[ALB_DATA,ALB_GENNR]      := albums->gennr
tmp[ALB_DATA,ALB_COMNR]      := albums->comnr
tmp[ALB_DATA,ALB_MULTIART]   := albums->multiart
tmp[ALB_DATA,ALB_PRIJS]      := albums->prijs
i := media(albums->mednr) // seek, but value is of no interest to me...
tmp[ALB_DATA,ALB_NRALBS]     := media->items
tmp[ALB_DATA,ALB_TOTTIME]    := 0

records->(dbseek(tmp[ALB_DATA,ALB_ORDNR]))
while records->ordnr == tmp[ALB_DATA,ALB_ORDNR] .and. !eof()
      aadd(tmp[REC_DATA], get_rec())
      tmp[ALB_DATA,ALB_TOTTIME] += tmp[REC_DATA, len(tmp[REC_DATA]), REC_TIME]
      records->(dbskip(1))
end

old_com := 0
if len(tmp[REC_DATA]) > 0
  for i := 1 to len(tmp[REC_DATA])
   composed->(dbseek(str(tmp[REC_DATA,i,REC_RECNR],7)))
   if (tmp[REC_DATA,i,REC_RECNR]#composed->recnr)
      perror("~RECORDS~ bevat een record dat niet gekoppeld is aan ~COMPOSED~.")
   endif

   if tmp[REC_DATA,i,REC_ISAMIX]
      while composed->recnr == tmp[REC_DATA,i,REC_RECNR] .and. !eof()
            aadd(tmp[COM_DATA], {MIX_PART, get_com()})
            composed->(dbskip(1))
      end
      if len(tmp[COM_DATA]) > 1
         tmp[COM_DATA,old_com+1,1] := MIX_BEG
         tmp[COM_DATA,(old_com := len(tmp[COM_DATA])),1] := MIX_END
      else

      endif
   else
      aadd(tmp[COM_DATA], {ONE_REC, get_com()})
   endif
 next
else

endif
return(tmp)

function get_com
local comd[COM_ASIZE]
comd[COM_INREC]   := composed->recnr
comd[COM_SONGNR]  := composed->songnr
comd[COM_ARTNR]   := composed->artnr
comd[COM_VERSION] := composed->version
comd[COM_RECNO]   := composed->(recno())
return (comd)

function get_rec
local recd[REC_ASIZE]
recd[REC_RECNR]      := records->recnr
recd[REC_ISAMIX]     := records->IsAMix
recd[REC_MULTIART]   := records->MultiArt
recd[REC_TIME]       := records->time
recd[REC_DISKNR]     := records->disknr
recd[REC_CDID]       := records->cdid
return (recd)

function show_version(tekst,ma)
@ maxrow()-2,OPX say padr(tekst,VERSIONLEN)
@ RY,41 say iif(ma,padr("Artiest",30),space(30))
return


function rec_edit(y, buffer, item)
local old, p := ascan(buffer[REC_DATA],{|x| x[REC_RECNR] == buffer[COM_DATA,item,2,COM_INREC]})
if p > 0
   old := {buffer[REC_DATA,p],buffer[COM_DATA,item]}

else
   perror ("Geen titels ingevoerd.")
endif
return


function albumMenu(data)
local k
k:=askwindow("Album","",{" ^Wijzigen  ",;
                               " ^Toevoegen ",;
                               "^Verwijderen",;
                               "  ^Zoeken   ",;
                               " ^Annuleren "},5,DIALOG_TEXT,2)

do case
   case k == 1
        alb_wijzig(data)
   case k == 2
        alb_new()
   case k == 3

   case k == 4
        // Album zoeken op TITEL of ORDNR
        k := askwindow("Album : Zoek","Wilt u een album specifiek zoeken op",;
                      {"^Bestelnummer","^Titel","^Annuleren"},3,DIALOG_TEXT,1)
        do case
           case k == 1
                // Zoek Bestelnummer
           case k == 2
                // Zoek Titel
           case k == 3
                // So long ...
        endcase
   case k == 5
        // We're going home...
endcase
return

function alb_new
local adat[ALB_ASIZE], expand := {space(30),space(5),1,space(12),space(15)}
adat[ALB_ORDNR]     := space(20)
adat[ALB_ALTNR]     := 0
adat[ALB_VOLUME]    := space(3)
adat[ALB_YEAR]      := year(date())
adat[ALB_DOP]       := date()
adat[ALB_MEDNR]     := 0
adat[ALB_GENNR]     := 0
adat[ALB_COMNR]     := 0
adat[ALB_MULTIART]  := .F.
adat[ALB_PRIJS]     := 0
adat[ALB_TOTTIME]   := 0
adat := alb_edit(adat, expand)
if adat # NIL
   // Store it ... (and if for example mednr does not exist, we have the
   //               text that goes with it in adat[2] !

else
   // Escaped ...
endif
return

function alb_wijzig(adat)
local k := save_keys()
local expand := {title(adat[ALB_ALTNR]),media(adat[ALB_MEDNR]),adat[ALB_NRALBS],;
                 genre(adat[ALB_GENNR]),company(adat[ALB_COMNR])}
saykeys()
adat := alb_edit(adat,expand)
if adat # NIL
   // Store it ...

else
   // Escaped ...
endif
deactPickList()
rest_keys(k)
return

function alb_edit(adat, expand)
// expand : titel,media,items,genre,label
local olditems := expand[3]
setcolor(DIALOG_TEXT[1])
@ 7,53 say "x  "
labtext(5,75,"Volume","")
setcolor(DIALOG_TEXT[4])
@ 7,10 say space(30)
a_show_time(0)
setcolor(DIALOG_TEXT[4]+","+DIALOG_INPUT[1]+",,,"+DIALOG_INPUT[2])

@ 5,10 get adat[ALB_ORDNR]  picture "@k@!"    ;
           when actAlbFunc(ALB_ORDNR)   valid deActPickList()
@ 5,37 get expand[1]        picture "@k"      ;
           when actAlbFunc(ALB_TITLE)   valid deActPickList()
@ 5,75 get adat[ALB_VOLUME] picture "!!!"     ;
           when actAlbFunc(ALB_VOLUME)  valid deActPickList()
@ 7,48 get expand[2]        picture "@k"      ;
           when actAlbFunc(ALB_MEDIA)   valid deActPickList()
@ 7,54 get expand[3]        picture "9"       ;
           when actAlbFunc(ALB_ITEMS)   valid deActPickList()
@ 7,64 get expand[4]        picture "@k"      ;
           when actAlbFunc(ALB_GENRE)   valid deActPickList()
@ 9,08 get expand[5]        picture "@k"      ;
           when actAlbFunc(ALB_LABEL)   valid deActPickList()
@ 9,41 get adat[ALB_YEAR]   picture "9999"    ;
           when actAlbFunc(ALB_YEAR)    valid deActPickList()
@ 9,54 get adat[ALB_DOP]    picture "@D"      ;
           when actAlbFunc(ALB_DOP)     valid deActPickList()
@ 9,69 get adat[ALB_PRIJS]  picture "9999.99" ;
           when actAlbFunc(ALB_PRIJS)   valid deActPickList()
newRead()
mutkey(.F.) // to be sure ...
if lastkey() == K_ESC
   return NIL
else
   media->(dbseek(albums->mednr))
   adat[ALB_NRALBS] := media->items
endif
return {adat,expand}

function deactPickList()
mutkey(.F.)
saykeys()
return

function actAlbFunc(n)
local pick := 0, topic
do case
   case n == ALB_ORDNR
        pick := 0
        topic := HLP_BESTELNUMMER
   case n == ALB_TITLE
        pick := 8
        topic := HLP_TITEL_ALBUM
   case n == ALB_VOLUME
        pick := 0
        topic := HLP_VOLUME
   case n == ALB_MEDIA
        pick := 6
        topic := HLP_MEDIA
   case n == ALB_ITEMS
        pick := 0
        topic := HLP_AANTAL
   case n == ALB_GENRE
        pick := 7
        topic := HLP_GENRE
   case n == ALB_LABEL
        pick := 9
        topic := HLP_LABEL
   case n == ALB_YEAR
        pick := 0
        topic := HLP_JAAR
   case n == ALB_DOP
        pick := 0
        topic := HLP_DATUM_VAN_AANSCHAF
   case n == ALB_PRIJS
        pick := 0
        topic := HLP_PRIJS
endcase
help_topic(topic)
if pick # 0
   mutkey(.T., pick)
   saykeys("~F2~ Zoek ~F5~ Lijst")
else

endif
return .T.

function mutkey(s,n)
if s
   setkey(K_F2,{||help_layer1(n)})
   setkey(K_F5,{||help_layer1(n,.T.)})
else
   setkey(K_F2,NIL)
   setkey(K_F5,NIL)
endif
return


function help_layer1(n,c)
mutkey(.F.)
if pickList(n,c) # NIL  // An item is chosen

else

endif
mutkey(.T., n)
return
