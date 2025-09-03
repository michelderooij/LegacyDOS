#include "inkey.ch"
#include "config.ch"

// Close a file from the databasesystem

function SysClose(id)
dbSelectAr (DBF_DESCR[iif(valtype(id)=="N",id,val(id))])
dbCloseArea()
return

// Select an open database from the system

function SysSelect(id)
local i := iif(valtype(id)=="N",id,val(id))
select (DBF_DESCR[i])
return

// Use a (NEW) databasesystem file, with optional indices

function SysUse (id,ind)
local idx[15], i, n, d
ind := pdef(ind,.F.)
id := iif(valtype(id)=="N",id,val(id))
n := DBF_NAME(id)
d := DBF_DESCR[id]
if !file(n) .or. !f_isdbf(n)
   tune(TUNE_RING)
   if askwindow("ERROR","Het bestand ~"+n+"~ is niet te benaderen. Wilt u;"+;
                "hiervoor een nieuw (leeg) bestand laten aanmaken ?",{"^Ja","^Nee"},2,ERROR)==1
      dbcreate(CONFIG_DBF_PATH+DBF_DESCR[id],DBF_STRUX[id])
   else
      perror("Databestanden incompleet.")
      return .F.
   endif
endif
dbusearea (.T., , n, d, , )
if ind
   for i := 1 to len(NTX_STRUX[id])
    if !file(NTX_NAME(id,i))
     tune(TUNE_RING)
     perror ("Indexbestanden incompleet. Selecteer ~Onderhoud~ in het submenu;"+;
              "~Bestand~ om de indexen opnieuw te genereren.")
     return .F.
    endif
    dbSetIndex(NTX_NAME(id,i))
  next
endif
return .T.

function DBF_NAME(x)
return (CONFIG_DBF_PATH+DBF_DESCR[x]+".DBF")

function NTX_NAME(x,y)
return(CONFIG_DBF_PATH+"IDX"+NTOC(x,10,2,"0")+NTOC(y,10,2,"00")+".NTX")

function CFTS_NAME(x,y)
return(CONFIG_DBF_PATH+"IDX"+NTOC(x,10,2,"0")+NTOC(y,10,2,"00")+".IAX")

function artist(artnr)
if artnr#0
   artists->(occures(artnr))
   return(artists->name)
else

endif
return padr(DIVERSEN,30)

function song(songnr)
if songnr#0
   songs->(occures(songnr))
   return (songs->title)
else
   return padr(MIXTEXT,30)
endif

function company(comnr)
company->(occures(comnr))
return (company->company)

function title(altnr)
titles->(occures(altnr))
return (titles->title)

function media(mednr)
media->(occures(mednr))
return (media->media)

function genre(gennr)
genres->(occures(gennr))
return (genres->genre)

function cfts_expr
local s := rtrim(song(composed->songnr)), os := select(), oi := records->(indexord())
s+="|"+rtrim(artist(composed->artnr))
records->(dbsetorder(2)) // composed is what we are looking for ...
records->(occures(composed->recnr))
records->(dbsetorder(1))
albums->(dbseek(records->ordnr))
s+="|"+rtrim(composed->version)
dbselectar(os)
return translate(s)

function ViewMix(rec)
local y := maxrow()/2, x := maxcol()/2, h := (maxrow()-18)/2, o := {composed->(recno()),records->(recno())}
local w, v := save_keys(), t, c[3], i, hand, tf, gow, titel, dh, keypend
rec := pdef(rec,0)
saykeys("~"+KEY_SEARCH[2]+"~ Zoek ~F3~ Verder")

tf := create_tmp("DBF")
dbcreate(tf,{{"key","n",10,0}})
dbuseArea(.T., , tf)
dh := select()

select composed
dbseek(str(records->recnr,7))
gow := 1
if composed->recnr==records->recnr
   if composed->songnr#0
      // Skip titel mix...
      titel := rtrim(song(composed->songnr))
      dbskip(1)
   else
      titel := MIXTEXT
   endif
   while composed->recnr == records->recnr .and. !composed->(eof())
      (dh)->(dbappend())
      replace (dh)->key with composed->(recno())
      if rec==composed->(recno())
         gow := (dh)->(recno())
      else

      endif
      composed->(dbskip(1))
   end
