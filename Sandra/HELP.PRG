// Source       : help (module+routines)
// Author       : M.de Rooy
// Note         : Gebruikt kleurendefinities uit config.ch (HELP[x]) (zie defines),
//                en routines uit FUNCKY 1.5 en NTools 2.50 !

// HELP-SYSTEM (program module)

#include "hc.ch"
#include "inkey.ch"
#include "config.ch"

#define COL_TEKST       HELP[1]
#define COL_HIGH        HELP[2]
#define COL_TITLE       HELP[3]
#define COL_INAREF      HELP[4]
#define COL_ACTREF      HELP[5]

#define WIDTH           50
#define HEIGHT          (maxrow()-12)
#define HX              (maxcol()/2-WIDTH/2)
#define HY              (maxrow()/2-HEIGHT/2)

#define HISTSIZE        16

#define SETTOPIC         1
#define PUSHTOPIC        2
#define POPTOPIC         3
#define ALTER_INFO       4
#define GETACTIVETOPIC   5

#define TYPE  1
#define REF   2
#define TEKST 3
#define TITLE 4
#define ATTR  5
#define TOPIC 6

#define PREVTOPIC  {"F5",K_F5}
#define INDXTOPIC  {"F6",K_F6}
#define ONHELP     {"F7",K_F7}

static function expMacro(t)
if at("@",t) > 0
   t := strtran(t,"@PROGRAM",PROGNAME)
   t := strtran(t,"@VERSION",VERSIE)
   t := strtran(t,"@AUTHOR",AUTHOR)
   t := strtran(t,"@SERIAL",left(BLISERNUM(),8))
   t := strtran(t,"@OWNER",substr(BLISERNUM(),9))
   t := strtran(t,"@COPYRYEARS",COPYRIGHTYEARS)
   t := strtran(t,"@COPYROWNER",COPYRIGHTOWNER)
else

endif
return(t)

function help_on
set key K_F1 to HELP_DRIVER
return .T.

function help_off
set key K_F1 to
return .T.

function help_topic(t)
help_driver(,,,1,t,procname(1),procline(1))
return .T.

function HELP_DRIVER(procn, procl, rvar, cmd, var1,var2,var3)
static HELP_Active := {INDEX_TOPIC,1,1,"HELP_DRIVER",1}, Help_History[HISTSIZE]
local hwin, done := .F., ncmd, rval := 0
help_off()
if cmd == NIL
   hwin := save_video()
   openwindow(HY,HX,HY+HEIGHT,HX+WIDTH,"Help",{COL_TEKST,COL_HIGH,COL_TITLE})
   saykeys("~Esc~ Einde Help ~"+ONHELP[1]+"~ Over Help ~"+PREVTOPIC[1]+"~ Onderwerp terug ~"+INDXTOPIC[1]+"~ Index")
else
endif
while !done
 done := .T.
 do case
   case cmd == NIL
        // Help called

        if (ncmd := show_help(Help_Active,HY+2,HX+1,HEIGHT-2,WIDTH-2)) >= 0
           // ok
           do case
              case ncmd == 1  // Refer
                   done := .F.
              case ncmd == 2 // Pop & End
                   help_driver(,,,POPTOPIC)
              case ncmd == 3 // Pop & Show prev.topic
                   help_driver(,,,POPTOPIC)
                   done := .F.
              otherwise
                   // Die in Peace
           endcase
        else
           // active topic not found or inaccessible
           // -1 = cannot open help-file
           // -2 = topic not found
           do case
              case ncmd == -1
                   askwindow("FOUT","Kan helpfile niet openen.",{"OK"},1,ERROR)
              case ncmd == -2
                   askwindow("FOUT","Kan hoofdstuk "+ltrim(str(Help_Active[1]))+" niet vinden.",;
                             {"OK"},1,ERROR)

           endcase
        endif
   case cmd == ALTER_INFO
        Help_Active[2] := var1
        Help_Active[3] := var2
   case cmd == SETTOPIC
        HELP_driver(,,,PUSHTOPIC)
        Help_Active := {var1,1,1,var2,var3}
   case cmd == POPTOPIC
        if HELP_History[1] # NIL // Not an empty stack
           Help_Active := HELP_History[1]
           ADEL(HELP_History,1)
        else
           HELP_Active := {INDEX_TOPIC,1,1,procname(),procline()}
        endif
   case cmd == PUSHTOPIC
        AINS(HELP_History,1)
        Help_History[1] := HELP_Active
   case cmd == GETACTIVETOPIC
        rval := Help_Active[1]
  endcase
end
if cmd == NIL
   rest_video(hwin)
else

endif
help_on()
return (rval)

static function locate_topic(h,t)
local topic,ofs := 0,piv, found := .F., bot := 1
fseek(h,HELPTOP,0)
top := freadlong(h)
while !found .and. top >= bot
   piv := int((bot+top)/2)
   fseek(h,HELPTOP-4+(piv*8),0)
   topic := freadlong(h)
   ofs := freadlong(h)
   if t # topic
      if t < topic
         top := piv - 1
      else
         bot := piv + 1
      endif
   else
      found := .T.
   endif
