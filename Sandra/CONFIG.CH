*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*³ Include file ....... : CONFIG
*³
*³ Omschrijving ....... : BEVAT STANDAARD CONSTANTEN DIE CODE
*³                        LEESBAARDER MOETEN MAKEN, PLUS KLEURENSETTINGS
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

#translate activate(<x>) => qqout(<x>)

#translate gets_save() => getlist
#translate gets_restore(<x>) => getlist := (x)
#translate gets_clear() => getlist := {}

#translate occures(<key>) => dbseek(<key>)

#define VERSIONLEN    30

#define SYS_SIZE      40000
#define TAG_LIMIT     10

#define DIVERSEN      "Diversen"
#define MIXTEXT       "Mix"

#define HOTKEYS      "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"

// Database descriptions
#define DBF_DESCR  {"Composed","Records","Albums","Artists","Songs","Media","Genres","Titles","Company"}

// End-of-Line
#DEFINE EOLN (chr(13)+chr(10))

// KARAKTERS VOOR METERS BIJ VIEW/EDIT
#define IND_H1                  "°"
#define IND_H2                  "Û"
#define IND_V1                  "°"
#define IND_V2                  "Û"

#define TB_COLSEP               {"ÂÄ","³ "}

// Versie en naam :
#define PROGNAME                "SANDRA"
#define VERSIE                  "0.01à"
#define AUTHOR                  "M.de Rooy"
#define COPYRIGHTYEARS          "(c) 1992,1993"
#define COPYRIGHTOWNER          "Automatiserings- & Adviesbureau van Leeuwen"

// The numbers determine the level of adaptor. 4 can run 3, but 3 not 4 !
#define _MONO   10
#define _CGA    20
#define _EGA    30
#define _PGA    30
#define _MCGA   40
#define _VGA    40

#define SCREENMODES     {{_MONO,"^25 Regels",{||CGA80()}},{_EGA,"^43 Regels",{||EGA43()}},;
                         {_VGA,"2^8 Regels",{||VGA28()}},{_VGA,"^50 Regels",{||VGA50()}},;
                         {_MONO,"^Als in DOS",{||setscrmode(OLD_MODE)}}}

#define TUNE_LASER       1
#define TUNE_RING        2
#define TUNE_BUTTONPRESS 3
#define TUNE_NOTFOUND    4

#define CFG_SETTINGS      _SETTINGS_[1]

#define CONFIG_PRINTER     CFG_SETTINGS[1]
#define CONFIG_BEEPER      CFG_SETTINGS[2]
#define CONFIG_COLORSET    CFG_SETTINGS[3]
#define CONFIG_DBF_PATH    CFG_SETTINGS[4]
#define CONFIG_SCREENMODES CFG_SETTINGS[5]

// Name of configurationfile
#define CONFIG_NAME       PROGNAME+".CFG"

#define CFG_COLORS        _SETTINGS_[2,CONFIG_COLORSET]

#define BACKGR            CFG_COLORS[2]
#define DIALOG_TEXT       CFG_COLORS[3]
#define DIALOG_LIST       CFG_COLORS[4]
#define DIALOG_BUTTON     CFG_COLORS[5]
#define DIALOG_INPUT      CFG_COLORS[6]
#define DIALOG_SELECT1    CFG_COLORS[7]
#define DIALOG_SELECT2    CFG_COLORS[8]
#define DIALOG_SELECT3    CFG_COLORS[9]
#define MENU              CFG_COLORS[10]
#define WARNING           CFG_COLORS[11]
#define ERROR             CFG_COLORS[12]
#define METER             CFG_COLORS[13]
#define HELP              CFG_COLORS[14]

// z = pdef(x,y)
// z neemt de waarde aan van y indien x is gedefini‰erd, anders y.
// wordt gebruikt voor het instellen van standaardwaarden bij parameters
// indien niet doorgegeven.
#define pdef(x,y)               (iif(x=NIL,y,x))

#define DBF_STRUX  { ;
        {{"recnr","n",7,0},{"songnr","n",7,0},{"artnr","n",7,0},{"version","c",30,0}}, ;
        {{"ordnr","c",20,0},{"disknr","n",1,0},{"cdid","n",3,0},{"recnr","n",7,0},;
                   {"time","n",4,0},{"isamix","l",1,0},{"multiart","l",1,0}}, ;
        {{"ordnr","c",20,0},{"altnr","n",7,0},{"comnr","n",3,0},;
                   {"volume","c",3,0},;
                   {"year","n",4,0},{"multiart","l",1,0},{"dop","d",8,0},;
                   {"mednr","n",3,0},{"gennr","n",3,0},{"prijs","n",7,2}}, ;
        {{"artnr","n",7,0},{"name","c",30,0}}, ;
        {{"songnr","n",7,0},{"title","c",30,0}}, ;
        {{"mednr","n",3,0},{"media","c",5,0},{"items","n",2,0}}, ;
        {{"gennr","n",3,0},{"genre","c",12,0}},;
        {{"altnr","n",7,0},{"title","c",30,0}}, ;
        {{"comnr","n",3,0},{"company","c",15,0}} ;
        }

#define NTX_STRUX { ;
        {"str(recnr,7)+str(volgnr,3)"},;
        {"ordnr+str(disknr,2)+str(cdid,3)","recnr"},;
        {"ordnr"},;
        {"artnr"},;
        {"songnr"},;
        {"mednr"},;
        {"gennr"},;
        {"altnr"},;
        {"comnr"};
        }

// All CFTS-indices, except for the 'large' one, which includes all
// following fields : ...
#define CFTS_STRUX { ;
        {},;
        {},;
        {},;
        {"name"},;
        {"title"},;
        {"(padr(rtrim(media)+iif(items>1,'/'+str(items),space(0)),8))"},;
        {"genre"},;
        {"title"},;
        {"company"};
        }
// ... This 'special' index can be used for a global search.

// CFTS Fieldnames for use on header of PickLists ...
#define FIELDNAMES {"","","","Artiest","Titel","Medium","Genre","Titel Album","Label"}


#define KEY_SEARCH              {K_F2,"F2"}

