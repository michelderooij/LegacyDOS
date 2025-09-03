#include "config.ch"
#include "inkey.ch"

local lca[0], e
if Redo
   // New setting is in effect
   Redo := .F.
else

endif
for e := 1 to len(SCREENMODES)
    if SCREENMODES[e,1] <= _VIDEO_
       aadd(lca,SCREENMODES[e,2])
    else
       // Adaptor not suited
    endif
next
if CONFIG_SCREENMODES > len(lca)
   CONFIG_SCREENMODES := len(lca)
endif
level[3] := VertMenu(row(),col(),lca,CONFIG_SCREENMODES)
if level[3] # 0
   m := GETSCRMODE()
   e := setvideomode(level[3])
   if e == .T.
      CFG_CHANGED := .T.
      CONFIG_SCREENMODES := level[3]
      Redo := .T.
   else
      setscrmode(m)
   endif
endif
return
