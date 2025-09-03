{ Program......: MARJAN - installatie procedure
  Auteur.......: Michel de Rooy
  Datum........: 08/01/92
}

Program MI;

{$V-}


Uses Dos, Crt, FastTTT5, WinTTT5, MiscTTT5, StrnTTT5, ReadTTT5, KeyTTT5;

Label   proc1, proc2, proc3, proc4;

Type    ColorSet                = Array [1..7] of Byte;
                                  { 1/2 : Normal Fore/Back
                                    3/4 : Selector Fore/Back
                                    5/6 : Highlightd Fore/Back
                                    7   : Spec.Color BackGr.}

        Item                    = record
                                        Name : String[12];
                                        Cat  : Byte;
                                  end;

        BT                      = ^Byte;

Const   verno                   = '1.10';
        UpdateTrigger           = 'NIETWIS!.UP3';
        BWCol                   : Colorset
                                = (black,lightgray,white,black,white,lightgray,lightgray);
        RGBCol                  : ColorSet
                                = (black,cyan,yellow,black,white,cyan,blue);

        Categories              : Array [1..6] of String
                                = ('Programma',
                                   'Helpfiles',
                                   'Databases',
                                   'Documentatie',
                                   'Configuratie',
                                   'Windows'
                                  );

        NoFiles                 = 24;

        Files                   : Array [1..NoFiles] of Item
                                = ((Name:'MARJAN.EXE'  ;Cat:1),
                                   (Name:'INSTALL.EXE' ;Cat:1),
                                   (Name:'MARJAN.CFG'  ;Cat:5),
                                   (Name:'MARJAN.ICO'  ;Cat:6),
                                   (Name:'MARJAN.PIF'  ;Cat:6),
                                   (Name:'CATEGORY.DBF';Cat:3),
                                   (Name:'CATEGORY.NTX';Cat:3),
                                   (Name:'PROGCAT.NTX' ;Cat:3),
                                   (Name:'PROGDISK.NTX';Cat:3),
                                   (Name:'PROGNAME.NTX';Cat:3),
                                   (Name:'PROGRAMS.DBF';Cat:3),
                                   (Name:'ARCNR.NTX'   ;Cat:3),
                                   (Name:'ARCNRS.DBF'  ;Cat:3),
                                   (Name:'DISKNR.NTX'  ;Cat:3),
                                   (Name:'DISKNRS.DBF' ;Cat:3),
                                   (Name:'TYPENR.NTX'  ;Cat:3),
                                   (Name:'TYPENRS.DBF' ;Cat:3),
                                   (Name:'HELPIDX.NTX' ;Cat:2),
                                   (Name:'HELPTEXT.DBF';Cat:2),
                                   (Name:'HELPTEXT.DBT';Cat:2),
                                   (Name:'HISTORY.DOC' ;Cat:4),
                                   (Name:'LEESMIJ.DOC' ;Cat:4),
                                   (Name:'REGISTER.DOC';Cat:4),
                                   (Name:'UPDATE.DOC'  ;Cat:4)
                                  );

        BufSize                 = 65535;


Var     Color                   : ColorSet;
        Path, Dir, Name, Ext,
        OldDir,
        tmp                     : String;
        MaxUpdateFile           : Word;
                                  { Max. Filenr. van Files, in geval van
                                    een update-installatie, dus 'partial'.}


        InstallFrom,InstallTo   : StrScreen;
        i                       : Word;
        Buffer                  : Bt;
        Upgrade,OldCB           : Boolean;
        f                       : File;

Procedure Restore_Col;

begin
     ClrScr;
     TextColor (Lightgray);
     TextBackGround (Black);
     FCol := Lightgray;
     BCol := Black;
end;

Procedure BailOut;

begin
     Restore_Col;
     Writeln ('Installatie-procedure afgebroken.');
     Writeln;
     Halt(1);
end;

Procedure SetColors;

begin
  If ColorScreen Then
     Color := RGBCol
  Else
     Color := BWCol;
end;

Procedure Alarm;

Var       n    : Integer;

begin
     n := 3000;
     While n < 4000 do
     begin
          Sound (n);
          Sound (n-2000);
          Sound (n-1000);
          Sound (n-3000);
          Inc (n,1);
     end;
     NoSound;
