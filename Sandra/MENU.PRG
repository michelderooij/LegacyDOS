#include "config.ch"
#include "inkey.ch"

#define M_FILE     1
#define M_EDIT     2
#define M_COMPILE  3
#define M_OPTIONS  4
#define M_HELP     5

function mainmenu
private m_x := {01,10,20,30,38,46,57,68}
openwindow(1,0,1,79,"@",MENU)
DO WHILE (level[1] <> 0)
   if ReDo
      clear typeahead
      keyboard chr(13)
   else

   endif
   level[1] := horzMenu(1, {" ^Bestand "," ^Mutaties "," ^Functies "," ^Opties "," ^Help "},;
                        m_x, level[1])
   IF level[1] <> 0
      DO sub_menu
   else

   ENDIF
   if Redo
      exit
   endif
ENDDO
RETURN

PROCEDURE sub_menu
local v
while level[2] # 0
  If Redo
     clear typeahead
     keyboard chr(13)
  endif
  level[3] := 1
  DO CASE
   CASE level[1] == M_FILE
      level[2] := VertMenu(2,m_x[1],{'^Onderhoud','@',;
                                     'Af^drukken','@',;
                                     'DOS ^Sessie','^Afsluiten'},level[2])
        DO CASE
         CASE level[2] = 1
              bonderh()
         CASE level[2] = 2
              bafdruk()
         CASE level[2] = 3
              bdos()
         CASE level[2] = 4
              beinde()
        ENDCASE
   CASE level[1] == M_EDIT
        muteren()
        exit
   CASE level[1] == M_COMPILE
        compile()
        exit
   CASE level[1] == M_OPTIONS
      v := savescreen(2,0,maxrow(),maxcol())
      level[2] := VertMenu(2,m_x[M_OPTIONS],{"+^Printers","+^Kleuren", ;
                           "+Scherm^regels","@",;
                           "?^Audiosignalen "+OnOffState(CONFIG_BEEPER)},;
                           level[2],.F.)
      DO CASE
         CASE level[2] = 1
              optprint()
         CASE level[2] = 2
              optcolor()
         CASE level[2] = 3
              optscrn()
         CASE level[2] = 4
              optsound()
      ENDCASE
      restscreen(2,0,maxrow(),maxcol(),v)
   CASE level[1] == M_HELP
      level[2] := VertMenu(2,m_x[M_HELP],{'^Index','^Toetsen','Over ^Help','@','^Over '+PROGNAME},level[2])
      DO CASE
         CASE level[2] == 1
              index()
         CASE level[2] == 2
              toetsen()
         CASE level[2] == 3
              overhelp()
         CASE level[2] == 4
              about()
      ENDCASE
  ENDCASE
  if Redo
     exit
  endif
end
IF level[2] = 0
   level[2] = 1
ENDIF
RETURN
