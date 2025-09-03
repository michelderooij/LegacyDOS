*  FILE NAME: p_chkfls.PRG
*  BY: 
*  NOTICE: 
*  DATE: 1/15/92
*  DESC:
*  CALLED BY:
*  DATA FILES:
PRIVATE FILE[16],n
FILE[ 2]="programs.dbf"
FILE[ 3]="progname.ntx"
FILE[ 4]="progdisk.ntx"
FILE[ 5]="disknrs.dbf"
FILE[ 6]="disknr.ntx"
FILE[ 7]="typenrs.dbf"
FILE[ 8]="typenr.ntx"
FILE[ 9]="arcnrs.dbf"
FILE[10]="arcnr.ntx"
FILE[11]="helptext.dbf"
FILE[12]="helptext.dbt"
FILE[13]="helpidx.ntx"
FILE[14]="progcat.ntx"
FILE[15]="category.dbf"
FILE[16]="category.ntx"
FOR n =2 TO 16
   IF !FILE(FILE[n])
      errmsg ("File "+FILE[n]+" niet te benaderen.",.F.,"Filecheck")
      SET COLOR TO
      CLEAR
      QUIT 
   ENDIF 
NEXT 
RETURN 





*Formatted by: dANALYST Gold (Clipper 5.x) V5.0 on 2/16/92 at 1:33 PM.

