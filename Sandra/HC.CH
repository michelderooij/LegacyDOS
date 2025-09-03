#define HELPKEY         "301070130572"
#define ENFUNTEXT(x)    encrypt(x,HELPKEY)
#define DEFUNTEXT(x)    decrypt(x,HELPKEY)

#define HELPTOPIC       ".TOPIC"
#define HELPWORD        ".WORD"
#define HELPSCREEN      ".SCREEN"
#define HELPREFCHAR     {"{","}"}
#define HELPSEPERATOR   ":"
#define HELPTOP         128
#define HELPIGNORE      "%"

#define HELPFILE        "SANDRA.HLP"

#define HELP_TOPIC      10000
#define INDEX_TOPIC     9999

#define CENTER          {"^",1}
#define RJUST           {"`",2}
