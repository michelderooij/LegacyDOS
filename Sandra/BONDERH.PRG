#include "inkey.ch"
#include "config.ch"
#include "set.ch"

local i, j, h, totrec := 0
local y := 10
private gt, iname, iexpr, pm
for i := 1 to len(NTX_STRUX)
    SysUse(i,.F.)
    pack
    totrec+=(len(NTX_STRUX[i])+len(CFTS_STRUX[i]))*lastrec()
next
totrec+=composed->(lastrec())
totrec+=2*records->(lastrec())
pm := prog_init(10,70,"Creatie Indexbestanden","",totrec,METER)
gt := 0
for i := 1 to len(NTX_STRUX)
    sysSelect(i)
    if !diskready(left(CONFIG_DBF_PATH,1))
       perror("Drive "+left(CONFIG_DBF_NAME,1)+" is niet gereed")
       exit
    endif
    for j := 1 to len(NTX_STRUX[i])
        iexpr := NTX_STRUX[i,j]
        iname := NTX_NAME(i,j)
        index on &iexpr to &iname
        dbclearindex()
        dbcommit()
        gt+=lastrec()
        prog_supdate(pm,gt)
    next
    if !empty(CFTS_STRUX[i])
       for j := 1 to len(CFTS_STRUX[i])
         iexpr := CFTS_STRUX[i,j]
         iname := CFTS_NAME(i,j)
         if file(iname)
           filedelete(iname)
         endif
         h := createcftsind(iname,iexpr)
         cfts_close(h)
         gt+=lastrec()
         prog_supdate(pm,gt)
       next
    else
    endif
next

for i := 1 to len(NTX_STRUX)
    sysClose(i)
    //for j := 1 to len(NTX_STRUX[i])
    //   purify(NTX_NAME(i,j))
    //next
next

for i := 1 to len(NTX_STRUX)
    sysUse(i,.T.) // With indices !
next

 // And now : The MAJOR searchindex for the complete "Quest for Text"
 SysSelect(1) // It's compositions we wanna walk through ...
 h := createcftsind(CFTS_NAME(1,1),"cfts_expr()")
 cfts_close(h)

prog_full(pm)
for i := 1 to len(NTX_STRUX)
    sysClose(i)
next

prog_close(pm)
close databases
commit
return

function createcftsind(fname, expr)
local h, rec, od := SET(_SET_DELETED), io := indexord(), key, oldrec := recno()
set deleted off
set order to 0
if file(fname)
   if !ferase(fname)
      perror("Kan systeembestanden niet bijwerken")
      return
   else

   endif
else

endif
h := cftscrea(fname, 20, 3, .T., 1)
if h < 0
   cfts_err(procname(), procline()-2, h)
else

endif
goto top
while !eof()
   key := translate(&expr.)
   rec := cftsadd(h,key)
   if rec < 1
      cfts_err(procname(),procline()-2,rec)
   else

   endif
   dbskip()
end
set(_SET_DELETED, od)
cfts_close(h)
dbcommitall()
h:=cfts_open(fname,16,set(_SET_EXCLUSIVE))
dbgoto(oldrec)
dbsetorder(io)
return(h)
