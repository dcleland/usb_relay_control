object HidRlyForm: THidRlyForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'HID Relay Control'
  ClientHeight = 367
  ClientWidth = 363
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 149
    Height = 361
    Align = alLeft
    Caption = 'Panel2'
    TabOrder = 0
    object Panel1: TPanel
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 140
      Height = 25
      Margins.Right = 4
      Align = alTop
      BevelInner = bvLowered
      Caption = 'Relay Boards Present'
      TabOrder = 0
    end
    object lbBoards: TListBox
      AlignWithMargins = True
      Left = 4
      Top = 35
      Width = 140
      Height = 322
      Margins.Right = 4
      Align = alClient
      ItemHeight = 13
      TabOrder = 1
    end
  end
  object Panel3: TPanel
    AlignWithMargins = True
    Left = 158
    Top = 3
    Width = 202
    Height = 361
    Align = alClient
    TabOrder = 1
    object Log: TMemo
      AlignWithMargins = True
      Left = 4
      Top = 193
      Width = 194
      Height = 164
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 0
    end
    object PC: TPageControl
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 194
      Height = 183
      ActivePage = tsChannelButtons
      Align = alTop
      TabOrder = 1
      TabPosition = tpBottom
      OnChange = PCChange
      object tsAllOn: TTabSheet
        Caption = 'On/Off'
        ImageIndex = 1
        object BtnPan: TPanel
          AlignWithMargins = True
          Left = 0
          Top = 0
          Width = 183
          Height = 154
          Margins.Left = 0
          Margins.Top = 0
          Align = alClient
          BevelInner = bvLowered
          ParentBackground = False
          TabOrder = 0
          object Label1: TLabel
            Left = 18
            Top = 110
            Width = 71
            Height = 13
            Caption = 'Relay Number:'
          end
          object buAllOn: TButton
            Tag = 3
            AlignWithMargins = True
            Left = 13
            Top = 14
            Width = 75
            Height = 25
            Caption = 'ALL ON'
            TabOrder = 0
            OnClick = buAllOnClick
          end
          object buAllOff: TButton
            Tag = 4
            AlignWithMargins = True
            Left = 94
            Top = 14
            Width = 75
            Height = 25
            Caption = 'ALL OFF'
            TabOrder = 1
            OnClick = buAllOnClick
          end
          object seRelNo: TSpinEdit
            Left = 95
            Top = 107
            Width = 37
            Height = 22
            AutoSize = False
            MaxValue = 8
            MinValue = 1
            TabOrder = 4
            Value = 1
          end
          object buOn: TButton
            Tag = 1
            Left = 13
            Top = 65
            Width = 75
            Height = 25
            Caption = 'ON'
            TabOrder = 2
            OnClick = buAllOnClick
          end
          object buOff: TButton
            Tag = 2
            Left = 94
            Top = 65
            Width = 75
            Height = 25
            Caption = 'OFF'
            TabOrder = 3
            OnClick = buAllOnClick
          end
          object Panel6: TPanel
            Left = 8
            Top = 49
            Width = 170
            Height = 5
            BevelInner = bvLowered
            TabOrder = 5
          end
        end
      end
      object tsChannelButtons: TTabSheet
        Caption = 'Button per Channel'
        object Panel4: TPanel
          AlignWithMargins = True
          Left = 0
          Top = 0
          Width = 184
          Height = 154
          Margins.Left = 0
          Margins.Top = 0
          Margins.Right = 2
          Align = alClient
          BevelInner = bvLowered
          ParentBackground = False
          TabOrder = 0
          object sb1On: TSpeedButton
            Tag = 1
            Left = 8
            Top = 36
            Width = 42
            Height = 22
            GroupIndex = 1
            Caption = '1 ON'
            OnClick = sb1OnClick
          end
          object sb1Off: TSpeedButton
            Tag = 2
            Left = 50
            Top = 36
            Width = 42
            Height = 22
            GroupIndex = 1
            Down = True
            Caption = '1 OFF'
            OnClick = sb1OnClick
          end
          object sb2On: TSpeedButton
            Tag = 3
            Left = 96
            Top = 36
            Width = 42
            Height = 22
            GroupIndex = 2
            Caption = '2 ON'
            OnClick = sb1OnClick
          end
          object sb2Off: TSpeedButton
            Tag = 4
            Left = 137
            Top = 36
            Width = 42
            Height = 22
            GroupIndex = 2
            Down = True
            Caption = '2 OFF'
            OnClick = sb1OnClick
          end
          object sb3On: TSpeedButton
            Tag = 5
            Left = 8
            Top = 64
            Width = 42
            Height = 22
            GroupIndex = 3
            Caption = '3 ON'
            OnClick = sb1OnClick
          end
          object sb3Off: TSpeedButton
            Tag = 6
            Left = 50
            Top = 64
            Width = 42
            Height = 22
            GroupIndex = 3
            Down = True
            Caption = '3 OFF'
            OnClick = sb1OnClick
          end
          object sb4On: TSpeedButton
            Tag = 7
            Left = 95
            Top = 64
            Width = 42
            Height = 22
            GroupIndex = 4
            Caption = '4 ON'
            OnClick = sb1OnClick
          end
          object sb4Off: TSpeedButton
            Tag = 8
            Left = 137
            Top = 64
            Width = 42
            Height = 22
            GroupIndex = 4
            Down = True
            Caption = '4 OFF'
            OnClick = sb1OnClick
          end
          object Sb5On: TSpeedButton
            Tag = 9
            Left = 8
            Top = 92
            Width = 42
            Height = 22
            GroupIndex = 5
            Caption = '5 ON'
            OnClick = sb1OnClick
          end
          object sb5Off: TSpeedButton
            Tag = 10
            Left = 50
            Top = 92
            Width = 42
            Height = 22
            GroupIndex = 5
            Down = True
            Caption = '5 OFF'
            OnClick = sb1OnClick
          end
          object sb6On: TSpeedButton
            Tag = 11
            Left = 95
            Top = 92
            Width = 42
            Height = 22
            GroupIndex = 6
            Caption = '6 ON'
            OnClick = sb1OnClick
          end
          object sb6Off: TSpeedButton
            Tag = 12
            Left = 137
            Top = 92
            Width = 42
            Height = 22
            GroupIndex = 6
            Down = True
            Caption = '6 OFF'
            OnClick = sb1OnClick
          end
          object sb7On: TSpeedButton
            Tag = 13
            Left = 8
            Top = 120
            Width = 42
            Height = 22
            GroupIndex = 7
            Caption = '7 ON'
            OnClick = sb1OnClick
          end
          object sb7Off: TSpeedButton
            Tag = 14
            Left = 50
            Top = 120
            Width = 42
            Height = 22
            GroupIndex = 7
            Down = True
            Caption = '7 OFF'
            OnClick = sb1OnClick
          end
          object sb8On: TSpeedButton
            Tag = 15
            Left = 95
            Top = 120
            Width = 42
            Height = 22
            GroupIndex = 8
            Caption = '8 ON'
            OnClick = sb1OnClick
          end
          object sb8Off: TSpeedButton
            Tag = 16
            Left = 137
            Top = 120
            Width = 42
            Height = 22
            GroupIndex = 8
            Down = True
            Caption = '8 OFF'
            OnClick = sb1OnClick
          end
          object Panel5: TPanel
            AlignWithMargins = True
            Left = 10
            Top = 5
            Width = 164
            Height = 25
            Margins.Left = 8
            Margins.Right = 8
            Align = alTop
            BevelInner = bvLowered
            Caption = 'Relay Channels'
            TabOrder = 0
          end
        end
      end
    end
  end
  object HidCtl: TJvHidDeviceController
    OnEnumerate = HidCtlEnumerate
    OnDeviceChange = HidCtlDeviceChange
    Left = 64
    Top = 80
  end
end
