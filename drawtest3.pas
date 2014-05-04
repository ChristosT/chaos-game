program drawtest;

{$mode objfpc}{$H+}
{$Apptype GUI}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes,
  fpg_main,
  fpg_base,
  fpg_widget,
  fpg_form,
  fpg_progressbar,
  fpg_button,
  fpg_label,
  fpg_edit,
  fpg_trackBar,
  fpg_tab,
  fpg_radiobutton,
  Math;


type
  // progress event for TGraphComponent
  TProgressEvent = procedure(Sender: TObject; const ACount: integer) of object;


  TGraphComponent = class(TfpgWidget)
  private
    R: real;
    n: integer;
    m: integer;
//    i: longint;

    x2, y2,l1,l2: integer;
    results: array of integer;
    intS: array of array of integer;
    FOnProgress: TProgressEvent;
    
	    function    logos(c, b: integer): integer;
    procedure   DoOnProgress(const ACount: integer);
  protected
    procedure   HandlePaint; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure   DrawGraph(const ACount: integer;Ncount:integer;a:integer;b:integer;flag:boolean);
    property    OnProgress: TProgressEvent read FOnProgress write FOnProgress;
  end;


  TMainForm = class(TfpgForm)
  private
    {@VFD_HEAD_BEGIN: MainForm}
    ProgressBar1: TfpgProgressBar;
    btnStart: TfpgButton;
	btnQuit: TfpgButton;
	btnHelp:TfpgButton;
    Custom1: TGraphComponent;
    EditInteger1: TfpgEditInteger;
	EditInteger2: TfpgEditInteger;
	EditInteger3: TfpgEditInteger;
	EditInteger4: TfpgEditInteger;
    Label1: TfpgLabel;
	Label2: TfpgLabel;
	Label3: TfpgLabel;
	Label4: TfpgLabel;
		rbBlack: TfpgRadioButton;
    rbColored: TfpgRadioButton;
    {@VFD_HEAD_END: MainForm}
    procedure btnStartClicked(Sender: TObject);
	procedure   btnCloseClick(Sender: TObject);
	procedure   btnHelpClick(Sender: TObject);
    procedure Custom1Progress(Sender: TObject; const ACount: integer);
  public
    procedure AfterCreate; override;
  end;

  THelpForm = class(TfpgForm)
  private
  {@VFD_HEAD_BEGIN: thelpform}
    
    pcMain: TfpgPageControl;
    tsOne: TfpgTabSheet;
    tsTwo: TfpgTabSheet;
    tsThree: TfpgTabSheet;
	labelH1:TfpgLabel;
	labelH2:TfpgLabel;
	labelH3:TfpgLabel;
	labelH32:TfpgLabel;
	  {@VFD_HEAD_END: Thelpform}
     
  public
    constructor Create(AOwner: TComponent); override;
  end;
  
  Var
  ColorME: array [1..50] of TfpgColor;
color:boolean; 
wG,hG,w:integer; 


procedure TMainForm.btnCloseClick(Sender: TObject);
begin
  Close;
end;
procedure TMainForm.btnHelpClick(Sender: TObject);
Var
  frm: THelpForm;
begin
  fpgApplication.Initialize;
  frm := ThelpForm.Create(nil);
  frm.Show;
  fpgApplication.Run;
  frm.Free;
end;

function TGraphComponent.logos(c, b: integer): integer;
begin
  Result := (l1*c+(l2-l1)*b) div (l2)
end;

procedure TGraphComponent.DoOnProgress(const ACount: integer);
begin
  if Assigned(FOnProgress) and ((ACount mod 1000) = 0) then
    FOnProgress(self, ACount);
end;

procedure TGraphComponent.HandlePaint;
var
  x, y, u: real;
  k,pleura: integer;
  i: integer;
