*  FILE NAME: p_prnset.PRG
*  BY: 
*  NOTICE: 
*  DATE: 1/15/92
*  DESC:
*  CALLED BY:
*  DATA FILES:
PRIVATE filtre,old_sr,old_co,klaar,_lo,_hi,s,ss
filtre =SPACE(0)
SAVE SCREEN TO old_sr
old_co =setcolor()
setcolor(COLOR [3])
@6,9 TO 19,70
@7,10 CLEAR TO 18,69
@8,12 SAY "                  Configuratie van Marjan :"
@10,12 SAY "þ Regels per pagina            :"GET prn_pagelen PICTURE '99';
   RANGE 40,99
@11,12 SAY "þ Linker marge                 :"GET prn_leftmrg PICTURE '99';
   RANGE 0,99
@12,12 SAY "þ Ongemerkte records afdrukken :"GET prn_merk PICTURE 'A';
   valid prn_merk $"JNjn" .and. !(prn_merk $"nN" .and. prn_norm $"nN")
@13,12 SAY "þ Gemerkte records afdrukken   :"GET prn_norm PICTURE 'A';
   valid prn_norm $"JNjn" .and. !(prn_merk $"nN" .and. prn_norm $"nN")
@14,12 SAY "þ IBM Graphics gebruiken       :"GET prn_ibmgraf PICTURE 'A';
   valid prn_ibmgraf $"JNjn"
@15,12 SAY "þ Startcodes printer           :"GET prn_start
@16,12 SAY "þ Printer uitvoer naar file    :"GET prn_tofile PICTURE 'A';
   valid prn_tofile $"JNjn"
@17,12 SAY "þ Naam file                    :"GET prn_filename PICTURE 'XXXXXXXX.XXX'
SET cursor ON 
SET CONFIRM ON 
READ 
SET CONFIRM OFF 
SET cursor OFF 
prn_start =UPPER(prn_start)
prn_merk =UPPER(prn_merk)
prn_norm =UPPER(prn_norm)
prn_ibmgraf =UPPER(prn_ibmgraf)
prn_tofile =UPPER(prn_tofile)
prn_filename =UPPER(prn_filename)
store_cfg()
IF lastkey()=27
   setcolor (old_co)
   RESTORE SCREEN FROM old_sr
   RETURN 
ENDIF 
setcolor (old_co)
RESTORE SCREEN FROM old_sr
RETURN 





*Formatted by: dANALYST Gold (Clipper 5.x) V5.0 on 2/16/92 at 1:36 PM.

