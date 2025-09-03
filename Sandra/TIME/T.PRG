#define TIMELEFT               1
#define PRIORITY               2
#define SEQUENCE               3
#define BEST_TIME              4
#define BEST_PRIO              5
#define OPTIM                  6
#define EVTIME                 7
#define EVPRI                  8

local maxTime, sumPri
local optimum := {0,0,{},0,0,{},{},{}}

private item := {}

// by changing eval_* into code that will seek and read dbf-fields, you can save
// memory, by using disk-access instead of arrays... but don't forget the coffee :-)

//private eval_time := "{|x|item[x,1]}"
//private eval_prio := "{|x|item[x,2]}"
private eval_time := "{|x|goto(x), dur}"
private eval_prio := "{|x|goto(x), pri}"

private maxItem

use test index i1 new
clear
go top
dbeval({||aadd(item, {test->dur, test->pri}), test->flag := .F.})

maxItem := Lastrec()
maxTime := 10000
sumPri := 0

asize(optimum[SEQUENCE],maxItem)
//asize(optimum[SEQUENCE],ceiling(maxItem/32))
afill(optimum[SEQUENCE],.F.)
optimum[OPTIM] := optimum[SEQUENCE]
optimum[EVTIME] := (eval_time)
optimum[EVPRI] := (eval_prio)

optimum[PRIORITY] := optimum[BEST_PRIO] := sumPri
optimum[TIMELEFT] := optimum[BEST_TIME] := maxTime

? "Optimizing Time ... "
st := seconds()
optimum := optimize_time(optimum, 1, maxTime, sumPri)
et := seconds()
? "Priority ... "+str(optimum[BEST_PRIO])
? "Time Left .. "+str(optimum[BEST_TIME])
? "Reeks ...... "
for x := 1 to len(optimum[OPTIM])
    ?? charmirr(ntoc(optimum[OPTIM,x],2,,"0"))
next
? "Elapsed sec. "+str(et-st)

afill(optimum[SEQUENCE],0)
optimum[OPTIM] := optimum[SEQUENCE]
optimum[PRIORITY] := optimum[BEST_PRIO] := sumPri
optimum[TIMELEFT] := optimum[BEST_TIME] := maxTime

? "Optimizing Priority ... "
st := seconds()
optimum := optimize_prio(optimum, 1, maxTime, sumPri)
et := seconds()
? "Priority ... "+str(optimum[BEST_PRIO])
? "Time Left .. "+str(optimum[BEST_TIME])
? "Reeks ...... "
for x := 1 to len(optimum[OPTIM])
    ?? charmirr(ntoc(optimum[OPTIM,x],2,,"0"))
next
? "Elapsed sec. "+str(et-st)

//go top
//dbeval({||test->flag:=isbit(optimum[OPTIM,1],recno())})

//list nr, dur, pri, flag
close test
return

function optimize_time (prev, init, mt, sp)
local seq:=prev, ot := mt, op := sp, t
if init <= maxItem
   prev[SEQUENCE] := set(prev[SEQUENCE],init)
   if (mt >= (t := eval(&(prev[EVTIME]),init)))
      mt -= t
      sp +=eval(&(prev[EVPRI]),init)
      if ((mt<prev[TIMELEFT]).OR.(mt==prev[TIMELEFT].AND.sp>prev[PRIORITY]))
         prev[TIMELEFT] := mt
         prev[PRIORITY] := sp
           if ((mt<prev[BEST_TIME]).OR.(mt==prev[BEST_TIME].AND.sp>prev[BEST_PRIO]))
              prev[OPTIM] := aclone(prev[SEQUENCE])
              prev[BEST_TIME] := prev[TIMELEFT]
              prev[BEST_PRIO] := prev[PRIORITY]
           endif
         prev := optimize_time(prev, init+1, mt, sp)
      endif
   endif
   prev[SEQUENCE] := clear(prev[SEQUENCE],init)
   seq := optimize_time(seq, init+1, ot, op)
   if ((seq[BEST_TIME]<prev[BEST_TIME]).OR.(seq[BEST_TIME]==prev[BEST_TIME].AND.seq[BEST_PRIO]>prev[BEST_PRIO]))
      prev := seq
   endif
endif
return (prev)

function optimize_prio (prev, init, mt, sp)
local seq:=prev, ot := mt, op := sp, t
if init <= maxItem
   prev[SEQUENCE] := set(prev[SEQUENCE],init)
   if (mt >= (t := eval(&(prev[EVTIME]),init)))
      mt -= t
      sp +=eval(&(prev[EVPRI]),init)
      if ((sp>prev[PRIORITY]).OR.(sp==prev[PRIORITY].AND.mt<prev[TIMELEFT]))
         prev[TIMELEFT] := mt
         prev[PRIORITY] := sp
           if ((sp>prev[BEST_PRIO]).OR.(sp==prev[BEST_PRIO].AND.mt<prev[BEST_TIME]))
              prev[OPTIM] := aclone(prev[SEQUENCE])
              prev[BEST_TIME] := prev[TIMELEFT]
              prev[BEST_PRIO] := prev[PRIORITY]
           endif
         prev := optimize_prio(prev, init+1, mt, sp)
      endif
   endif
   prev[SEQUENCE] := clear(prev[SEQUENCE],init)
   seq := optimize_prio(seq, init+1, ot, op)
   if ((seq[BEST_PRIO]>prev[BEST_PRIO]).OR.(seq[BEST_PRIO]==prev[BEST_PRIO].AND.seq[BEST_TIME]<prev[BEST_TIME]))
      prev := seq
   endif
endif
return (prev)

procedure set(x,p)
//local h := floor(p/32), l := p%32
//h++
//x[h]:=setbit(x[h],l)
x[p] := .T.
return x

procedure clear(x,p)
//local h := floor(p/32), l := p%32
//h++
//x[h]:=clearbit(x[h],l)
x[p] := .F.
return(x)


procedure Used(x,p)
//local h := floor(p/32), l := p%32
//h++
//return (isbit(x[h],l))
return x[p]

function goto(x)
dbgoto(x)
return nil
