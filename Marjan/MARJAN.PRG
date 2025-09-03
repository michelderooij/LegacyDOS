*  FILE NAME: P_START.PRG
*  BY: 
*  NOTICE: 
*  DATE: 1/15/92
*  DESC:
*  CALLED BY:
*  DATA FILES:

PUBLIC COLOR [9],adapter,a_a,a_t,new_disk,uid,org_cols,a_c,tmp, ;
   prn_merk,prn_ibmgraf,prn_leftmrg,prn_norm,prn_pagelen,prn_start, ;
   prn_tofile,prn_filename,t,LOGOUT [17], prn_col9, colname[16], ;
   prn_col1,prn_col2,prn_col3,prn_col4,prn_col5,prn_col6,prn_col7,prn_col8

setcancel (.f.)
init_kleuren()
uid ="Marjan v"+SUBSTR(BLISERNUM(),10,5)
t=0
DO p_main

CLOSE ALL
@ 24,0 SAY ""
? uid
? "(c) 1990,1991,1992 M.de Rooy, NL."
?
?"Bedankt voor het gebruiken van Marjan. Mocht u dit programma nuttig vinden,"
?"dan kunt u uw donatie kwijt op het in de file LEESMIJ.DOC vermelde nummer."
?"Serieuze suggesties zijn ook welkom. Deze Marjan is vrij verspreidbaar."
?
?
RETURN 





*Formatted by: dANALYST Gold (Clipper 5.x) V5.0 on 2/16/92 at 1:32 PM.