else

endif
dbSelectArea(dh)
dbgoto(gow)
composed->(dbgoto((dh)->key))


w := openwindow(y-h-2,x-33,y+h+1,x+32,titel+" ("+sec2time(records->time)+")",DIALOG_LIST)
t := tBrowseDB(y-h,x-31,y+h,x+31)

t:headsep := TB_COLSEP[1]
t:colsep  := TB_COLSEP[2]
t:colorSpec := DIALOG_LIST[1]+","+;
               DIALOG_LIST[5]+","+DIALOG_LIST[4]

c[1] := TBColumnNew("Titel",{|| composed->(dbgoto((dh)->key)), song(composed->songnr)})
c[2] := TBColumnNew("Artiest",{|| artist(composed->artnr)})
c[3] := TBColumnNew("Opmerking",{|| composed->version})

for i := 1 to 3
    c[i]:colorBlock := {|| {2,3}}
    if !(i == 2 .and. !records->multiart)
       t:addColumn(c[i])
    else

    endif
next

if rec#0
   // Set relations for search-match (keypend is used as a dummy...)
   keypend := artist(composed->artnr)
   keypend := song(composed->songnr)
   do case
      case translate(SEARCH_BUFFER)$translate(rtrim(songs->title))
           t:colPos := 1
      case translate(SEARCH_BUFFER)$translate(rtrim(artists->name))
           t:colPos := 2
      otherwise
           t:colPos := 3
   endcase
else

endif

keypend := 0
while .T.
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
         @ t:nTop+1, t:nLeft  say iif(t:LeftVisible > 1, "",right(t:headSep,1))
         @ t:nTop+1, t:nRight say iif(t:RightVisible < t:colCount,"",right(t:headSep,1))
         action := EventWait()
      else
         // action is now filled
      endif
      do case
         case action == K_ESC
              exit
         case action == KEY_SEARCH[1]
              keypend := KEY_SEARCH[1]
              exit
         case action == K_F3
              keypend := K_F3
              exit
         case action == K_UP
              t:up()
         case action == K_DOWN
              t:down()
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
      endcase
end
dbCloseArea()
composed->(dbgoto(o[1]))
records->(dbgoto(o[2]))
select records
closeWindow(w)
erase_tmp(tf)
rest_keys(v)
return (keypend)

function tekst_zoek(cfts)
local y := maxrow()/2, x := maxcol()/2, rec, o := {composed->(recno()),records->(recno())}
local w := openwindow(y-2,x-17,y+1,x+17,"Geef de te zoeken tekst op",DIALOG_TEXT)
SEARCH_BUFFER := padr(SEARCH_BUFFER,30)
setcolor(","+DIALOG_INPUT[1])
@ y,x-15 get SEARCH_BUFFER picture "@k@!"
NewRead()
if lastkey() # K_ESC
   cfts_set(cfts, translate(rtrim(SEARCH_BUFFER)))
   rec := cfts_nxt(cfts)
   composed->(dbgoto(rec))
   while rec # 0
     if cfts_veri(cfts, cfts_expr(""), translate(rtrim(SEARCH_BUFFER)), 4) == 1
        exit
     else
        rec := cfts_nxt(cfts)
        composed->(dbgoto(rec))
     endif
   end
   if rec # 0
      records->(dbsetorder(2))
      records->(dbseek(composed->recnr))
      records->(dbsetorder(1))
      albums->(dbseek(records->ordnr))
   else
      askwindow("Mededeling","De opgegeven tekst kan niet worden gevonden.",{"^OK"},1,WARNING)
      composed->(dbgoto(o[1]))
      records->(dbgoto(o[2]))
   endif
else
   rec := o[1]
   composed->(dbgoto(o[1]))
   records->(dbgoto(o[2]))
endif
closeWindow(w)
SEARCH_BUFFER := rtrim(SEARCH_BUFFER)
return(rec)

