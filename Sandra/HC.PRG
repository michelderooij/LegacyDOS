// Source       : hc.prg
// Author       : M.de Rooy

// Regels die beginnen met een % worden genegeerd. Hiermee kunnen dus
// commentaarregels worden gemaakt.

// .topic ###:Title   : Volledig gebruik van help-historie.
// .screen ###:Title  : Wordt niet in help-historie geplaatst.
// .word ###:Title    : Wordt niet in help-historie geplaatst, waarna
//                      het vorige hoofdstuk wordt getoond. U wordt aangeraden
//                      deze teksten niet direct aan te laten roepen.
//
// N.B. : De nummers in bovenstaande topic/screen/word is niet per groep.
//        Dus ".topic 2000" ‚n ".word 2000" MAG NIET !

// De volgende functies zijn mogelijk in de tekst van een hoofdstuk :
//    ` Regel rechts uitlijnen (Standaard links)
//    ^ Centreren regel
//

// De volgende macro's kunnen in de tekst van een hoofdstuk worden geplaatst,
// waarna de genoemde tekst ervoor in de plaats wordt gezet (door #define) :
// @PROGRAM             Naam van het programma          (PROGNAME)
// @VERSION             Versie van het programma        (VERSIE)
// @AUTHOR              Maker(s) van het programma      (AUTHOR)
// @SERIAL              Serienummer van kopie           (left(BLISERNUM(),8))
// @OWNER               Licentiehouder kopie            (substr(BLISERNUM(),9))
// @COPYRYEARS          Copyright (c) 1992,1993 e.d.    COPYRIGHTYEARS
// @COPYROWNER          Houder van copyright (bedrijf)  COPYRIGHTOWNER

#include "hc.ch"

#define EOLN  (chr(13)+chr(10))

#define HELP_HEADER     padr("Clipper Help-Compiler, "+;
                              "by M.de Rooy, "+;
                              "(c) 1992,1993 ....",128)

#define HELPSOURCE      "HELP.TXT"
#define WORKFILE        "HELP.TMP"
#define INDEXFILE       "HELP.IDX"
#define LISTFILE        "HELP.ME"
#define HEADERFILE      "HELP.CH"

local src, hlp := fcreate(HELPFILE,0)
local topics[0], t, il, ll, lc, ip, idf, lt, ln

public lread

set date to french
cls

? "Clipper Help-Compiler v0.01"
? "by M.de Rooy, (c) 1992,1993 ???"
?
? "Compiling help-source "+HELPSOURCE+" to "+HELPFILE+" ..."
?

? "Creating workfile from original help-file ..."
filedelete(WORKFILE)
filecopy(HELPSOURCE,WORKFILE)
?? "ok"

src := fopen(WORKFILE,0)

? "Searching for topics ... "
topics := gettopic(src, topics)
?? "found "+ltrim(str(len(topics)))


? "Checking for doubles ... "
if len(topics) > 1
   for t := 1 to len(topics)-1
       if topics[t,1]==topics[t+1,1]
          ? "ERRROR, multiple topic declared : "+ltrim(str(topics[t,1]))
          tone(440,4)
          quit
       else

       endif
   next
else

endif
?? "ok"

? "Sorting topics (Title)... "
asort(topics,,,{|x,y| upper(x[2]) < upper(y[2])})
?? "ok"

? "Writing Listfile "+LISTFILE+" ... "
idf := fcreate(LISTFILE)
fwrite(idf,padr("Number",12)+padr("Title",32)+padr("Type",5)+padr("Line",12)+padr("#Lines",7)+EOLN)
aeval(topics,{|x| fwrite(idf,str(x[1],10)+"³ "+padr(x[2],30)+"³ "+str(x[3],3)+"³ "+str(x[7],10)+"³ "+str(x[5],7)+EOLN)})
fclose(idf)
?? "ok"

