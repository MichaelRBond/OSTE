program Over_Simplistic_Text_Editor;

uses app, objects, menus, drivers, views, tutconst, msgbox, memory, editors,
     stddlg, crt, colorsel, dos, dialogs, ostecmds, asciitab, ostehelp;

type
    screentype = array [0..3999] of byte;

type
    tosteapp = object(tapplication)
    clipboardwindow: peditwindow;
    constructor init;
    procedure initstatusline;                                    virtual;
    procedure initmenubar;                                       virtual;
    procedure outofmemory;                                       virtual;
    procedure doaboutbox;                                        virtual;
    procedure handleevent(var event: tevent);                    virtual;
    procedure newwindow;                                         virtual;
    procedure openwindow;                                        virtual;
    procedure asciichart;                                        virtual;
    procedure ss;                                                virtual;
    procedure changedir;                                         virtual;
    procedure help;                                              virtual;
    procedure color_select;                                      virtual;
    procedure color_restore;                                     virtual;
    procedure del_dsk_file;                                      virtual;
    procedure color_save;                                        virtual;
    procedure storedesktop(var S: TStream);                      virtual;
    procedure loaddesktop(var S: TStream);                       virtual;
    {procedure screen_saver;                                      virtual;}
    procedure cmd_line_open;                                     virtual;
    {procedure print;                                             virtual;}
    {procedure FileOpen(WildCard: PathStr); virtual;
    function OpenEditor(FileName: FNameStr; Visible: Boolean): PEditWindow; virtual;}

end;

const
  signatureLen = 21;
  dsksignature : string[signatureLen] = 'oSTe Color Information File'#26;

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
end;

procedure tosteapp.initmenubar;
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
             newsubmenu('~S~earch', hcnocontext, newmenu(
               newitem('~S~earch', '', kbnokey, cmfind, hcnocontext,
               newitem('~R~eplace', '', kbnokey, cmreplace, hcnocontext,
               nil))),
             newsubmenu('~O~ptions', hcnocontext, newmenu(
               newitem('~T~oggle Video', '', kbnokey, cmoptionsvideo, hcnocontext,
               newitem('~A~scii Chart', '', kbnokey, cmasciitab, hcnocontext,
               newitem('~C~olor Selection', '', kbnokey, cmcolorselect, hcnocontext,
               newitem('~P~rint', '', kbnokey, cmprint, hcnocontext,
              nil))))),
             newsubmenu('~W~indow', hcnocontext, newmenu(
               stdwindowmenuitems(nil)),
             newsubmenu('~H~elp', hcnocontext, newmenu(
               newitem('~D~ocuments for OSTE v. 1.0', '', kbnokey, cmhelp, hcnocontext,
               newitem('~A~bout', '', kbnokey, cmabout, hcnocontext,
               nil))), nil)))))))));
     end;

