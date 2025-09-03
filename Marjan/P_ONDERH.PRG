*  FILE NAME: p_onderh.PRG
*  BY: 
*  NOTICE: 
*  DATE: 1/15/92
*  DESC:
*  CALLED BY:
*  DATA FILES:
PRIVATE old_col,_ans,tmp,prog,x,rn,rd,todel,delrec,last
old_col=setcolor()
setcolor (COLOR [3])
SAVE SCREEN 
@6,9 TO 18,70
@7,10 CLEAR TO 17,69
_ans ="J"
SET cursor ON 
SET CONFIRM OFF 
@8,12 SAY "þ Verwijderen onbezette disks in database ? ";
   GET _ans PICTURE "!"valid (_ans $"jnJN")
READ 
SET CONFIRM ON 
IF lastkey()<>27
   @9,12 SAY "þ Waarschuwing : Na onderhoud zijn alle items met het"
   @10,12 SAY "  <WIS>-merk voorgoed verdwenen. Doorgaan ?"
   IF sure()
      SET KEY 28 TO 
      @7,10 CLEAR TO 17,69
      @8,12 SAY "þ Bijwerken databases         "
      setcolor(COLOR [7])
      @8,43 SAY REPLICATE("°",20)
      SELECT 1
      PACK 
      @8,43 SAY REPLICATE("²",20)
      setcolor (COLOR [3])
      @10,12 SAY "þ Controleren/bijwerken disks "
      setcolor (COLOR [7])
      @10,43 SAY REPLICATE("°",20)
      SELECT 1
      SET ORDER TO 2
      GO TOP 
      x =0
      IF lastrec()>0
         DO WHILE !EOF()
            @10,43+INT(x/lastrec()*20)SAY "²"
            x =x +1
            tmp =programs->disknr
            rd =DELETED()
            rn =RECNO()
            SKIP 1
            IF programs->disknr =tmp
               SKIP -1
               prog =0
               todel =0
               DO WHILE programs->disknr =tmp
                  REPLACE programs->disks WITH 0
                  prog =prog +1
                  IF DELETED()
                     todel =todel+1
                     delrec =RECNO()
                  ENDIF 
                  SKIP 1
               ENDDO 
               last =RECNO()
               IF todel =prog-1
                  GO delrec
                  REPLACE programs->disks WITH 1
               ENDIF 
               GO last
            ELSE 
               SKIP -1
               IF programs->disks =0
                  REPLACE programs->disks WITH 1
               ENDIF 
               SKIP 1
            ENDIF 
         ENDDO 
      ENDIF 
      @10,43 SAY REPLICATE("²",20)
      setcolor (COLOR [3])
      @12,12 SAY "þ Opnieuw indices genereren   "
      setcolor (COLOR [7])
      @12,43 SAY REPLICATE("°",20)
      INDEX ON UPPER(name)+disknr TO progname
      @12,43 SAY REPLICATE("²",4)
      INDEX ON disknr+STR(catnr)+UPPER(name)TO progdisks
      @12,47 SAY REPLICATE("²",4)
      INDEX ON STR(catnr)+UPPER(name)TO progcat
      @12,51 SAY REPLICATE("²",4)
      SELECT 2
      INDEX ON disknr TO disknr
      @12,55 SAY REPLICATE("²",4)
      SELECT 4
      INDEX ON arcnr TO arcnr
      @12,59 SAY REPLICATE("²",4)
      setcolor (COLOR [3])
      @14,12 SAY "þ Verwijderen onbezette disks "
      setcolor (COLOR [7])
      @14,43 SAY REPLICATE("°",20)
      SELECT 1
      USE programs
      SET INDEX TO progname,progdisk,progcat
      SET ORDER TO 2
      SELECT 2
      prog =lastrec()
      IF prog >0
         GO TOP 
         IF _ans ="J"
            DO WHILE !EOF()
               @14,43+INT(RECNO()/lastrec()*15)SAY "²"
               tmp =disknrs->disknr
               SELECT 1
               SEEK tmp
               IF !FOUND()
                  SELECT 2
                  DELETE 
               ENDIF 
               SELECT 2
               SKIP 1
            ENDDO 
         ENDIF 
         PACK 
      ENDIF 
      COMMIT 
      @14,43 SAY REPLICATE("²",20)
      setcolor(COLOR [3])
      @16,12 SAY "Klaar met onderhoud. Druk een toets voor menu ..."
      SET cursor ON 
      SELECT 1
      SET ORDER TO 1
      INKEY(0)
   ENDIF 
ENDIF 
RESTORE SCREEN 
setcolor (old_col)
SET KEY 28 TO p_help
RETURN 






*Formatted by: dANALYST Gold (Clipper 5.x) V5.0 on 2/16/92 at 1:36 PM.