? "Creating headerfile "+HEADERFILE+" ... "
idf := fcreate(HEADERFILE)
fwrite(idf,"// Header : HELP TOPICS"+EOLN)
fwrite(idf,"// Author : "+rtrim(HELP_HEADER)+EOLN)
fwrite(idf,"// Date   : "+DTOC(DATE())+EOLN)
fwrite(idf,EOLN)
fwrite(idf,"// #Include this file into your sources ... "+EOLN)
fwrite(idf,EOLN)
fwrite(idf,"// "+space(5)+padr("Hoofdstuk",30)+padl("Nummer",10)+EOLN)
fwrite(idf,EOLN)
lt := ""
ln := 1
if len(topics) > 0
   for t := 1 to len(topics)
       fwrite(idf,"#define HLP_")
       if lt == upper(topics[t,2])
          ln++
          fwrite(idf,upper(padr(lt+ltrim(str(ln)),30)))
       else
          ln := 1
          lt := rangerem(0,47,strtran(upper(topics[t,2])," ","_"))
          lt := rangerem(58,63,lt)
          lt := rangerem(91,94,lt)
          lt := rangerem(96,255,lt)
          while atnum("__",lt) > 0
                lt := strtran(lt,"__","_")
          end
          fwrite(idf,padr(lt,30))
       endif
       fwrite(idf,str(topics[t,1],10)+EOLN)
   next
else

endif
fclose(idf)
?? "ok"

? "Creating index ... "
idf := fcreate(INDEXFILE)
ll := chr(0)
fseek(src,0,2)
fwrite(src,EOLN)
il := 0
if len(topics) > 0
   for t := 1 to len(topics)
     if topics[t,3] == 1  // Only Topics are allowed
        if (lc := upper(left(topics[t,2],1))) # ll
          ll := lc
          fwrite(idf," "+EOLN)
          fwrite(idf," "+ll+EOLN)
          fwrite(idf," "+EOLN)
          il+=3
       else
       endif
       fwrite(idf," "+HELPREFCHAR[1]+ltrim(str(topics[t,1]))+HELPREFCHAR[2]+EOLN)
       il++
     else

     endif
   next
else

endif
ip := ftell(src)
fclose(src)
fclose(idf)
fileappend(INDEXFILE,WORKFILE)
filedelete(INDEXFILE)
src := fopen(WORKFILE)
aadd(topics,{INDEX_TOPIC,"Index",1,ip,il,0})
?? "ok"

? "Sorting topics (Number)... "
asort(topics,,,{|x,y| x[1] < y[1]})
?? "ok"

? "Constructing helpfile ..."
makehelp(src,hlp,@topics)
?? "ok"

? "Deleting workfile..."
filedelete(WORKFILE)
?? "ok"

fclose(src)
fclose(hlp)
return

function gettopic (src, topics)
local nr, topnr[2], line, pos, title, lines := 0
// Zoek alle TOPICs
nr := 0
lread := 0
ftop(src)
while !feof(src)
      lines++
      line := ffreadline(src)
      if upper(left(line,len(HELPTOPIC)))==HELPTOPIC

        // Text is a topic

        if (topnr[2] := at(HELPSEPERATOR,line)) > 0
           topnr[1] := val(substr(line,len(HELPTOPIC)+1))
           title := substr(line,topnr[2]+1)
        else
           ? "Error : no title defined in "+line
           tone(440,4)
           quit
        endif
        pos := ftell(src)
        aadd(topics,{topnr[1],title,1,pos,0,0,lread})
        if topnr[1]==INDEX_TOPIC
           ? "Error : Topic 9999 is an internal reserved number"
           tone(440,4)
           quit
        endif
        if len(topics) > 1
           topics[len(topics)-1,5] := lines-1
        endif
        lines := 0
        nr++
      else
        if upper(left(line,len(HELPWORD)))==HELPWORD

           // Text is a word-topic

           if (topnr[2] := at(HELPSEPERATOR,line)) > 0
             topnr[1] := val(substr(line,len(HELPWORD)+1))
             title := substr(line,topnr[2]+1)
           else
             ? "Error : no title defined in "+line
             tone(440,4)
             quit
          endif
          pos := ftell(src)
          aadd(topics,{topnr[1],title,2,pos,0,0,lread})
          if topnr[1]==INDEX_TOPIC
             ? "Error : Topic 9999 is an internal reserved number"
             tone(440,4)
             quit
          endif

          if len(topics) > 1
             topics[len(topics)-1,5] := lines-1
          endif
          lines := 0
          nr++
        else
                if upper(left(line,len(HELPSCREEN)))==HELPSCREEN

                   // Text is a screen -> not pushed on help-stack

                   if (topnr[2] := at(HELPSEPERATOR,line)) > 0
                     topnr[1] := val(substr(line,len(HELPSCREEN)+1))
                     title := substr(line,topnr[2]+1)
                  else
                     ? "Error : no title defined in "+line
                     tone(440,4)
                     quit
                  endif
                  pos := ftell(src)
                  aadd(topics,{topnr[1],title,3,pos,0,0,lread})
                  if topnr[1]==INDEX_TOPIC
                     ? "Error : Topic 9999 is an internal reserved number"
                     tone(440,4)
                     quit
                  endif
                  if len(topics) > 1
                     topics[len(topics)-1,5] := lines-1
                  endif
                  lines := 0
                  nr++
                else

                endif

        endif
      endif
