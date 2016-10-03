program Over_Simplistic_Text_Editor;

uses app, objects, menus, drivers, views, tutconst, msgbox, memory, editors,
     stddlg, crt, colorsel, dos, dialogs, ostecmds, asciitab, ostehelp;

type
 screentype = array [0..3999] of byte;

type
    tosteapp = object(tapplication)
    clipboardwindow: peditwindow;
    constructor init;
    procedure initstatusline;                           virtual;
    procedure initmenubar;                              virtual;
    procedure doaboutbox;                               virtual;
    procedure handleevent(var event: tevent);           virtual;
    procedure newwindow;                                virtual;
    procedure openwindow;                               virtual;
    procedure asciichart;                               virtual;
    procedure ss;                                       virtual;
    procedure changedir;                                virtual;
    procedure help;                                     virtual;
    {procedure FileOpen(WildCard: PathStr); virtual;
    function OpenEditor(FileName: FNameStr; Visible: Boolean): PEditWindow; virtual;}

end;

var
   osteapp: tosteapp;
   screen : screentype absolute $B800:0000;


procedure tosteapp.initstatusline;
var
   r: trect;
begin
     getextent(r);
     r.a.y := r.b.y -1;
     new(statusline, init(r,
       newstatusdef(0, $EFFF,
         newstatuskey('~F2~ Save', kbF2, cmsave,
         newstatuskey('~F3~ Open', kbF3, cmopen,
         newstatuskey('~F4~ New', kbF4, cmnew,
         newstatuskey('~Alt+F3~ Close', kbaltF3, cmclose,
         newstatuskey('~Alt+J~ Jump to DOS', kbaltJ, cmdosshell,
         stdstatuskeys(nil)))))),
         nil)));
{       newstatusdef($F000, $FFFF,
         newstatuskey('~A~ir~W~ay~S~ BBs', kbnokey, cmabout,
         stdstatuskeys(nil)), nil);}
end;

procedure Tosteapp.initmenubar;
var
   r: trect;
begin
     getextent(r);
     r.b.y := r.a.y+1;
     menubar := new(pmenubar, init(r, newmenu(
             newsubmenu('~F~ile', hcnocontext, newmenu(
               stdfilemenuitems(nil)),
             newsubmenu('~E~dit', hcnocontext, NewMenu(
               stdeditmenuitems(nil)),
             newsubmenu('~O~ptions', hcnocontext, newmenu(
               newitem('~T~oggle Video', '', kbnokey, cmoptionsvideo, hcnocontext,
               newitem('Ascii ~C~hart', '', kbnokey, cmasciitab, hcnocontext,
               nil))),
             newsubmenu('~W~indow', hcnocontext, newmenu(
               stdwindowmenuitems(nil)),
             newsubmenu('~H~elp', hcnocontext, newmenu(
               newitem('~G~eneral Help', '', kbnokey, cmhelp, hcnocontext,
               newitem('~A~bout', '', kbnokey, cmabout, hcnocontext,
               nil))), nil))))))));
     end;

procedure tosteapp.doaboutbox;
begin
     messagebox(#3'­Ÿ„œ‡¢¤!''s Over Simplistic Text Editor'#13 +
       #3'OSTE v. .01 beta',
       nil, mfinformation or mfokbutton);
end;

constructor tosteapp.init;
var
   r: trect;
begin
     maxheapsize := 6000;
     editordialog := stdeditordialog;
     inherited init;
     desktop^.getextent(r);
     ClipboardWindow := new(peditwindow, init(r, '', wnnonumber));
     if validview(clipboardwindow) <> nil then
     begin
       clipboardwindow^.hide;
       insert(clipboardwindow);
       clipboard := clipboardwindow^.editor;
       clipboard^.canundo := false;
     end;
end;

procedure tosteapp.newwindow;
var
   r: trect;
   thewindow: peditwindow;
begin
     r.assign(0,0,80,23);
     new(thewindow, init(r, '', wnnonumber));
     insertwindow(thewindow);
end;

procedure tosteapp.openwindow;
var
   r: trect;
   filedialog: pfiledialog;
   thefile: fnamestr;
const
     fdoptions: word = fdokbutton or fdopenbutton;
begin
     thefile := '*.*';
     new(filedialog, init(thefile, 'Open File', 'File ~N~ame',
       fdoptions, 1));
     if executedialog(filedialog, @thefile) <> cmcancel then
     begin
          r.assign(0,0,80,23);
          insertwindow(new(peditwindow, init(r, thefile, wnnonumber)));
     end;
end;

procedure tosteapp.handleevent(var event: tevent);
begin
     inherited handleevent(event);
     if event.what = evcommand then
     case event.command of
          cmoptionsvideo:
            begin
                 setscreenmode(screenmode xor smfont8x8);
                 clearevent(event);
            end;
          cmabout:
            begin
                 doaboutbox;
                 clearevent(event);
            end;
         cmnew:
           begin
                newwindow;
                clearevent(event);
           end;
        cmopen:
           begin
                openwindow;
                clearevent(event);
           end;
        cmasciitab:
           begin
                asciichart;
           end;
        cmscreensaver:
           begin
               ss;
           end;
        cmchangedir:
           begin
              changedir;
           end;
        cmhelp:
           begin
              help;
           end;
     end;
  end;

{function menucoloritems(const next: pcoloritem): pcoloritem;
begin
     menucoloritems :=
                    coloritem('Normal',                 2,
                    coloritem('Disabled',               3,
                    coloritem('Shortcut',               4,
                    coloritem('Selected',               5,
                    coloritem('Selected Disabled',      6,
                    coloritem('Shortcut Selected',      7,
                    next))))));
end;}

{Ascii Chart Was Taking from Borland's TVDEMO.PAS and Uses Borland's
asciitab.tpu}

procedure tosteapp.Asciichart;
var
  P: PAsciiChart;
begin
  P := New(PAsciiChart, Init);
  P^.HelpCtx := hcAsciiTable;
  insertwindow(P);
end;

procedure tosteapp.help;
begin
       messagebox(#3'The Help System Has not yet been coded'#13 +
       #3'PLEASE read oste.doc for all questions.',
       nil, mfinformation or mfokbutton);
end;

procedure tosteapp.ChangeDir;
var
  D: PChDirDialog;
begin
  D := New(PChDirDialog, Init(cdNormal + cdHelpButton, 101));
  D^.HelpCtx := hcFCChDirDBox;
  ExecuteDialog(D, nil);
end;

procedure tosteapp.ss;
begin
end;

procedure title;
{$I title.pas}
begin
  clrscr;
  move (title,screen,4000);
  repeat until keypressed;
end;

begin
     title;
     osteapp.init;
     osteapp.run;
     osteapp.done;
end.