begin
    //inherited    HandlePaint;

  { We are doing all the painting, so no need to call inherited }
  Canvas.Clear(clWhite);

  // Only paint when we called DrawGraph - all other times it will blank component.
  if Tag = 0 then
   Exit;
  
  
	if (l1<0) XOR (l2<0) then
  begin  
 pleura:=round(150/868 *hG);
 R:=intpower(pleura,n) ; //Μετά απο δοκιμές
 end
 else
 begin 
 pleura:=round(420/868 *hG);
 R:=intpower(pleura,n);
  end;

  k := 0;
  u := pi / 2;
  for i := 1 to n do
  begin
    x := power(R, (1 / n)) * cos(((2 * k * pi + u) / n)) + wG/2;
    y := power(R, (1 / n)) * sin(((2 * k * pi + u) / n)) + hG/2;
    ints[i, 1] := trunc(x);
    ints[i, 2] := trunc(y);
    k := k + 1;

  end;{For-loop}
  
  Canvas.SetColor(clBlack);
  Canvas.DrawLine(intS[1, 1], intS[1, 2], intS[n, 1], intS[n, 2]);
  for i := 2 to n do
    Canvas.DrawLine(intS[i - 1, 1], intS[i - 1, 2], ints[i, 1], intS[i, 2]);

  { if m is very big (e.g 1000000) the user gets a black screen until
    all the points are drawn }
  X2 := 500;
  y2 := 500;
  for i := 1 to m do
  begin
    results[i] := random(n) + 1;
    x2 := logos(x2, intS[results[i], 1]);
    y2 := logos(y2, intS[results[i], 2]);
	if color= false then
		  
		  Canvas.Pixels[x2, y2] := colorMe[1]
		else
		
		Canvas.Pixels[x2, y2] := colorME[results[i]];
    DoOnProgress(i);
  end;{For-loop}
  

end;

constructor TGraphComponent.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  //PreCalculations;
end;

procedure TGraphComponent.DrawGraph(const ACount: integer;Ncount:integer;a:integer;b:integer;flag:boolean);
begin
  Tag := 1;
  m := ACount;
  n:=Ncount;
  l1:=a;
  l2:=b;
  if flag= true then 
  color:= true
  else 
  color:=false;
//    results: array [1..m] of integer;
//    intS:    array[1..m, 1..2] of integer;
  SetLength(results, m+1);
  Setlength(intS, m+1, 3);
 
 Invalidate;
 Tag := 0; 

end;

{ TMainForm }

procedure TMainForm.btnStartClicked(Sender: TObject);

begin
  wG:=width-100;
    hG:=height-100;
    with Custom1 do
  begin
    SetPosition(108, 0, wG, hG);
    Anchors := [anLeft,anBottom];
   
 end;
  ProgressBar1.Position := 0;
  fpgApplication.ProcessMessages;
  Custom1.DrawGraph(EditInteger1.Value,EditInteger2.Value,EditInteger3.Value,EditInteger4.Value,rbColored.Checked);
  
end;

procedure TMainForm.Custom1Progress(Sender: TObject; const ACount: integer);
var
  p: integer;
begin
  // calculate percentage complete.
  p := Trunc((ACount / EditInteger1.Value) * 100);
  ProgressBar1.Position := p;
end;

procedure TMainForm.AfterCreate;