end
return (ofs)

function ffread(h)
local l, s
l := freadint(h)
s := space(l)
fread(h,@s,l)
s := DEFUNTEXT(s)
return(s)

static function get_topic(h, pos)
local type, title, nref, ref[0], i, top, line, kol, alen, ;
      tty, tti, nlines, tekst[0], fp, j, attr[0]
fseek(h,pos,0)
type := freadbyte(h)
title := ffread(h)
nref := freadlong(h)
if nref > 0
   // Process (read) references
   for i := 1 to nref
       top := freadlong(h)
       line := freadint(h)
       kol := freadint(h)
       alen := freadint(h)
       fp := ftell(h)
       // Use topic's title as ref.
       if (pos := locate_topic(h,top)) > 0
          // ok
          fseek(h,pos,0)
          tty := freadbyte(h)
          if alen == 0
             tti := ffread(h)
          else
             tti := ""
          endif
       else
          // cannot locate topic
          return{}
       endif
       fseek(h,fp,0)
       aadd(ref,{top,line,kol,alen,tty,tti})
   next
else

endif
tekst := {" "+title+" Ü"," "+replicate("ß",len(title)+2)}
attr := {0,0}
// Now we come to the text ...
nlines := freadlong(h)
if nlines > 0
   for i := 1 to nlines
       aadd(attr,freadbyte(h))
       line := ffread(h)
       // Replace (if necessary)
       if nref > 0
          for j := 1 to nref
              if ref[j,2] == i
                 if ref[j,4] > 0
                    // Alias in FX
                    // Get ref-description from line into ref-table
                    ref[j,6] := substr(line,ref[j,3],ref[j,4])
                 else
                    // ref[j,6] is filled -> put in line and kill
                    line := stuff(line,ref[j,3],0,ref[j,6])
                    // Replace "alen" with length of alias in line
                    ref[j,4] := len(ref[j,6])
                    ref[j,6] := space(0)
                 endif
              else

              endif
          next
       else

       endif
       aadd(tekst,expMacro(line))
   next
else

endif

// increase lines where references live with the size of the title-banner (3)
for j := 1 to nref
    ref[j,2]+=2
next
return {type, ref, tekst,title, attr}


static function show_help(actHelp,y,x,wy,wx)
// (y,x) is used as an offset, so we can easily convert this help-routine
// to non-relative coordinates (i.e. non-NT250 window-routines)
local h, i, pos, topline := actHelp[2], botline, actref := actHelp[3], oC := setcursor()
local info, rval, topic := actHelp[1], rr, refb[2], doAll := .F., showRef, oldc
if (h := fopen(HELPFILE,0)) # -1
   // ok
else
   // cannot open help-file
   return (-1)
endif
if (pos := locate_topic(h,topic)) > 0
   // ok
else
   // cannot locate topic
   fclose(h)
   return (-2)
endif
if empty(info := get_topic(h, pos))
   fclose(h)
   return (-2)
else

