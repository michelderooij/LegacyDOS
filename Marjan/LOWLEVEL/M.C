/*

getrights(C,N)
setrights(C,N)
i2c(L,N)
C1=tempfile(C2,C3)
setpal(C)
N=bin2dec("101011101001")
*/

#include "nandef.h"
#include "extend.h"

#include <c:\qc\include\stdlib.h>
#include <c:\qc\include\stdio.h>
#include <c:\qc\include\io.h>
#include <c:\qc\include\dos.h>
#include <c:\qc\include\sys\types.h>
#include <c:\qc\include\sys\stat.h>

#define  buffersize         2

/*
** getrights ("drive:path\file.ext",mode)
**
** Geeft Read/Write rechten van een file
**
** mode : 00 - Existence                04 Read permission
**        02 - Write permission         06 Read & Write permission
**
** Returns : .T.  if passed mode is effective
**           .F.  if passed mode not effective or in case of an error
**
*/

CLIPPER getrights()
{
    char *pathname;
    int mode;
    if ((PCOUNT==2) && ISCHAR(1) && ISNUM(2))
    {
        pathname = _parc(1);
        mode = _parni(2);
        printf(" %d ",access(pathname,mode));
        _retl(access(pathname,mode)==0 ? TRUE : FALSE);
        return;
    }
    else
    {
        _retl(FALSE);
        return;
    }
} /* getrights */

/*
** setrights ("drive:path\file.ext",mode)
**
** Zet Read/Write rechten van een file
**
** mode :                               04 Read permission
**        02 - Write permission         06 Read & Write permission
**
** Returns : .T.  if done
**           .F.  in case of error
**
*/

CLIPPER setrights()
{
    char *pathname;
    int mode;
    if ((PCOUNT==2) && ISCHAR(1) && ISNUM(2))
    {
        pathname = _parc(1);
        mode = _parni(2);
        _retl(chmod(pathname,mode)==0 ? TRUE : FALSE);
        return;
    }
    else
    {
        _retl(FALSE);
        return;
    }
} /* setrights */


/* Geeft characterstring van logische waarde terug
** l2c(L,N)
**
**          .T.    .F.
**
** N = 1  : JA     NEE
** N = 2  : AAN    UIT
** N = 3  : TRUE  FALSE
*/

CLIPPER l2c()
{
    Boolean a;
    if ((PCOUNT==2) && ISLOG(1) && ISNUM(2))
    {
        a = _parl(1);
        switch (_parni(2))
        {
               case 1 : _retc(a==TRUE ? "JA" : "NEE"); return;
               case 2 : _retc(a==TRUE ? "AAN" : "UIT"); return;
               case 3 : _retc(a==TRUE ? "TRUE" : "FALSE"); return;
               default: _retc(a==TRUE ? "JA" : "NEE"); return;
        }
    }
    else
    {
        a = _parl(1);
        if ((PCOUNT==1) && ISLOG(1))
        {
           _retc(a==TRUE ? "JA" : "NEE");
           return;
        }
        else
        {
           _retc("");
           return;
        }
    }
}

CLIPPER tempfile()
{
    char *dir, *prefix, *name;
    if ((PCOUNT==2) && ISCHAR(1) && ISCHAR(2))
    {
        dir = _parc(1);
        prefix = _parc(2);
        name=tempnam(dir,prefix);
        if (name!=NULL)
        {
            _retc(name);
            return;
        }
        else
        {
            _retc("");
            return;
        }
    }
    else
    {
        _retc ("");
        return;
    }
}

CLIPPER bin2dec()
{
    quant a=0;
    char *str;
    if ((PCOUNT==1) && ISCHAR(1))
    {
        str = _parc(1);
        while (*str)
        {
            a = (a << 1) + (*str=='0' ? 0 : 1);
            str++;
        }
    }
    _retnd(a);
}

CLIPPER setpal()
{
    union REGS inregs,outregs;
    struct SREGS sregs;
    char *str;
    if ((PCOUNT==1) && ISBYREF(1))
    {
        str = _parc(1);
        inregs.x.ax = 0x1002;
        sregs.es = FP_SEG(str);
        inregs.x.dx = FP_OFF(str);
        int86x (0x10,&inregs,&outregs,&sregs);
    }
    _retl(TRUE);
    return;
}

