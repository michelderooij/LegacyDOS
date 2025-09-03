#include "config.ch"
#include "inkey.ch"

local c := {}, id := {}, i, k
if Redo == .T.
   Redo := .F. // New setting in effect ...
else

endif
k := 1
for i := 1 to len(_SETTINGS_[2])
    aadd(id,i)
    aadd(c,"^"+substr(HOTKEYS,k++,1)+". "+_SETTINGS_[2,i,1])
next
if empty(c)
   perror("No saved mode suited for your video-adaptor. Use;~Modify Colors~ to add one for your system.")
   return
endif
if ascan(id,CONFIG_COLORSET)==0 // Previous colorset cannot be set
   level[3] := id[1]
else
   level[3] := CONFIG_COLORSET
endif
level[3] := VertMenu(row(),col(),c,level[3]) // In case of Adaptor-change
if level[3] # 0
   CFG_CHANGED := .T.
   CONFIG_COLORSET := id[level[3]]
   Redo := .T.
   ClockOff()
   ClockOn()
endif
return
