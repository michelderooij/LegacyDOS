/****************************************************************
*
*  Program  : BLERRC50.PRG
*           : Blinker/Clipper 5.0 Error Handler
*  Date     : 91.05.04
*
*  Compiler : Clipper 5.0
*  Linker   : Blinker 1.50
*  Compile  : /n/m/w/l
*
*  Note     : Overlaying of this file is NOT recommended, because
*           : if a severe error occurs, it may be impossible to
*           : load this error handler into memory, in which case
*           : the error will never be reported, making debugging
*           : difficult.
*/

#command ? <list,...>   =>  ?? Chr(13) + Chr(10) ; ?? <list>
#command ?? <list,...>  =>  OutErr(<list>)

function BlErrc50()
local bBliError, bOldErrBlk, nErrCode, oErr, lUseErrBlk
public lInErr       

// First check we're not in a multiple error situation
// (likely cause of multiple error is an error loading
// an overlay while in an error situation)

if m->lInErr
   ?  "Blinker error :   "
   ?? BliErrNum()
   ?  "(Multiple errors occurred while in error handler)"
   quit
endif

m->lInErr := .T.                                // In an error
lUseErrBlk = .t.                                // Use BLINKER error block

oErr := ErrorNew()                              // Create error object

nErrCode       := BliErrNum()                   // Blinker Error Number
oErr:subsystem := [BLINKER]                     // Failing Subsystem name
oErr:subCode   := nErrCode                      // Blinker error number
oErr:canRetry  := .F.                           // Not Retryable

do case
   case nErrCode = 1201
        oErr:description := [Unable to find overlay file ]+BliErrPrm()+[ in current path]
        oErr:filename    := BliErrPrm()
   case nErrCode = 1202
        oErr:description := [Dos read error in file ]+BliErrPrm()
        oErr:filename    := BliErrPrm()
   case nErrCode = 1203
        oErr:description := [File ]+BliErrPrm()+[ is not a valid .EXE file]
        oErr:filename    := BliErrPrm()
   case nErrCode = 1204
        oErr:description := [Overlay file ] + BliErrPrm() + [ does not match the .EXE file]
        oErr:filename    := BliErrPrm()
   case nErrCode = 1205
        oErr:description := [Not enough memory to load procedure]
   case nERRCode = 1206
        oErr:description := [Maximum procedure nesting depth exceeded]
        lUseErrBlk = .f.
   case nERRCode = 1207
        oErr:description := [Demonstration calls limit exceeded]
        lUseErrBlk = .f.
   case nERRCode = 1208
        oErr:description := [Demonstration date limit exceeded]
        lUseErrBlk = .f.
   case nERRCode = 1209
        oErr:description := [Demonstration time limit exceeded]
        lUseErrBlk = .f.
   case nERRCode = 1210
        oErr:description := [Overlay has been prematurely freed]
   case nERRCode = 1211
        oErr:description := [Overlay manager internal stack overflow]
   case nERRCode = 1212
        oErr:description := [Overlay Opsize exceeded - increase Opsize]
   case nERRCode = 1213
        oErr:description := [Attempt to call DEFINED routine]
        lUseErrBlk = .f.
   otherwise
        oErr:description := [Unknown BLINKER error]
end case

set color to
cls

if lUseErrBlk
   bOldErrBlk := ErrorBlock({|e|BliError(e)})   // Install new error handler
else
   ?? "Blinker error" + str (oErr:subCode,5)
   ?? " :", oErr:description                    // Just in case error handler
   ?                                            // fails
endif

eval(Errorblock(),oErr)                         // Evaluate the error block

if lUseErrBlk
   Errorblock(bOldErrBlk)                       // Restore the previous handler
endif

m->lInErr := .F.

return (nil)

// Blinker error handler

Static Function BliError(e)
local i

   ? "Error         : "

	if ( !Empty(e:subsystem()) )
      ?? e:subsystem() + "/" + Ltrim(Str(e:subCode()))
	end
	if ( !Empty(e:description()) )
      ? "Description   : " + e:description()
	end
   if ( !Empty(e:filename()) )
      ? "Filename      : " + e:filename()
	end
   ?
   ? "Call Trace"
   i := 3
	while ( !Empty(ProcName(i)) )
      ? "Called from   : ", Left(ProcName(i)+SPACE(20),20) + ;
         "(" + Substr(SPACE(7)+Str(ProcLine(i)),-7) + ")  "
		i++
	end
   ?
   ERRORLEVEL(1)                             
   QUIT                                         // terminate application
return (nil)