end;

Procedure Beep;

Var       n    : Integer;

begin
     n := 4000;
     While n > 100 do
     begin
          sound (n);
          Dec (n,15);
     end;
     NoSound;
end;

Function JaNee : Boolean;

Var      iv    : Char;

Begin
     FlushKeyBuffer;
     iv := chr(0);
     While not (iv in ['J','N',Chr(27)]) do
         iv := Upcase(GetKey);
     If iv = Chr(27) Then
        R_Char := Chr(27);
     If iv = 'J' Then
        JaNee := TRUE
     Else
        JaNee := FALSE;
End;

Function Afbreken : Boolean;

Begin
     SaveScreen (2);
     FillScreen (41,25,80,25,Color[1],Color[2],' ');
     WriteAt (42,25,Color[1],Color[2],'Installatie afbreken (j/n)');
     GotoXY (79,25);
     Beep ;
     Afbreken := JaNee;
     RestoreScreen (2);
End;

Procedure Stoppen;

Begin
     Restore_Col;
     FWriteln ('Installatie afgebroken.');
     Halt (1);
End;

Procedure Warning (s : String);

Begin
     Alarm;
     FBox (15,15,65,17,Color[3],Color[4],4);
     WriteAt (17,16,Color[3],Color[4],s+' Afbreken (j/n)');
     GotoXY (Length(s)+37,16);
     If JaNee
        Then Stoppen;
     GotoXY (1,25);
End;

Function Enough_Room (Var Source,Dest : StrScreen; Var Upgrade : Boolean) : Boolean;

Var       Space_Needed     : LongInt;
          I, Max           : Integer;
          F                : File;

begin
     GotoXY (80,25);
     If Upgrade
     Then
         Max := MaxUpdateFile
     Else
         Max := NoFiles;
     Space_Needed := 0;
     For I := 1 to Max do
     With Files[i] do
     begin
         If not Exist (Source+Name) Then
             begin
             Warning ('File '+Name+' niet aanwezig');
             If not (R_Char IN [Chr(27), 'n', 'N'])
             Then
                    BailOut;
             end;
         {$i-}
         Assign (F, Source+Name);
         Reset (F,1);
         Space_Needed := Space_Needed + FileSize(F);
         Close (F);
         {$i+}
     end;
     Enough_Room := (DiskFree(Ord(InstallTo[1])-Ord('A')+1) >  Space_Needed)
end;

Procedure InstallFile (Var CurFile : Item; Var Source, Dest : String;
                       Var Buffer : Bt);

Label     retry1, retry2;

Var       S, D             : File;
          BRead            : LongInt;
          Done, W          : Word;
          PercDone,OP      : Word;
          Klaar, Cancel    : Boolean;
          Size             : LongInt;

begin
  With CurFile do
  begin
    {$i-}
    Assign (S, Source+Name);
    Assign (D, Dest+Name);
    Reset (S,1);
    Size := FileSize(S);
    Cancel := FALSE;
    If not Exist (Source+Name) Then
    begin
       Warning ('File '+Name+' niet aanwezig');
       If R_Char IN [Chr(27), 'n', 'N']
       Then
           Cancel := TRUE
       Else
          BailOut;
    end;
    {$i+}
    GotoXY (1,25);
    WriteAt (42,12,Color[5],Color[6],First(12,Name+Replicate(12,' ')));
    WriteAt (42,14,Color[5],Color[6],First(12,Categories[Cat]+Replicate(12,' ')));
    WriteAt (42,16,Color[5],Color[6],First(12,Int_to_Str(Size)+Replicate(12,' ')));
    WriteAt (42,18,Color[1],Color[2],Replicate(15,'∞'));

    If not Cancel
    Then
    begin
       {$I-}
       Rewrite (D,1);
       Klaar := FALSE;
       BRead := 0;
       Done := 1;
       OP := 0;
       Repeat
             PercDone := Trunc(15*((BRead+BufSize)/Size));
             If PercDone > 15 Then
                PercDone := 15;
             WriteAt (42,18,Color[5],Color[6],Replicate(PercDone,'R'));
             WriteAt (42,18,Color[5],Color[6],Replicate(OP,'≤'));
             BlockRead (S, Buffer^, BufSize, Done);
             If DosError <> 0 Then
             begin
             Warning ('Fout opgetreden tijdens lezen '+Source+Name+'.');
             If not (R_Char IN [Chr(27), 'n', 'N'])
             Then
                    BailOut;
             end;
             If Done < BufSize Then
                Klaar := TRUE;
             W := 1;
             WriteAt (42,18,Color[5],Color[6],Replicate(PercDone,'W'));
             WriteAt (42,18,Color[5],Color[6],Replicate(OP,'≤'));
             BlockWrite (D, Buffer^, Done, W);
             If DosError <> 0 Then
             begin
             Warning ('Fout opgetreden tijdens schrijven '+Dest+Name+'.');
             If not (R_Char IN [Chr(27), 'n', 'N'])
             Then
                    BailOut;
             end;
             Inc (BRead, Done);
             WriteAt (42,18,Color[5],Color[6],Replicate(PercDone,'≤'));
             OP := PercDone;
             If KeyPressed Then
                If GetKey = Chr(27) Then
                   If Afbreken Then
                      Stoppen;
       Until Klaar;
       Close (S);
       Close (D);
       {$I+}
     End;
  End;