end
if len(topics) > 0
   topics[len(topics),5] := lines
endif
return (topics)

function makehelp(src,hlp,topics)
local t, l
create_header(src,hlp,topics)
for t := 1 to len(topics)
    process_topic(src,hlp,@topics,t)
next
adjust_header(hlp,topics)
return

function adjust_header(hlp,topics)
local t
help_top(hlp)
// Nr. of topics
fwritelong(hlp,len(topics))
// write each topic-Nr., followed by the offset in the help-file
for t := 1 to len(topics)
    fwritelong(hlp,topics[t,1])
    fwritelong(hlp,topics[t,6])
next
return

function create_header(src,hlp,topics) // Make dummy header
local t
ftop(hlp)
fwrite(hlp,HELP_HEADER)
help_top(hlp)
fwritelong(hlp,0)
for t := 1 to len(topics)
    fwritelong(hlp,0)
    fwritelong(hlp,0)
next
return

function process_topic(src,hlp,topics,n)
local l, ref[0], pos[3], line, cut, tekst[0], kenm[2], instext

// Store offset-position where topic-info begins for later storage in header !
topics[n,6] := ftell(hlp)

// Write type of topic [TOPIC|WORD|SCREEN]
fwritebyte(hlp,topics[n,3])
// Write title of topic
ffwrite(hlp,topics[n,2])

if topics[n,5] > 0
   fseek(src,topics[n,4],0)
   for l := 1 to topics[n,5]
       line := ffreadline(src)
       // ? line
       // Process each line
       pos[1] := at(HELPREFCHAR[1],line)
       pos[2] := at(HELPREFCHAR[2],line)
       // Replace References
       while pos[1]*pos[2] > 0 .and. pos[2] > pos[1]
             cut := substr(line,pos[1]+1,pos[2]-pos[1]-1)
             if (pos[3] := at(HELPSEPERATOR,cut)) > 0
                kenm[1] := val(left(cut,pos[3]-1))
                instext := substr(cut,pos[3]+1)
                kenm[2] := len(instext)
             else
                kenm[1] := val(cut)
                kenm[2] := 0
                instext := ""
             endif
             aadd(ref,{kenm[1],l,pos[1],kenm[2]})
             if ascan(topics,{|x| x[1]==ref[len(ref),1]}) > 0
                // ok
             else
                ? "Reference to a non-existing topic : "+ltrim(str(ref[len(ref),1]))
                tone(440,4)
                quit
             endif
             line := stuff(line,pos[1],pos[2]-pos[1]+1,instext)
             pos[1] := at(HELPREFCHAR[1],line)
             pos[2] := at(HELPREFCHAR[2],line)
       end
       aadd(tekst,line)
   next
   // Write references and their attributes
   fwritelong(hlp,len(ref))
   if len(ref) > 0
      for l := 1 to len(ref)
          fwritelong(hlp,ref[l,1]) // topic
          fwriteint(hlp,ref[l,2])  // line
          fwriteint(hlp,ref[l,3])  // kolom
          fwriteint(hlp,ref[l,4])  // length of "alias" (==0 -> topic-title!)
      next
   else

   endif
   // write contents ...
   fwritelong(hlp,len(tekst))
   if len(tekst) > 0
      for l := 1 to len(tekst)
          process_line(hlp,tekst[l])
      next
   else

   endif
else

endif
return

function process_line (hlp,t)
local lc := left(t,1), attr := 0
if !empty(lc)
   do case
      case lc == CENTER[1]
           t := substr(t,2)
           attr := CENTER[2]
      case lc == RJUST[1]
           t := substr(t,2)
           attr := RJUST[2]
   endcase
else

endif
fwritebyte(hlp,attr)
ffwrite(hlp,t)
return

function help_top(hlp)
fseek(hlp,HELPTOP,0)
return

function ffwrite(h,t)
fwriteint(h,len(t))
fwrite(h,ENFUNTEXT(t))
return

function ffreadline(h,a)
local l := freadline(h)
lread++
while left(l,1) == HELPIGNORE .and. !feof(h)
      l := freadline(h)
      lread++
end
return (l)
