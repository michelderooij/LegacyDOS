/* Functie : Translate
   Versie  : 1.5
   Door    : M.de Rooy
             (c) 1992 M.de Rooy
   Compiler: Microsoft-C versie 5.01 (of hoger)
   Compile : cl /c /AL /Zl /Oalt /FPa /Gs translate.c
   Syntax  : <c1> = translate(<c2>)
   Param.  : <c2> is de te bewerken string
   Geeft   : <c1> is de vertaalde string
   Werking : Vertaald
             þ letters met leestekens naar de letter zelf in uppercase
             þ streepjes, apostrophes, worden genegeerd. Het aantal karakters
               wat tot deze groep behoort wordt als spaties aangevuld.
               <c1> wordt dus een string van een reeks tekens (1 'woord')
             þ Een 'y' wordt gelijkgesteld aan 'ij'/'˜' (Met inachtname van
               de regel '‰'÷'e', '‹'÷'i', etc. ! )
             þ de rest naar uppercase

   Doel    : Het consequent houden van bv. een lijst met namen :

                VOOR:                                NA:

                Giant                                Giant
                Gizmo                 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄGiáling
                GiálingÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ              Gizmo
                Jan Hees                             Jan Hees
                Jan Modaal            ÚÄÄÄÄÄÄÄÄÄÄÄÄÄJan-Kees
                Jan-KeesÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ              Jan Modaal
                Meijgaarden                          Meyer
                Meyer                                Meijgaarden
                Van VlietÄÄÄÄÄÄÄÄÄÄÄÄÄ¿              Vanavond
                Vanavond              ÀÄÄÄÄÄÄÄÄÄÄÄÄÄVan Vliet


*/
#include "extend.h"

#define toupper(c)  (((c)>='a' && (c)<='z') ? (c)+'A'-'a' : (c))

#include <stdlib.h>

CLIPPER translate()
{
    unsigned int j,i;
    unsigned char *source, *target, *csrc, *ctgt, *aanvul;
    unsigned char plainupperchar(unsigned char kar);

    if (PCOUNT==1 && ISCHAR(1))
    {
        source = _parc(1);
        j=strlen(source);
        target=_exmgrab(1+j);
        csrc=source;
        ctgt=target;
        *(target+j) = '\0';  /* Ook NULL-CHAR ! */
        aanvul=target+j-1;
        for (i=0; i < j; i++)
        {
            switch (*csrc)
            {
                /* Hieronder de eruit te filteren karakters : */
                case '-' :
                case '.' :
                            *aanvul=' '; /* Vul aan met spaties */
                            aanvul--;
                            break;

                /* De rest omzetten */
                default : *ctgt = plainupperchar(*csrc);
                          ctgt++;
                          break;
            }
            csrc++;
        }
        _retc(target);
    }
    else
    {
        _retc("");
    }
}

unsigned char plainupperchar(unsigned char kar)
{
    switch(kar)
	{
	    case 'ƒ' :
	    case '„' :
	    case '…' :
	    case ' ' :
	    case '†' :
	    case '‘' :
	    case 'Ž' :
	    case '’' :
        case '' :  return 'A';
	    case '‡' :
        case '€' :  return 'C';
	    case '‚' :
	    case 'ˆ' :
	    case '‰' :
	    case 'Š' :
        case '' :  return 'E';
	    case '‹' :
	    case 'Œ' :
	    case '' :
        case '¡' :  return 'I';
	    case '“' :
	    case '”' :
	    case '•' :
	    case '¢' :
        case '™' :  return 'O';
	    case '¤' :
        case '¥' :  return 'N';
        case 'á' :  return 'S';
	    case '–' :
	    case '' :
	    case '—' :
	    case '£' :
        case 'š' :  return 'U';
        case '˜' :  return 'Y';
        default : return toupper(kar);
	}
}

