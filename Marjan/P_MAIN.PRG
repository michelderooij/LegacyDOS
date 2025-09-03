*  FILE NAME: p_main.PRG
*  BY:
*  NOTICE:
*  DATE: 1/15/92
*  DESC:
*  CALLED BY:
*  DATA FILES:

PRIVATE old_scr,keuze1,y,org_scr,org_row,org_col,h

SET PROCEDURE TO p_func
adapter = 1
adapter =getvideo(0)
setvideo (adapter)

retrieve_cfg()

SET wrap ON 
SET SCOREBOARD OFF 
SET DATE french
SET KEY 28 TO p_help
SET softseek ON 
SET CONFIRM ON 
SET BELL OFF 
SET CENTURY OFF 
SET deleted OFF 
SET EXCLUSIVE ON 

O_SETID(uid+"   (c) 1990,1991,1992 M.de Rooy, NL.                ")
IF (O_GETID(1) = O_GETID(0))
   errmsg("U kunt Marjan maar 1 keer opstarten als programma.",.F., ;
      "Opstarten Marjan")
   RETURN
ENDIF

IF FILE("marjan.tmp")
   errmsg ("Vorige sessie incorrect afgesloten. Bestanden mogelijk beschadigd.",.F., ;
      "Afsluiten Marjan")
ENDIF

SELECT 1
USE programs
SET INDEX TO progname,progdisk,progcat
SET ORDER TO 1

SELECT 2
USE disknrs
SET INDEX TO disknr

SELECT 3
USE typenrs
SET INDEX TO typenr
SET ORDER TO 1

SELECT 4
USE arcnrs
SET INDEX TO arcnr
SET ORDER TO 1

SELECT 5
USE helptext
SET INDEX TO helpidx
SET ORDER TO 1

SELECT 6
USE category
SET INDEX TO category
SET ORDER TO 1

CLEAR TYPEAHEAD 

org_row =ROW()
org_col =COL()
org_cols =setcolor()
SAVE SCREEN TO org_scr

keuze1 =1
setcolor (COLOR [1])
overscan(attr(COLOR [8]))
CLEAR 
FOR y =1 TO 23
   @y,0 SAY REPLICATE("°",80)
NEXT y

DO p_logo

setcolor (COLOR [2])
@24,0 CLEAR TO 24,79
keybar (24,1,"~F1~ Help")
@0,0 CLEAR TO 0,79
@0,(79-LEN(uid)-8)SAY uid+" ³ "

DO p_ult3

DO p_chkfls

mouseon()
h=fcreate("marjan.tmp",0)
fclose(h)
DO WHILE keuze1 <>0
   setcolor (COLOR [2])
   @24,0 CLEAR TO 24,79
   keybar (24,1,"~F1~ Help")
   @0,0 CLEAR TO 0,79
   @0,(79-1-LEN(uid))SAY uid
   SELECT 1
   SET ORDER TO 1
   SET cursor OFF 
   setcolor (COLOR [2])
   @0,02 PROMPT " Info "
   @0,11 PROMPT " Mutatie "
   @0,21 PROMPT " Afdruk "
   @0,30 PROMPT " Opties "
   @0,39 PROMPT " DOS "
   @0,45 PROMPT " Einde "
   MENU TO keuze1
   IF keuze1 <>0
      DO CASE 
      CASE keuze1 =1
         DO p_info
      CASE keuze1 =2
         DO p_muteer
      CASE keuze1 =3
         DO p_afdruk
      CASE keuze1 =4
         DO p_opties
      CASE keuze1 =5
         DO p_dos
      CASE keuze1 =6
         IF sure()
            keuze1 =0
            setcolor(org_cols)
            overscan(0)
            nice_clear()
            RESTORE SCREEN FROM org_scr
            @org_row,org_col SAY ""
         ENDIF 
      ENDCASE 
   ELSE 
      tone (110,1)
      keuze1 =1
      KEYBOARD ("e")
   ENDIF 
ENDDO
mouseoff()
ERASE marjan.tmp
CLEAR TYPEAHEAD
RETURN 



*Formatted by: dANALYST Gold (Clipper 5.x) V5.0 on 2/16/92 at 1:33 PM.