end;


Begin
     GetCBreak(OldCB);
     SetCBreak(FALSE);
     Upgrade := FALSE;
     MaxUpdateFile := 99;
     If paramcount > 0 then
     begin
          if upper(paramstr(1))= '/UE3'
          then begin  { Voor 3.00 }
                        Upgrade := TRUE; MaxUpdateFile := 7;
                   end;
          if upper(paramstr(1))= '/UV3'
          then begin  { Vanaf 3.00 }
                        Upgrade := TRUE; MaxUpdateFile := 5;
                   end;
     end;
     GetDir (0, OldDir);
     SetColors;
     FillScreen (1,1,80,25,Color[7],Color[1],'∞');
     FBox (1,1,80,4,Color[1],Color[2],2);
     FCol := Color[7]; BCol := Color[1];
     ColWrite (1,10,'∞€€€€›∞∞∞∞∞∞€€€€›∞∞€€€€€€€›∞∞∞∞€€€€€€€€€€›∞∞∞∞€€€€€›∞€€€€€€€›∞∞∞∞€€€€›∞∞∞€€€€€›∞');
     ColWrite (1,11,'∞∞€€€€›∞∞∞∞€€€€› ∞∞∞€€€€€€€›∞∞∞∞€€€›   €€€›∞∞∞∞€€€› ∞∞€€€€€€€›∞∞∞∞€€€€›∞∞∞€€€› ∞');
     ColWrite (1,12,'∞∞€€€€€›∞∞€€€€€›∞∞∞€€€›  €€€›∞∞∞€€€›∞∞∞∞€€€›∞∞∞€€€›∞∞€€€›  €€€›∞∞∞€€€€€›∞∞€€€›∞∞');
     ColWrite (1,13,'∞∞€€€€€€›€€€€€€›∞∞∞€€€›∞∞€€€›∞∞∞€€€›∞∞∞∞€€€›∞∞∞€€€›∞∞€€€›∞∞€€€›∞∞∞€€€€€€›∞€€€›∞∞');
     ColWrite (1,14,'∞∞€€€›€€€€€›€€€›∞∞€€€› ∞∞∞€€€›∞∞€€€›∞∞∞€€€› ∞∞∞€€€›∞€€€› ∞∞∞€€€›∞∞€€€›€€€›€€€›∞∞');
     ColWrite (1,15,'∞∞€€€›∞€€€› €€€›∞∞€€€€€€€€€€€›∞∞€€€€€€€€€› ∞∞∞∞€€€›∞€€€€€€€€€€€›∞∞€€€›∞€€€€€€›∞∞');
     ColWrite (1,16,'∞∞€€€›∞∞€› ∞€€€›∞∞€€€     €€€›∞∞€€€›   €€€›∞∞∞∞€€€›∞€€€     €€€›∞∞€€€›∞∞€€€€€›∞∞');
     ColWrite (1,17,'∞∞€€€›∞∞∞ ∞∞€€€›∞∞€€€›∞∞∞∞€€€›∞∞€€€›∞∞∞∞€€€›∞∞∞€€€›∞€€€›∞∞∞∞€€€›∞∞€€€›∞∞∞€€€€›∞∞');
     ColWrite (1,18,'∞€€€€€›∞∞∞∞€€€€€›€€€€€›∞∞€€€€€›€€€€€›∞∞∞€€€€€›∞€€€›€€€€€›∞∞€€€€€›€€€€€›∞∞∞€€€€›∞');
     ColWrite (1,19,'∞∞     ∞∞∞∞∞     ∞     ∞∞∞     ∞     ∞∞∞∞     ∞€€€›∞     ∞∞∞     ∞     ∞∞∞∞    ∞');
     ColWrite (1,20,'∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞€€€›∞∞∞∞∞∞€€€›∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞');
     ColWrite (1,21,'∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞€€€€€€€€€€€› ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞');
     ColWrite (1,22,'∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞           ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞');
     WriteAt (35, 2,Color[1],Color[2],'Marjan');
     WriteAt (25, 3,Color[1],Color[2],'Installatie-procedure v'+verno);
     FillScreen (1,25,80,25,Color[1],Color[2],' ');
     WriteAt ( 1,25,Color[3],Color[2],' Esc');
     WriteAt ( 6,25,Color[1],Color[2],'Afbreken');
     WriteAt (40,25,Color[1],Color[2],'≥');
     With RTTT do
     begin
       FCol := Color[3]; BCol := Color[4];
       HiFCol := Color[3]; HiBCol := Color[4];
       LoFCol := Color[3]; LoBCol := COlor[4];
       PFCol := Color[1]; PBCol := Color[2];
       BoxFCol := Color[1]; BoxBCol := Color[2];
       AllowEsc := True; AllowNull := False; WhiteSPace := ' ';
     end;
     InstallFrom := 'A';
     SaveScreen (1);
