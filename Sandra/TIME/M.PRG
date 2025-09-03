local a[0], b[0], i, s, e
use test new
go top
for i := 1 to 5
    aadd(a,test->dur)
    aadd(b,test->pri)
    skip
next
//a := {40,20,55,10,30}
//b := {1,1,5,1,1}
s := seconds()
? optimize(a, b, 5400, .T.)
e := seconds()
? "Elapsed time : "+str(e-s)
close test
