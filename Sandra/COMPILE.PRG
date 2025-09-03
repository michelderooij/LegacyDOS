#include "config.ch"
#include "box.ch"
#include "inkey.ch"

#define VIEWMIX        {K_F4,"F4"}
#define CDPROG         {K_F5,"F5"}
#define OPTIMIZE       {K_F6,"F6"}
#define COVER          {K_F7,"F7"}
#define TOGGLEA        ASC("A")
#define TOGGLEB        ASC("B")

#define OPT_TIME       1
#define OPT_PRIO       2

local v := save_video(), action, done, c[9], p, total_time := {0,0}, m := maxrow()-3
local w, nrec := 0, Gezocht, comrec, cfts, next_action
private tagged[2,0], t, lastactive := {"",-1,-1,-1,-1,-1,-1}

SEARCH_BUFFER := ""

for i := 1 to len(DBF_STRUX)
    if !sysUse(i,.T.)
       // ERROR OPENING FILE
       return
    else

    endif
next

openwindow(3,0,maxrow()-7,maxcol(),"Titels",DIALOG_LIST,.T.)
openwindow(maxrow()-5,8,maxrow()-2,69,"Selectie",DIALOG_TEXT)
setcolor(DIALOG_TEXT[1])
@ m,10 say "Kant-A xx titels … xx:xx:xx"
@ m,41 say "Kant-B xx titels … xx:xx:xx"
setcolor(DIALOG_TEXT[2])
@ m,10+5 say "A"
@ m,41+5 say "B"

t := tBrowseDB(5,1,maxrow()-8,maxcol()-1)
t:headsep := TB_COLSEP[1]
t:colsep  := TB_COLSEP[2]
t:colorSpec := DIALOG_LIST[1]+","+;
               DIALOG_LIST[5]+","+DIALOG_LIST[4]+","+DIALOG_SELECT1[1]+","+;
               DIALOG_SELECT1[2]+","+DIALOG_SELECT2[1]+","+DIALOG_SELECT2[2]+","+;
               DIALOG_SELECT3[1]+","+DIALOG_SELECT3[2]

select records
go top

c[2] := TBColumnNew ("Titel",{|| iif(records->IsAMix,""," ")+song(composed->songnr)})
c[3] := TBColumnNew ("Artiest",{|| artist(composed->artnr)})
c[4] := TBColumnNew ("Duur",{|| sec2time(records->time)})
c[5] := TBColumnNew ("Opmerking", {|| composed->version})
c[6] := TBColumnNew ("Album",{|| padr(rtrim(titles->title)+" "+albums->volume,33)})
c[7] := TBColumnNew ("Genre", {|| genre(albums->gennr)})
c[8] := TBColumnNew ("Medium", {|| media(albums->mednr)+iif((media->items)>1,"("+str(media->items,2)+")","    ")})
c[9]:= TBColumnNew ("Label", {|| company(albums->comnr)})
c[1] := TBColumnNew ("CD/NR",{|| setrel(), if(media->items>1,str(records->disknr,1)," ")+" "+str(records->cdid,3)})
for i := 1 to len(c)
    c[i]:colorBlock := {|| tagcol(t)}
    t:addColumn(c[i])
next
t:freeze := 2

if file(CFTS_NAME(1,1))
   cfts := cfts_open(CFTS_NAME(1,1),16,set(_SET_EXCLUSIVE))
else
   perror("Indexbestanden incompleet. Selecteer ~Onderhoud~ uit het menu;"+;
          "~Bestand~ om deze te genereren.")
   rest_video(v)
   return
endif

saykeys("~"+KEY_SEARCH[2]+"~ Zoek ~F3~ Verder ³             ³ ~"+CDPROG[2]+"~ Prog. ~"+OPTIMIZE[2]+"~ Opt. ~"+COVER[2]+"~ Hoes ~A~/~B~ Merk")