Proc1:
     { Get drive to install from }
     RestoreScreen (1);
     Beep;
     FlushKeyBuffer;
     Read_Alpha (25,15,1,'Installatie vanaf drive :',1,InstallFrom);
     InstallFrom := Upper (InstallFrom);
     If R_Char = Chr(27) Then
        If Afbreken Then
           Stoppen
        Else
           Goto Proc1;
     InstallFrom := InstallFrom +':';
     If (not Exist (InstallFrom+Files[1].Name)) Then
        InstallFrom := InstallFrom +'\';
        If (not Exist (InstallFrom+Files[1].Name)) Then
        Begin
             SaveScreen (2);
             FBox (18,12,62,14,Color[1],Color[2],1);
             WriteAt (20,13,Color[1],Color[2],'Kan Marjan Files niet vinden op drive '+InstallFrom[1]+':');
             GotoXY (60,13);
             Alarm ;
             FlushKeyBuffer;
             While Not Keypressed do;
             GotoXY(80,25);
             RestoreScreen (2);
             InstallFrom := InstallFrom[1];
             FlushKeyBuffer;
             Goto proc1;
        End;
     WriteAt (42,25,Color[1],Color[2],InstallFrom);
     InstallTo := 'A:\';
     If not Exist ('C:.') Then
     begin
        RestoreScreen (1);
        Goto Proc3;
     end;
Proc2:
     { Install on harddisk ? }
     RestoreScreen (1);
     Beep;
     FBox (21,14,57,16,Color[1],Color[2],1);
     WriteAt (23,15,Color[1],Color[2],'Installatie op harddisk (j/n) ');
     GotoXY (53,15);
     If JaNee Then
        InstallTo := 'C:\MARJAN'
     Else
        InstallTo := 'B:\';
     If R_Char = Chr(27) Then
        If Afbreken Then
           Stoppen
        Else
           Goto Proc2;
     RestoreScreen (1);
