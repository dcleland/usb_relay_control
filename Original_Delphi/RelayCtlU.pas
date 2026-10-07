unit RelayCtlU;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, JvHidControllerClass, Vcl.ExtCtrls, Vcl.Buttons,
  Vcl.Samples.Spin, Vcl.ComCtrls, Vcl.CategoryButtons;

type
  TRLButtons = record
    Buttons: array [0..15] of TSpeedButton;
  end;

  THidRlyForm = class(TForm)
    HidCtl: TJvHidDeviceController;
    Panel2: TPanel;
    Panel1: TPanel;
    lbBoards: TListBox;
    Panel3: TPanel;
    Log: TMemo;
    PC: TPageControl;
    tsChannelButtons: TTabSheet;
    tsAllOn: TTabSheet;
    BtnPan: TPanel;
    Label1: TLabel;
    buAllOn: TButton;
    buAllOff: TButton;
    seRelNo: TSpinEdit;
    buOn: TButton;
    buOff: TButton;
    Panel4: TPanel;
    sb1On: TSpeedButton;
    sb1Off: TSpeedButton;
    sb2On: TSpeedButton;
    sb2Off: TSpeedButton;
    sb3On: TSpeedButton;
    sb3Off: TSpeedButton;
    sb4On: TSpeedButton;
    sb4Off: TSpeedButton;
    Sb5On: TSpeedButton;
    sb5Off: TSpeedButton;
    sb6On: TSpeedButton;
    sb6Off: TSpeedButton;
    sb7On: TSpeedButton;
    sb7Off: TSpeedButton;
    sb8On: TSpeedButton;
    sb8Off: TSpeedButton;
    Panel5: TPanel;
    Panel6: TPanel;
    procedure FormActivate(Sender: TObject);
    function HidCtlEnumerate(HidDev: TJvHidDevice; const Idx: Integer): Boolean;
    procedure HidCtlDeviceChange(Sender: TObject);
    procedure buAllOnClick(Sender: TObject);
    procedure sb1OnClick(Sender: TObject);
    procedure PCChange(Sender: TObject);
  private
    RlTtl: TPanel;
    function GetButtonStatus: Byte;
    function SendCmd(Relay, Mode: Byte): String;
    procedure InitButtons(var ButtonList: TRLButtons);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HidRlyForm: THidRlyForm;

implementation

{$R *.dfm}

const
  DEVICENAME = 'USBRelay'; // Base name for report ProductName
  Cmds:       array [0..3] of Byte = ({On}  $FF, {Off}  $FD,  {All ON} $FE, {All OFF} $FC);
  SubCmds:    array [0..1] of Byte = ({Off} $FD, {On}   $FF);

procedure THidRlyForm.InitButtons(var ButtonList: TRLButtons);
begin
  ButtonList.Buttons[ 0] := sb1On;
  ButtonList.Buttons[ 1] := sb1Off;
  ButtonList.Buttons[ 2] := sb2On;
  ButtonList.Buttons[ 3] := sb2Off;
  ButtonList.Buttons[ 4] := sb3On;
  ButtonList.Buttons[ 5] := sb3Off;
  ButtonList.Buttons[ 6] := sb4On;
  ButtonList.Buttons[ 7] := sb4Off;
  ButtonList.Buttons[ 8] := sb5On;
  ButtonList.Buttons[ 9] := sb5Off;
  ButtonList.Buttons[10] := sb6On;
  ButtonList.Buttons[11] := sb6Off;
  ButtonList.Buttons[12] := sb7On;
  ButtonList.Buttons[13] := sb7Off;
  ButtonList.Buttons[14] := sb8On;
  ButtonList.Buttons[15] := sb8Off;
end;

function THidRlyForm.GetButtonStatus: Byte;
var
  Btns:  TRLButtons;
  Dev: TJvHidDevice;
  pB: pByte;
  Status: Boolean;
  Sb, i: Byte;