function zoek_volgend(cfts)
local rec, t := translate(rtrim(SEARCH_BUFFER)), ex1, old[2]
local o := {composed->(recno()),records->(recno())}
if len(t)==0
   return (tekst_zoek(cfts))
else

endif
old := {records->ordnr, composed->recnr}
rec := cfts_nxt(cfts)
records->(dbsetorder(2))
while rec # 0
   composed->(dbgoto(rec))
   records->(dbseek(composed->recnr))
   albums->(dbseek(records->ordnr))
   // if ... en : niet in de naam van de artiest op een album van alleen die artiest (of mix) :
   if cfts_veri(cfts, cfts_expr(""), t, 4) == 1
      if t$translate(rtrim(artist(composed->artnr)))
         if notsamestruc(old)
            exit
         else
            rec := cfts_nxt(cfts)
         endif
      else
         exit
      endif
   else
      rec := cfts_nxt(cfts)
   endif
end
if rec#0

else
   askwindow("Mededeling","Opgegeven tekst is verder niet aanwezig. ~Verder~ zal;"+;
                          "zal overnieuw beginnen met zoeken.",{"^OK"},1,WARNING)
   // No more records left with searchtext
   composed->(dbgoto(o[1]))
   records->(dbgoto(o[2]))
endif
records->(dbsetorder(1))
return(rec)

