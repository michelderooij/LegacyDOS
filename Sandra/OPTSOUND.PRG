#include "config.ch"
CONFIG_BEEPER := !CONFIG_BEEPER
if CONFIG_BEEPER
   CFG_CHANGED := .T.
   beep()
endif
return