begin
  {%region 'Auto-generated GUI code' -fold}
  {@VFD_BODY_BEGIN: MainForm}
  
  Name := 'MainForm';
   SetPosition(10, 25, 1024, 768);
   w:=width;
  WindowTitle := 'Παιχνίδι του Χάους ';
  Sizeable := True;
  
   ProgressBar1 := TfpgProgressBar.Create(self);
  with ProgressBar1 do
  begin
    Name := 'ProgressBar1';
    SetPosition(392, 724, round(456/1024*w), 22);
    Anchors := [AnRight,AnBottom];
    Max := 100;
  end;


  btnStart := TfpgButton.Create(self);
  with btnStart do
  begin
    Name := 'btnStart';
    SetPosition(12, 280, 80, 24);
    Text := 'Εκκίνηση';
    FontDesc := '#Label1';
    //Anchors := [anLeft,anBottom];
    Hint := '';
    ImageName := '';
    TabOrder := 1;
    OnClick := @btnStartClicked;
  end;
  
   btnQuit := TfpgButton.Create(self);
  with btnQuit do
  begin
    Name := 'btnQuit';
    SetPosition(10, 700, 80, 24);
    Text := 'Έξοδος';
	FontDesc := '#Label1';
	Anchors := [anLeft,anBottom];
    Hint := '';
    ImageName := 'stdimg.exit';
    TabOrder := 1;
    OnClick := @btnCloseClick;
  end;

   btnHelp := TfpgButton.Create(self);
  with btnHelp do
  begin
    Name := 'btnHelp';
    SetPosition(10, 670, 80, 24);
    Text := 'Βοήθεια';
	FontDesc := '#Label1';
	 Anchors := [anLeft,anBottom];
    Hint :=' ';
    ImageName := 'stdimg.help';
    TabOrder := 1;
    OnClick := @btnHelpClick;
  end;

  Custom1 := TGraphComponent.Create(self);
  with Custom1 do
  begin
    Name := 'Custom1';
    SetPosition(108, 0, 924, 668);
    Anchors := [anLeft,anBottom];
    OnProgress  := @Custom1Progress;
  end;

  EditInteger1 := TfpgEditInteger.Create(self);
  with EditInteger1 do
  begin
    Name := 'EditInteger1';
    SetPosition(12, 80, 80, 24);
    TabOrder := 3;
    FontDesc := '#Edit1';
  //  Anchors := [anLeft,anBottom];
    Value := 10000;
  end;
  
   EditInteger2 := TfpgEditInteger.Create(self);
  with EditInteger2 do
  begin
    Name := 'EditInteger2';
    SetPosition(32, 140, 60, 24);
    TabOrder := 3;
   FontDesc := '#Edit1';
   // Anchors := [anLeft,anBottom];
    Value := 3;
  end;
  
     EditInteger3 := TfpgEditInteger.Create(self);
  with EditInteger3 do
  begin
    Name := 'EditInteger3';
    SetPosition(42, 200, 55, 24);
    TabOrder := 3;
    FontDesc := '#Edit1';
   // Anchors := [anLeft,anBottom];
    Value := 1;
  end;
  
     EditInteger4 := TfpgEditInteger.Create(self);
  with EditInteger4 do
  begin
    Name := 'EditInteger4';
    SetPosition(42, 230, 55, 24);
    TabOrder := 3;
    FontDesc := '#Edit1';
    //Anchors := [anLeft,anBottom];
    Value := 2;
  end;

  Label1 := TfpgLabel.Create(self);
  with Label1 do
  begin
    Name := 'Label1';
    SetPosition(4, 60, 100, 16);
    FontDesc := '#Label1';
   // Anchors := [anLeft,anBottom];
    Hint := '';
    Text := 'πλήθος σημείων';
  end;
 Label2 := TfpgLabel.Create(self);
  with Label2 do
  begin
    Name := 'Label2';
    SetPosition(4, 120, 104, 16);
    FontDesc := '#Label1';
  //  Anchors := [anLeft,anBottom];
    Hint := '';
    Text := 'πλήθος κορυφών';
  end; 
  
  Label3 := TfpgLabel.Create(self);
  with Label3 do
  begin
    Name := 'Label3';
    SetPosition(8, 200, 20, 20);
    FontDesc := '#Label1';
   // Anchors := [anLeft,anBottom];
    Hint := '';
    Text := 'α = ';
  end; 
  
  Label4 := TfpgLabel.Create(self);
  with Label4 do
  begin
    Name := 'Label4';
    SetPosition(8, 235, 20, 20);
    FontDesc := '#Label1';
    //Anchors := [anLeft,anBottom];
    Hint := '';
    Text := 'β = ';
  end;
  
  
 rbBlack := TfpgRadioButton.Create(self);
  with rbBlack do
  begin
    Name := 'rbBlack';
    SetPosition(8, 335, 100, 20);
    Checked := True;
    FontDesc := '#Label1';
   // Anchors := [anLeft,anBottom];
    GroupIndex := 0;
    TabOrder := 0;
    Text := 'Μαύρο';
  end;

  rbColored := TfpgRadioButton.Create(self);
  with rbColored do
  begin
    Name := 'rbColored';
    SetPosition(8, 365, 100, 20);
    FontDesc := '#Label1';
    //Anchors := [anLeft,anBottom];
    GroupIndex := 0;
    TabOrder := 0;
    Text := 'Έγχρωμο';
	
  end;
   {@VFD_BODY_END: MainForm}
  {%endregion}
end;

constructor ThelpForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  WindowTitle := 'Βοήθεια';
  SetPosition(100, 320, 566, 450);
  Sizeable := False;
  

  pcMain := TfpgPageControl.Create(self);
  pcMain.Top      := 10;
  pcMain.Left     := 10;
  pcMain.Width    := Width -20;
  pcMain.Height   := Height - 20;
  pcMain.Anchors  := [anLeft, anTop, anRight, anBottom];

  // Tab One
  tsOne := TfpgTabSheet.Create(pcMain);
  tsOne.Text := 'Tab One';
   tsOne.Text := 'Υπόμνημα';
     
    LabelH1 := TfpgLabel.Create(tsOne);
  with LabelH1 do
  begin
    Name := 'LabelH1';
    SetPosition(54, 40, 450,300 );
    FontDesc := '#Label1';
    Hint := '';
	Text := 'α/β : η απόσταση του  κάθε νέου σημείου από την κορυφή σε σχέση με την απόσταση του προηγούμενου σημείου'+
	#10#10'πλήθος κορυφών : ο αριθμός των κορυφών του κανονικού ν-γώνου '#10#10'πλήθος σημείων: το πλήθος των σημείων του πειράματος     ';
    WrapText := True;
  end;
   

  // Tab Two
  tsTwo := TfpgTabSheet.Create(pcMain);
  tsTwo.Text := 'Επεξήγηση';
          LabelH2 := TfpgLabel.Create(tsTwo);
  with LabelH2 do
  begin
    Name := 'LabelH2';
    SetPosition(54, 40, 450,340 );
    FontDesc := '#Label1';
    Hint := '';
   Text := 'Περιγραφή του πειράματος:'+#10#10'Το πρόγραμμα ξεκινά σχεδιάζοντας το επιθυμητό κανονικό πολύγωνο χρησιμοποιώντας τις μιγαδικές λύσεις της εξίσωσης z^ν = a.'+#10' Έπειτα ορίζει τυχαία ένα σημείο Α πάνω στο επίπεδο και στην συνέχεια ακολουθεί τον παρακάτω αλγόριθμό: '+