procedure tosteapp.doaboutbox;
begin
     messagebox(#3'Alternate Personality''s Over Simplistic Text Editor'#13 +
       #3'OSTE v. 1.0',
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
          {cmprint:
            begin
                 print;
            end;}
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
        cmcolorselect:
           begin
              color_select;
           end;
        cmsavecolor:
           begin
              del_dsk_file;
           end;
        cmrestorecolor:
           begin
              color_restore;
           end;
        {cmscreensaver:
           begin
              screen_saver;
           end;}
     end;
end;

{Ascii Chart Was Taking from Borland's TVDEMO.PAS and Uses Borland's
asciitab.tpu}

procedure tosteapp.Asciichart;
var
  p: pasciichart;
begin
  p := New(pasciichart, Init);
  p^.helpctx := hcasciitable;
  insertwindow(p);
end;

{**************************************************************************}
procedure tosteapp.help;
var
   i : word;
   r : trect;
   filedialog: pfiledialog;
   thefile: fnamestr;

const
     fdoptions: word = fdokbutton or fdopenbutton;

begin
   thefile := 'oste.doc';
   r.assign(0,0,80,23);
   insertwindow(new(peditwindow, init(r, 'oste.doc', wnnonumber)));
end;

procedure tosteapp.changedir;
var
  d: pchdirdialog;
begin
  d := new(pchdirdialog, init(cdnormal + cdhelpbutton, 101));
  d^.helpctx := hcfcchdirdbox;
  executedialog(d, nil);
end;

procedure tosteapp.color_select;
var
  d: pcolordialog;
begin
  d := new(pcolordialog, init('',
    colorGroup('Desktop',       desktopcoloritems(nil),
    colorGroup('Menus',         menucoloritems(nil),
    colorGroup('Dialogs',  dialogcoloritems(dpgraydialog, nil),
    colorGroup('Editor', windowcoloritems(wpbluewindow, nil),
    colorGroup('Ascii table',   windowcolorItems(wpgraywindow, nil),
          nil)))))));

  d^.helpctx := hcoccolorsdbox;

  if executedialog(d, application^.getpalette) <> cmcancel then
  begin
    donememory;
    redraw;
  end;
del_dsk_file;
end;

procedure tosteapp.loaddesktop(var s: tstream);
var
  p: pview;
  pal: pstring;

procedure closeview(p: pview); far;
begin
  message(p, evcommand, cmclose, nil);
end;

begin
  if desktop^.valid(cmclose) then
  begin
    desktop^.foreach(@closeview);
    repeat
      p := pview(s.get);
      desktop^.insertbefore(validview(p), desktop^.last);
    until p = nil;
    pal := s.readstr;
    if pal <> nil then
    begin
      application^.getpalette^ := pal^;
      donememory;
      application^.redraw;
      disposestr(pal);
    end;
  end;
end;

procedure tosteapp.color_restore;
var
  s: pstream;
  signature: string[signaturelen];
begin
  s := new(pbufstream, init('c:\oste\oste.dsk', stopenread, 1024));
  if s^.status <> stOk then
    messagebox('Move your oste files to c:\oste', nil, mfOkButton + mfError)
  else
  begin
    signature[0] := char(signaturelen);
    s^.read(signature[1], signaturelen);
    if signature = dsksignature then
    begin
      loaddesktop(s^);
      loadindexes(s^);
      if s^.status <> stOk then
        messagebox('Error reading desktop file', nil, mfOkButton + mfError);
    end
    else
      messagebox('Error: Invalid Desktop file.', nil, mfOkButton + mfError);
  end;
  dispose(s, done);
end;

procedure tosteapp.del_dsk_file;
begin
     exec('\command.com', '/c del c:\oste\oste.dsk');
     color_save;
end;

procedure tosteapp.color_save;
var
  s: pstream;
  f: File;
begin
  s := new(pbufstream, init('c:\oste\oste.dsk', stcreate, 1024));
  if not lowmemory and (s^.status = stOk) then
  begin
    s^.write(dsksignature[1], signaturelen);
    storedesktop(s^);
    storeindexes(s^);
    if s^.status <> stOk then
    begin
      messagebox('Could not create c:\oste\oste.dsk.', nil, mfOkButton + mfError);
      {$I-}
      dispose(s, done);
      assign(f, 'oste.dsk');
      erase(f);
      exit;
    end;
  end;
  dispose(s, done);
end;

procedure tosteapp.storedesktop(var S: TStream);
var
  pal: pstring;

procedure writeview(p: pview); far;
begin
  if p <> desktop^.last then s.put(p);
end;

begin
  desktop^.foreach(@writeview);
  s.put(nil);
  pal := @application^.getpalette^;
  s.writestr(pal);
end;

{procedure tosteapp.screen_saver;
begin
     clrscr;
     exec('','d:\bp\bigscree.exe');
end;}

procedure tosteapp.outofmemory;
begin
end;

procedure tosteapp.ss;
begin
end;

{procedure tosteapp.print;
var
   thefile : fnamestr;
   lst : text;
begin
     thefile := thefile;
     assign(lst, 'lpt1');
     rewrite(lst);
     writeln(lst, thefile);
     close(lst);
end;}

procedure title;
{$I title.pas}
begin
  clrscr;
  move (title,screen,4000);
  repeat until keypressed;
end;

procedure tosteapp.cmd_line_open;
var
   i : word;
   r : trect;
   filedialog: pfiledialog;
   thefile: fnamestr;

const
     fdoptions: word = fdokbutton or fdopenbutton;

begin
  for i := 1 to paramcount do
    thefile := 'paramstr(i)';
       r.assign(0,0,80,23);
       insertwindow(new(peditwindow, init(r, paramstr(i), wnnonumber)));
osteapp.run;
end;

procedure param_open;
begin
   if paramcount = 0 then
      osteapp.run
   else
      osteapp.cmd_line_open;
end;

begin
     title;
     osteapp.init;
     osteapp.color_restore;
     param_open;
     osteapp.done;
end.