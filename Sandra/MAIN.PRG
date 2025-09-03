#include "config.ch"

local e
public Redo := .F. // Redo : For Use With New Scr/Col. Func. that sets it, must ALSO reset it !
public DOS_SCREEN[3]
public _SETTINGS_ := {}, _VIDEO_ := _MONO, OLD_MODE, CFG_CHANGED := .F.
public level := {1,1,1}, SEARCH_BUFFER := ""

// *******************************************************************

// Unquote next 2 lines when configuration-structure has to be changed.
// Place these changes between the following lines, et voila ! (or edit config.ch)

//_SETTINGS_ := default_config()
//save_config()

// *******************************************************************

save screen to DOS_SCREEN[1]
DOS_SCREEN[2] := {savecursor(),setcolor(),setblink()}
setcursor(1)
set typeahead to 32
set scoreboard off
set cursor off
set message to
set wrap on
set unique off
set deleted on
set confirm on
SET DATE ITALIAN
SET SCOREBOARD OFF 
SET EPOCH TO 1940
SET DELETED ON 
set exclusive on
set message to maxrow()
set softseek on
SET UNIQUE OFF
if O_GETID() == PROGNAME
   ?
   ? "A copy of "+PROGNAME+" is still in memory."
   ?
   quit
endif
O_SETID(PROGNAME)

// Check if system is still available !

restore_config()

OLD_MODE := getscrmode()
if ISMONO()
   _VIDEO_ := _MONO
endif
if ISCGA()
   _VIDEO_ := _CGA
endif
if ISPGA()
   _VIDEO_ := _PGA
endif
if ISEGA()
   _VIDEO_ := _EGA
endif
if ISVGA()
   _VIDEO_ := _VGA
   //FastPCX("title.bin")
   //inkey(5)
   //txtMode()
else
   // Alternate title-page
endif

e := SetVideoMode(CONFIG_SCREENMODES)
if e == .F.
   setscrmode(OLD_MODE)
else

endif
setblink(.F.)
help_on()
clockOn()
blanktext(" ")

while .T.
  setcolor(",,"+BACKGR[3])
  clearwin(1,0,maxrow()-1,maxcol(),BACKGR[1],iif(_VIDEO_==_MONO,"±"," "))
  setcolor(BACKGR[2])
  @ 0,00 say padr(" "+PROGNAME+" v"+VERSIE,80)
  @ 0,20 say "³ " // +padr(iif(!empty(CONFIG_DBF_PATH),CONFIG_DBF_PATH,"NO SYSTEM ACTIVE"),29)
  @ 0,53 say "³"
  @ 0,69 say "³"
  clearwin(maxrow(),0,maxrow(),79,BACKGR[4]," ")
  clearwin(1,0,1,79,MENU[1]," ")
  mainmenu()
  if ReDo == .F.
     exit
  endif
end
if CFG_CHANGED
   save_config()
else

endif
help_off()
clockOff()
exit(0)
return

function exit(code)
code := pdef(code,0)
setscrmode(OLD_MODE)
border(0)
restore screen from DOS_SCREEN[1]
restcursor(DOS_SCREEN[2,1])
setcolor(DOS_SCREEN[2,2])
setblink(DOS_SCREEN[2,3])
errorlevel(code)
QUIT
return // We'll never reach this line