Proc3:
     { get diskdrive to install to }
     Beep;
     FlushKeyBuffer;
     Read_String_Upper (19,15,21,'Installatie in :',1,InstallTo);
     If R_Char = Chr(27) Then
        If Afbreken Then
           Stoppen
        Else
           begin
             RestoreScreen (1);
             Goto Proc3;
           end;
     If Last (1,InstallTo) <> '\' Then
        InstallTo := InstallTo + '\';
     {$i-}
     chdir (InstallTo[1]+Installto[2]);
     If IoResult <> 0 Then
     begin
        Alarm;
        WriteAt (42,25,Color[1],Color[2],'Kan directory niet aanmaken.');
        Goto proc3;
     end;
     chdir (InstallTo[1]+InstallTo[2]+'\');
     i := 4;
     while i <= length(InstallTo) do
     begin
      tmp := '';
      while (InstallTo[i] <> '\') and (i <= length(InstallTo)) do
      begin
         tmp := tmp + InstallTo[i];
         inc (i)
      end;
      mkdir (tmp);
      chdir (tmp);
      inc (i)
     end;
     ChDir (OldDir);
     {$I+}
proc4:
     If Exist (InstallTo+Files[1].Name) and not Upgrade
     then
        begin
             SaveScreen (2);
             FBox (12,12,68,14,Color[1],Color[2],1);
             WriteAt (14,13,Color[1],Color[2],'Marjan files al aanwezig . Uitvoeren upgrade (j/n)');
             GotoXY (67,13);
             Alarm ;
             If not JaNee then
                stoppen;
             GotoXY(80,25);
             RestoreScreen (2);
             If R_Char = Chr(27)
             Then
                Goto proc3;
             MaxUpdateFile := 5;
             Upgrade := TRUE;
             If not Exist (InstallTo+Files[6].name) then
                MaxUpdateFile := 7;
        End;
     If Not Enough_Room (InstallFrom, InstallTo, Upgrade)
     Then
         begin
             SaveScreen (2);
             FBox (17,12,63,14,Color[1],Color[2],1);
             WriteAt (19,13,Color[1],Color[2],'Te weinig ruimte om Marjan te installeren.');
             GotoXY (80,25);
             Alarm ;
             FlushKeyBuffer;
             While Not KeyPressed do;
             GotoXY(80,25);
             RestoreScreen (2);
             Goto proc3;
        End;

     RestoreScreen (1);
     FBox (20,10,60,20,Color[1],Color[2],3);
     WriteAt (24,12,Color[1],Color[2],'Name............:');
     WriteAt (24,14,Color[1],Color[2],'Onderdeel.......:');
     WriteAt (24,16,Color[1],Color[2],'Size............:');
     WriteAt (24,18,Color[1],Color[2],'Vorderingen.....:');
     GetMem (Buffer, BufSize);
     FillScreen (41,25,80,25,Color[1],Color[2],' ');
     If Upgrade
     then
         if MaxUpdateFile = 7
         then
            WriteAt (42,25,Color[1],Color[2],'Upgraden eerdere versie dan 3.00')
         else
            WriteAt (42,25,Color[1],Color[2],'Upgraden versie vanaf 3.00 ...')
     Else
         WriteAt (42,25,Color[1],Color[2],'Installatie bestanden ...');
     If Upgrade
     Then
     begin
        For i := 1 to MaxUpdateFile do
        begin
             InstallFile (Files[i],InstallFrom,InstallTo, Buffer);
        End;
        If MaxUpdateFile = 7 then
        begin
             { Add File to trigger structure altering by MARJAN.EXE }
             {$I-}
             Assign(f,InstallTo+UpdateTrigger);
             Close(f);
             Erase(f);
             Assign(f,InstallTo+UpdateTrigger);
             Rewrite(f,1);
             Close(f);
             {$I+}
        end;
     end
     Else
        For i := 1 to NoFiles do
        begin
             InstallFile (Files[i],InstallFrom,InstallTo, Buffer);
        End;
     FillScreen (41,25,80,25,Color[1],Color[2],' ');
     FreeMem (Buffer, BufSize);
     Restore_Col;
     ClrScr;
     FWriteln ('Marjan succesvol geãnstalleerd. Om Marjan op te starten gaat u naar');
     FWriteln ('directory '+InstallTo+', en typt in "MARJAN".');
     FWriteln ('');
     Halt(1);
     SetCBreak(OldCB);
End.