begin
  if lbBoards.Count > 0 then
  begin
    Dev := TJvHidDevice(lbBoards.Items.Objects[lbBoards.ItemIndex]);

    try
      pB := AllocMem(10);

       pB^      := 0;
      (pB + 1)^ := 0;
      (pB + 2)^ := 0;

      Status := Dev.GetFeature(pB^, 9);
      if Status  then
      begin
        Sb := (pB + 8)^;
        InitButtons(Btns);

        for i := 0 to 7 do
        begin
          Btns.Buttons[(i * 2)    ].Down :=     Boolean(Sb and 1);
          Btns.Buttons[(i * 2) + 1].Down := not Boolean(Sb and 1);
          Sb := Sb shr 1;
        end;
      end;
    finally
      FreeMem(pB);
    end;
  end;
end;

procedure THidRlyForm.buAllOnClick(Sender: TObject);
begin
  Log.Lines.Add(SendCmd(seRelNo.Value, Cmds[TWinControl(Sender).Tag - 1]));
end;

procedure THidRlyForm.FormActivate(Sender: TObject);
var
  i: Integer;
begin
  HidCtlDeviceChange(Self);
  PC.TabIndex := 0;
end;

// free all board objects, clear board list and re-enumerate boards
procedure THidRlyForm.HidCtlDeviceChange(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to lbBoards.Items.Count - 1 do
    TJvHidDevice(lbBoards.Items.Objects[i]).Free;

  lbBoards.Clear;
  Log.Clear;

  Log.Lines.Add(Format('-- %s --', [DateTimeToStr(Now)]));
  HidCtl.Enumerate;

//  Select the first board
  if lbBoards.Count = 0 then
    Log.Lines.Add('No relay boards present')
  else
    lbBoards.ItemIndex := lbBoards.Count - 1;

  BtnPan.Enabled := (lbBoards.Count > 0);
end;

function THidRlyForm.HidCtlEnumerate(HidDev: TJvHidDevice; const Idx: Integer): Boolean;
var
  Bd: Integer;
begin
//  Show all USB devices in the log
  if HidDev.ProductName <> '' then
    Log.Lines.Add(HidDev.ProductName)
  else
    Log.Lines.Add(Format('VID=%4.4x, PID=%4.4x', [HidDev.Attributes.VendorID, HidDev.Attributes.ProductID]));

//  Select only the devices we are interested in
  if Copy(HidDev.ProductName, 1, Length(DEVICENAME)) = DEVICENAME then
  begin
    Bd := lbBoards.Count;
    Bd := lbBoards.Items.Add(Format('%d - %s', [Bd, HidDev.ProductName]));
    HidCtl.CheckOutByIndex(HidDev, Idx);
    lbBoards.Items.Objects[Bd] := HidDev;
  end;
//  Application.ProcessMessages;
  Result := True;
end;

procedure THidRlyForm.PCChange(Sender: TObject);
var
  Stat: Byte;
  i, j: Integer;
begin
  if PC.TabIndex = 1 then
    GetButtonStatus;
end;

procedure THidRlyForm.sb1OnClick(Sender: TObject);
var
  Ch: Integer;
  On: Byte;
begin
  Ch := ((TWinControl(Sender).Tag - 1) shr 1) + 1;
  On := (TWinControl(Sender).Tag and 1);

  Log.Lines.Add(SendCmd(Ch, SubCMds[On]));
end;

function THidRlyForm.SendCmd(Relay, Mode: Byte): String;
var
  pB: pByte;
  Dev:  TJvHidDevice;
  Status: Boolean;
begin
  Dev := TJvHidDevice(lbBoards.Items.Objects[lbBoards.ItemIndex]);
  try
    pB := AllocMem(10);

     pB^      := 0;
    (pB + 1)^ := Mode;
    (pB + 2)^ := Relay;

    Status := Dev.SetFeature(pB^, 9);

    if Status then
      Result := Format('%2.2x %2.2x %2.2x', [(pB + 0)^, (pB + 1)^, (pB + 2)^])
    else
      Result := 'Command not sent';

    Status := Dev.GetFeature(Pb^, 9);
    if Status then
      Result := Format('%s - %2.2x', [Result, (pB + 8)^]);
  finally
    FreeMem(pB);
  end;
end;

end.
