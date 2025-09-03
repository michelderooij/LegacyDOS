*  FILE NAME: p_dos.PRG
*  BY: 
*  NOTICE: 
*  DATE: 1/15/92
*  DESC:
*  CALLED BY:
*  DATA FILES:
PRIVATE old_col,envvar,res
SAVE SCREEN 
old_col=setcolor()
setcolor (org_cols)
CLEAR 
@2,0 SAY "Typ 'EXIT' om terug te keren naar Marjan."
@0,0
?"Vrij maken geheugen..."
@4,0
SET cursor ON 
mouseoff()
envvar ="OVERLAYED=Y"
overscan (0)
COMMIT 
Overlay ("",0,"",envvar)
COMMIT 
res =O_ErrMajor()
IF ISCOLOR()
   overscan (attr(COLOR [8]))
ENDIF 
mouseon()
SET cursor OFF 
setcolor (old_col)
RESTORE SCREEN 
IF res <>0
   p_help(0,"DOSERROR",0)
ENDIF 
rest_logo()
RETURN 




*Formatted by: dANALYST Gold (Clipper 5.x) V5.0 on 2/16/92 at 1:34 PM.