#10#10#10'Βήμα 1: Επιλέγουμε τυχαία ένα αριθμό από το 1 έως το ν'+#10#10'Βήμα 2: Ανάλογα με τον αριθμό που επιλέξαμε θέτουμε ως'+' νέες συντεταγμένες του Α αυτές του  α/β (α,β ακεραίοι)της απόστασης ΑΜ_ν όπου Μ_ν η εικόνα της νιοστής ρίζας της εξίσωσης '+
#10#10'Βήμα 3:Πηγαίνουμε στο βήμα 1'+#10#10'Σημείωση:Ο αλγόριθμος επαναλαμβάνεται όσες φορές του υποδεικνύει η οριζόμενη από τον χρήστη μεταβλητή πλήθος' ;
    WrapText := True;
  end;

// Tab Three
tsThree := TfpgTabSheet.Create(pcMain);
  tsThree.Text := 'Πληροφορίες';
          LabelH3 := TfpgLabel.Create(tsThree);
 with LabelH3 do
  begin
    Name := 'LabelH3';
    SetPosition(150, 40, 450,340 );
    FontDesc := '#Label2';
    Hint := '';
   Text := ' ChaosGame 1.0 - Παιχνίδι του Χάους ' ;
    WrapText := True;
  end;
      
          LabelH32 := TfpgLabel.Create(tsThree);
 with LabelH32 do
  begin
    Name := 'LabelH32';
    SetPosition(50, 80, 450,340 );
    FontDesc := '#Label1';
    Hint := '';
   Text := '                     Πρόγραμμα Προσομοίωσης του Παιχνιδιού του Χάους '+#10#10#10#10#10+'Τσολάκης Χρήστος'#10'email: youkol123@gmail.com' ;
    WrapText := True;
  end;
  
  pcMain.ActivePage := tsOne; 
end;
// -----------------------------------------
procedure MainProc;
var
  frm: TMainForm;
begin
  fpgApplication.Initialize;
  frm := TMainForm.Create(nil);
  //try
    frm.Show;
    fpgApplication.Run;
 // finally
    frm.Free;
//  end;
end;

procedure SetColors;
begin
 ColorME[1]:=TfpgColor($000000); //Black
ColorME[2]:=TfpgColor($0000FF);	//Blue
ColorME[3]:=TfpgColor($FF0000); //Red
ColorME[4]:=TfpgColor($FFFF00);//Yeloow
ColorME[5]:=TfpgColor($00FFFF);//Aqua
ColorME[6]:=TfpgColor($008000);//Green
ColorME[7]:=TfpgColor($3299CC);//Sky Blue                   #                                #
ColorME[8]:=TfpgColor($8C1717);//Scarlet 
ColorME[9]:=TfpgColor($871F78);//Dark Purple  #
ColorME[10]:=TfpgColor($00FF00);//Lime
ColorME[11]:=TfpgColor($70DB93);//Aquamarine
ColorME[12]:=TfpgColor($5C3317);//Baker's Chocolate 
ColorME[13]:=TfpgColor($9F5F9F);//Blue Violet
ColorME[14]:=TfpgColor($A62A2A);//Brown #
ColorME[15]:=TfpgColor($CD7F32);//Gold                                             
ColorME[16]:=TfpgColor($BC8F8F);//Pink                                             
ColorME[17]:=TfpgColor($C0C0C0);//Grey                                             
ColorME[18]:=TfpgColor($4F2F4F);//Violet                                           #Violet                                           #
ColorME[19]:=TfpgColor($FF00FF);//Fuchsia                                        #
ColorME[20]:=TfpgColor($99CC32);//Yellow Green                                     #


end;


begin//Main Program
SetColors();
  Randomize;
  MainProc;
end.