function notsamestruc(o)
// Pre-conditie : ZoekTekst staat in de naam van de actuele artiest -> Q:skip ?
if records->IsAMix .and. !records->multiart
   return (o[2] # composed->recnr)
else
   // Check if album met >1 artiest
   if albums->multiart
      return(.T.)
   else
      // Check indien oude album is nieuw gekozen album => skip
      return (o[1] # records->ordnr)
   endif
endif
return(.T.)

function reftab_create(n, e, key)
local c, d := create_tmp(), f, h, iexp
local match, r := (n)->(recno()), io := (n)->(indexord())
(n)->(dbsetorder(0))
dbcreate(d+".DBF",{{"searchkey","n",10,0}})
dbUseArea(.T., , d)
h := select()
//set relation to recno() into &(n)
index on idxset(n,searchkey) to &(d)
e := rtrim(translate(e))
c := cfts_open(CFTS_NAME(n,1),16,set(_SET_EXCLUSIVE))
cfts_set(c,e)
match := cfts_nxt(c)
while match > 0
    if inkey()==K_ESC
       d := ""
       exit
    endif
    (n)->(dbgoto(match))
    if cfts_veri(c,translate(eval({||(n)->&(key)})),e,4) == 1 .or. len(e)==0
       (h)->(dbappend())
       replace (h)->searchKey with match
    else

    endif
    match := cfts_nxt(c)
end
cfts_close(c)
dbSelectArea(h)
dbCloseArea()
(n)->(dbgoto(r))
(n)->(dbsetorder(io))
return(d)

function idxset(n,s)
(n)->(dbgoto(s))
return (n)->&(CFTS_STRUX[n,1])

function create_tmp(ext)
local p
ext := pdef(ext,"")
p := "SWP"+ntoc(random(),16,5,"0")+iif(empty(ext),"","."+ext)
return (p)

function erase_tmp(nam)
if !ferase(nam)
   perror("Kan tijdelijke file ~"+nam+"~ niet verwijderen (ErrCode="+ltrim(str(ferror()))+")")
else

endif
return

function pickList(n, cl)
local h, o := select(), w := NIL, t, m, key := CFTS_STRUX[n,1], retval
local PLDX, PLDY, v := save_keys(), nam, done, y, x, curGet, oGets := gets_save()
local oCur := setcursor(), tGet
cl := pdef(cl,.F.)
setcursor(0)
gets_clear()
sysSelect(n)
PLDX := len((&(key)))
done := .F.
PLDY := maxrow()-20
if (CurGet := GetActive()) # NIL
   if cl
      SEARCH_BUFFER := space(len(&(key)))
   else
      SEARCH_BUFFER := Curget:VarGet()
   endif
   if n # 6

   else
      // Media = media+items
   endif
   x := ideal_pos(CurGet:col,PLDX,maxcol())
   y := ideal_pos(CurGet:row+2,PLDY,maxrow()-1)
else
   SEARCH_BUFFER := space(len(&(key)))
   y := int((maxrow()/2)-(PLDY/2))
   x := int((maxcol()/2)-(PLDX/2))
endif
while !done
   done := .T.
   m := Message("Aan het zoeken ...")
   nam := reftab_create(n, SEARCH_BUFFER, key)
   closeMessage(m)
   if nam==""
      retval := NIL
      exit
   else

   endif
   dbUseArea(.T., , nam)
   dbsetIndex(nam)
   h := select()
   if w # NIL
      // Ai, ongestructureerde rotzooi, maar helaas wel nodig ...
      closeWindow(w)
   else

   endif
   w := openWindow(y-2,x-1,y+PLDY+1,x+PLDX,FIELDNAMES[n],DIALOG_LIST)

   setcolor(DIALOG_LIST[2])
   @ y+PLDY+1,x say "ZOEK:"
   t := tBrowseDB(y,x,y+PLDY,x+PLDX-1)

   setcolor(DIALOG_TEXT[4])
   @ y+PLDY+1,x+5 say padr(SEARCH_BUFFER,PLDX-5)

   t:headsep := ""
   t:colsep  := ""
   t:colorSpec := DIALOG_LIST[1]+","+;
                  DIALOG_LIST[5]+","+DIALOG_LIST[4]
   c := TBColumnNew("",{||(n)->(dbgoto((h)->searchkey)), (n)->&(key)})
   c:defColor := {2,3}
   t:addColumn(c)

   saykeys("~Esc~ Terug ~Ù~ Kies ~"+KEY_SEARCH[2]+"~ Zoek")

      while .T.
         if lastrec() > 0
          while (!t:stabilize())
            if (action := inkeytrap()) # 0
               exit
            else

            endif
          end
          if (t:stable)
            if (t:hitTop .or. t:hitBottom)
               beep()
            else

            endif
            action := EventWait()
          else
            // action is now filled
          endif
         else
          setcolor(DIALOG_LIST[1])
          @ y,x say "Onbekend"
          tune(TUNE_NOTFOUND)
          action := KEY_SEARCH[1]
         endif
         if !isalpha(chr(action)) .and. !isdigit(chr(action))

         else
            keyboard chr(action)
            action := KEY_SEARCH[1]  // Activates Search, key-buff is typed chr
         endif
         do case
            case action == K_PGDN
                 t:pageDown()
            case action == K_PGUP
                 t:pageUp()
            case action == K_END
                 t:goBottom()
            case action == K_HOME
                 t:goTop()
            case action == K_UP
                 t:up()
            case action == K_DOWN
                 t:down()
            case action == KEY_SEARCH[1]
                 setcolor(","+DIALOG_INPUT[1])
                 SEARCH_BUFFER := padr(SEARCH_BUFFER,39)
                 @ y+PLDY+1,x+5 get SEARCH_BUFFER picture '@k@!@s'+ltrim(str(PLDX-5,2))
                 NewRead()
                 SEARCH_BUFFER := rtrim(SEARCH_BUFFER)
                 if lastkey() # K_ESC
                    done := .F.
                    exit
                 else
                    if lastrec()==0
                       done := .T.
                       retval := NIL
                       exit
                    else

                    endif
                 endif
            case action == K_ENTER
                 done := .T.
                 if CurGet#NIL
                    if n # 6
                       CurGet:varPut(eval({||(n)->&(key)}))
                    else
                       // Media : media+items -> 2 GETS !
                       CurGet:varPut(media->media)
                       GetActive():VarPut(media->items)
                    endif
                 else

                 endif
                 retval := (h)->searchkey
                 exit
            case action == K_ESC
                 done := .T.
                 retval := NIL
                 exit
         end
      end
      dbselectarea(h)
      dbclosearea()
      erase_tmp(nam+".DBF")
      erase_tmp(nam+".NTX")
end
closeWindow(w)
rest_keys(v)
dbSelectArea(o)
gets_restore(oGets)
setcursor(oCur)
return (retval)

function ideal_pos(cpos, width, max)
return iif(cpos+width <= max, cpos, max-cpos)
