#include "config.ch"

local t, i := 1, choices := {}, pid := {}, n := 1
use printers new
if printers->(lastrec()) > 0
   while !eof() .and. (len(choices) < 10)
         aadd(choices,str(printers->id,4)+printers->name)
         skip
   end
endif
close printers
asort(choices,,,{|x,y| substr(x,5)<substr(y,5)})
for i := 1 to len(choices)
    aadd(pid,val(left(choices[i],4)))
    choices[i] := "^"+substr(HOTKEYS,i,1)+". "+substr(choices[i],5)
next
aadd(choices,"^F. Output to file")
aadd(pid,0)
level[3] := ascan(pid,CONFIG_PRINTER)
level[3] := VertMenu(row(),col(),choices,level[3])
if level[3] # 0
   CFG_CHANGED := .T.
   CONFIG_PRINTER := pid[level[3]]
endif
return