endif
setcursor(0)
actref := iif(len(info[REF])>0,actref,0)
doAll := .T.
showRef := .T.
while .T.
      if doAll .or. showRef
         if doAll
            botline := draw_help(info,topline,y,x,wy,wx,actref)
         else

         endif
         if showRef .or. doAll
            refb := getBounds(info[REF],topline,botline)
            ref_showAll(info[REF],info[ATTR],refb,topline,y,x,wx,actRef)
            showRef := .F.
            doAll := .F.
         else
         endif
      else

      endif
      key := eventWait()
      do case
         case key == INDXTOPIC[2] .and. topic # INDEX_TOPIC
              help_driver(,,,ALTER_INFO,topline,actref)
              help_topic(INDEX_TOPIC)
              rval := 1
              exit
         case key == PREVTOPIC[2]
              rval := 3
              exit
         case key == ONHELP[2] .and. topic # HELP_TOPIC
              help_driver(,,,ALTER_INFO,topline,actref)
              help_topic(HELP_TOPIC)
              rval := 1
              exit
         case key == K_PGDN
              if botline < len(info[TEKST])
                 if len(info[TEKST]) > wy
                    // More lines than window shows
                    if (botline+wy) < len(info[TEKST])
                       topline+=wy
                    else
                       topline := len(info[TEKST])-wy+1
                       actref := iif(len(info[REF]) > 0, len(info[REF]), 0)
                    endif
                    doAll := .T.
                    if refb[1] # 0 .and. refb[1] < len(info[REF])
                       actref := refb[2]+1
                    else
                    endif
                 else

                 endif
              else

              endif
         case key == K_PGUP
              if topline > 1
                 if len(info[TEKST]) > wy
                    // More lines than window shows
                    if (topline-wy) > 0
                       topline-=wy
                    else
                       topline := 1
                       actref := iif(len(info[REF]) > 0, 1, 0)
                    endif
                    doAll := .T.
                    if refb[1] > 1
                       actref := refb[1]-1
                    else
                    endif
                 else

                 endif
              else

              endif
         case key == K_END
              if botline < len(info[TEKST])
                 topline := len(info[TEKST])-wy+1
                 actref := iif(len(info[REF]) > 0, len(info[REF]), 0)
                 doAll := .T.
              else

              endif
         case key == K_HOME
              if topline > 1
                 topline := 1
                 actref := iif(len(info[REF]) > 0, 1, 0)
                 doAll := .T.
              else

              endif
         case (key == K_UP .or. key == K_SH_TAB)
              if actref # 0 .and. actref # refb[1]
                 actref--
                 showRef := .T.
              else
                if topline > 1
                 topline--
                 botline--
                 scroll(y,x,y+wy-1,x+wx,-1)
                 showline(y,x,wx,info[ATTR,topline],info[TEKST,topline])
                 oldc := refb[1]
                 refb := getBounds(info[REF],topline,botline)
                 if refb[1] > 0
                    if oldc == refb[1]

                    else
                       // Reference appeared in sight
                       actref := refb[1]
                       showRef := .T.
                    endif
                 else
                    // No visible ref.
                 endif
                 if actref # 0
                   if info[REF,actref,2] > botline
                    // Act.Reference out of sight - alter...
                    actref := refb[1]
                    ShowRef := .T.
                   else

                   endif
                 endif
                else
                 // bof
                endif
              endif
         case (key == K_DOWN .or. key == K_TAB)
              if actref # 0 .and. actref # refb[2]
                 actref++
                 showRef := .T.
              else
                if botline < len(info[TEKST])
                 topline++
                 botline++
                 scroll(y,x,y+wy-1,x+wx,1)
                 showline(y+(botline-topline),x,wx,info[ATTR,botline],info[TEKST,botline])
                 oldc := refb[2]
                 refb := getBounds(info[REF],topline,botline)
                 if refb[1] > 0
                    if oldc == refb[2]

                    else
                       // Reference appeared in sight
                       actref := refb[2]
                       showRef := .T.
                    endif
                 else
                    // No visible ref.
                 endif
                 if actref # 0
                   if info[REF,actref,2] < topline
                    // Act.Reference out of sight - alter...
                    showRef := .T.
                   else

                   endif
                 endif
                else
                 // eof
                endif
              endif
         case key == K_ENTER .and. actref#0
              help_driver(,,,ALTER_INFO,topline,actref)
              help_topic(info[REF,actref,1])
              rval := 1
              exit
         case key == K_ESC
              do case
                 case info[TYPE] == 1 // topic
                      rval := 0
                 case info[TYPE] == 2 // word
                      rval := 3
                 case info[TYPE] == 3 // screen
                      rval := 2
              endcase
              help_driver(,,,ALTER_INFO,topline,actref)
              exit
      endcase
end
setcursor(oC)
return(rval)

static function draw_help(info, top, y, x, wy, wx, actref)
local bot, l := 0, n
clearwin(y,x,y+wy-1,x+wx,COL_TEKST," ")
// Draw tekst
while (top+l) <= len(info[TEKST]) .AND. (l < wy)
      n := top+l
      showline(y+l,x,wx,info[ATTR,n],info[TEKST,n])
      l++
end
bot := top+l-1
return (bot)

static function showline(y,x,wx,attr,tekst)
do case
   case numand(attr,CENTER[2]) # 0
        highlite(y,x,tekst,COL_TEKST,COL_HIGH,,1)
   case numand(attr,RJUST[2]) # 0
        highlite(y,x,tekst,COL_TEKST,COL_HIGH,,2)
   otherwise
        highlite(y,x,tekst,COL_TEKST,COL_HIGH,,0)
endcase
return

static function getBounds(ref,topline,botline)
local i := 1, rv[2], lr := len(ref)
if lr > 0
   i := ascan(ref,{|x| x[2] >= topline})
   if i > 0
      // Visible
      rv[1] := i
      i := lr
      while ref[i,2] > botline
            i--
      end
      rv[2] := i
   else
      // Invisible, or non-existing ...
      rv := {0,0}
   endif
else
   rv := {0,0}
endif
return (rv)

static function ref_showAll(ref,attr,refb,topline,y,x,wx,actRef)
local i
if len(ref) > 0 .and. refb[1] # 0
   for i := refb[1] to refb[2]
       ref_Show(ref[i],attr[i],(ref[i,2]-topline)+y,x,wx,(actRef==i))
   next
else

endif
return

static function ref_Show(ref,attr,y,x,wx,isAct)
local ofs := x + ref[3]-1
colorwin(y,ofs,y,ofs+ref[4]-1,iif(isAct,HELP[5],HELP[4]))
return

