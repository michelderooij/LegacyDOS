*  FILE NAME: P_ULT3.PRG
*  BY: 
*  NOTICE: 
*  DATE: 2/16/92
*  DESC:
*  CALLED BY:
*  DATA FILES:
PRIVATE _ans, o, os

IF !FILE("nietwis!.up3")
   RETURN
ENDIF

SAVE SCREEN TO os

_ans ="J"
CLEAR TYPEAHEAD
SET cursor ON 
SET CONFIRM OFF 
o=setcolor(COLOR[2])
@ 06,15 CLEAR TO 17,63
@ 06,15       TO 17,63
@ 08,17 SAY "Tijdens de installatie is gebleken dat u een"
@ 09,17 SAY "versie voor 3.00 gebruikte. Om de nieuwe"
@ 10,17 SAY "te gebruiken dient de bestandsstructuur te"
@ 11,17 SAY "worden aangepast. De oude gegevens blijven"
@ 12,17 SAY "bewaard. Wilt u hiermee doorgaan ? " ;
   GET _ans PICTURE "!" valid (_ans $"jnJN")
READ
SET CONFIRM ON 

IF (lastkey() = 27) .OR. (_ans $ "nN")
   SET COLOR TO
   CLEAR
   QUIT
ENDIF

@ 13,17 SAY "Herdefini뎣en structuur               같같같"
@ 14,17 SAY "Cre뎣en database met nieuwe structuur 같같같"
@ 15,17 SAY "Cre뎣en nieuwe indices                같같같"
@ 16,17 SAY "Kopi뎣en records                      같같같"
setcolor(COLOR[7])
@ 13,55 SAY ""
* Store old structure in .dbf file
USE programs
COPY STRUCTURE EXTENDED TO temp1
@ 13,55 SAY "께�"
* Select the file with the new structure
USE temp1
* Add the new field we need
APPEND BLANK
REPLACE field_name WITH "CATNR"
REPLACE field_type WITH "N"
REPLACE field_len  WITH 2
REPLACE field_dec  WITH 0
@ 13,55 SAY "께께께"

@ 14,55 SAY ""
* Create a new .dbf with the new structure
CREATE temp2 FROM temp1
* Select new structure
USE temp2
@ 14,55 SAY "께께께"

@ 15,55 SAY ""
* Create new indices
INDEX ON STR(catnr)+UPPER(name) TO progcat
@ 15,55 SAY "께"
INDEX ON UPPER(name)+disknr TO progname
@ 15,55 SAY "께께"
INDEX ON disknr+STR(catnr)+UPPER(name) TO progdisk
@ 15,55 SAY "께께께"
* Activate these indices
SET INDEX TO progname,progcat,progdisk
* Delete superfluous indexfile
ERASE progarc.ntx

@ 16,55 SAY ""
* Copy records to new structure
APPEND ALL FIELDS name,disknr,merk,disks,arcnr FROM programs
@ 16,55 SAY "께께"
COMMIT
@ 16,55 SAY "께께�"

* Erase old structure, rename the new one as the old one, and erase tempfile
ERASE programs.dbf
RENAME temp2.dbf TO programs.dbf
ERASE temp1.dbf
@ 16,55 SAY "께께께"

ERASE nietwis!.up3 && Remove note-file for signaling 'add col'
setcolor(o)
SET cursor OFF
RESTORE SCREEN FROM os
RETURN
*Formatted by: dANALYST Gold (Clipper 5.x) V5.0 on 2/16/92 at 1:33 PM.