Gezocht := .F.
comrec := 0
done := .F.
next_action := 0
while !done
      if next_action == 0
         setcolor(DIALOG_SELECT2[1])
         @ m,17 say str(len(tagged[1]),2)
         @ m,29 say sec2hms(total_time[1])
         setcolor(DIALOG_SELECT1[1])
         @ m,60 say sec2hms(total_time[2])
         @ m,48 say str(len(tagged[2]),2)
         if Gezocht
            Gezocht := .F.
            composed->(dbgoto(nrec))
            if records->IsAMix .and. (composed->volgnr#1)
               // text in mix, show components of mix, and active appropriate row
               comrec := nrec
            else
               // OK, text in rec self (or in title of mix...)
               comrec := 0
               do case
                  case translate(SEARCH_BUFFER)$translate(rtrim(iif(composed->recnr#0,songs->title,padr(MIXTEXT,30))))
                       t:colPos := 2
                  case translate(SEARCH_BUFFER)$translate(rtrim(iif(composed->artnr#0,artists->name,padr(DIVERSEN,30))))
                       t:colPos := 3
                  otherwise
                       t:colPos := 5
               endcase
            endif
            t:refreshAll()
         else
            comrec := 0
         endif
         if comrec==0
            while (!t:stabilize())
              action := inkeytrap()
              if (action # 0 .and. ascan({K_F3,KEY_SEARCH[1]},action)==0)
                 exit
              else

              endif
            end
            if (t:stable)
              if (t:hitTop .or. t:hitBottom)
                 beep()
              else

              endif
              setcolor(DIALOG_LIST[1])
              @ t:nTop+1, t:nLeft  say iif(t:LeftVisible > (t:freeze+1), "",right(t:headSep,1))
              @ t:nTop+1, t:nRight say iif(t:RightVisible < t:colCount,"",right(t:headSep,1))
              highlite(maxrow(),21,iif(!(records->IsAMix),"~  ~         ","~"+VIEWMIX[2]+"~ Kijk Mix"),BACKGR[4],BACKGR[5])
              action := EventWait()
            else
              // action is now filled
            endif
            if isalpha(chr(action))
              action:=nupper(action)
            else

            endif
         else
            action := VIEWMIX[1]
         endif
      else
         action := next_action
         next_action := 0
      endif
      do case
         case action == KEY_SEARCH[1]
              if (nrec := tekst_zoek(cfts)) # 0
                 Gezocht := .T.
              else

              endif
         case action == K_F3
              if (nrec := zoek_volgend(cfts)) # 0
                 Gezocht := .T.
              else

              endif
         case action == VIEWMIX[1] .and. records->IsAMix
              // Kijk Mix
              next_action := ViewMix(comrec)
              t:refreshAll()
         case action == CDPROG[1]
              //
         case action == OPTIMIZE[1]
              // Optimaliseer indeling
         case action == COVER[1]
              // Hoes
         case action == K_PGDN
              t:pageDown()
         case action == K_PGUP
              t:pageUp()
         case action == K_CTRL_PGDN
              t:goBottom()
         case action == K_CTRL_PGUP
              t:goTop()
         case action == K_CTRL_HOME
              t:panhome()
         case action == K_CTRL_END
              t:panend()
         case action == K_HOME
              t:home()
         case action == K_END
              t:end()
         case action == K_RIGHT
              t:right()
         case action == K_LEFT
              t:left()
         case action == K_CTRL_RIGHT
              t:panright()
         case action == K_CTRL_LEFT
              t:panleft()
         case action == K_UP
              t:up()
         case action == K_DOWN
              t:down()
         case action == TOGGLEA .or. action == TOGGLEB
              w := if(action==TOGGLEA,1,2)
              if (p := ascan(tagged[w],records->(recno()))) > 0
                 total_time[w]-=records->time
                 adel(tagged[w],p)
                 asize(tagged[w],len(tagged[w])-1)
                 t:refreshCurrent()
              else
                 if len(tagged[w]) < TAG_LIMIT
                    if ascan(tagged[3-w],records->(recno())) > 0
                       tune(TUNE_RING)
                       if askwindow ("OPGELET","Dit lied is al gemarkeerd;voor "+;
                                    "kant ~"+{"A","B"}[3-w]+"~.",;
                                    {"^Toevoegen","^Annuleren"},1,WARNING)==1
                          aadd(tagged[w],records->(recno()))
                          total_time[w]+=records->time
                      else

                       endif
                    else
                       aadd(tagged[w],records->(recno()))
                       total_time[w]+=records->time
                    endif
                    t:refreshCurrent()
                 else
                    tune(TUNE_LASER)
                    askwindow ("FOUT","Maximum aantal te merken liederen;"+;
                               "bereikt voor kant ~"+{"A","B"}[w]+"~.",{"^OK"},1,ERROR)
                 endif
              endif
         case action == K_ALT_DEL
              tagged := {{},{}}
              total_time := {0,0}
              t:refreshAll()
         case action == K_ESC
              done = .T.
      endcase
end
cfts_close(cfts)
close databases
rest_video(v)
return

function tagcol(t)
local r := records->(recno())
in1 := ascan(tagged[1],r)>0
if ascan(tagged[2],r)>0
   if in1
      return {8,9}
   else
      return {4,5}
   endif
else
   if in1
      return {6,7}
   else
      return {2,3}
   endif
endif
return {2,3}

function sec2hms(s)
local min := int((s%3600)/60), sec := s%60, hour := int(s/3600)
return padl(ltrim(str(hour,2)),2,"0")+":"+padl(ltrim(str(min,2)),2,"0")+":"+padl(ltrim(str(sec,2)),2,"0")

// Sets relations from records outwards ...
function setrel
if lastactive[7] # records->recnr
   lastactive[7] := records->recnr
   composed->(occures(str(records->recnr,7)))
endif
if lastActive[1] == records->ordnr

else
   lastActive[1] := records->ordnr
   albums->(occures(records->ordnr))
endif
if lastActive[4] # albums->altnr
   lastActive[4] := albums->altnr
   titles->(occures(albums->altnr))
endif
if lastActive[5] == albums->mednr
else
   lastActive[5] := albums->mednr
   media->(occures(albums->mednr))
endif
if lastActive[6] == albums->gennr
else
   lastActive[6] := albums->gennr
   genres->(occures(albums->gennr))
endif
return NIL
