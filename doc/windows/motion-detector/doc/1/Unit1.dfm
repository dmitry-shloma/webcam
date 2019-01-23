object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1044#1077#1090#1077#1082#1090#1086#1088' '#1076#1074#1080#1078#1077#1085#1080#1103' ('#1074#1077#1088#1089#1080#1103' 0.5 '#1086#1090' 05.02.2007 '#1075'.)'
  ClientHeight = 280
  ClientWidth = 487
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label5: TLabel
    Left = 448
    Top = 125
    Width = 20
    Height = 13
    Caption = '0 %'
  end
  object Label1: TLabel
    Left = 352
    Top = 125
    Width = 92
    Height = 13
    Caption = #1048#1079#1084#1077#1085#1077#1085#1080#1077' '#1082#1072#1076#1088#1072':'
  end
  object Bevel1: TBevel
    Left = 353
    Top = 42
    Width = 128
    Height = 3
    Shape = bsTopLine
  end
  object Bevel2: TBevel
    Left = 353
    Top = 110
    Width = 128
    Height = 3
    Shape = bsTopLine
  end
  object Button1: TButton
    Left = 352
    Top = 11
    Width = 128
    Height = 25
    Caption = #1042#1082#1083#1102#1095#1080#1090#1100' '#1082#1072#1084#1077#1088#1091
    TabOrder = 0
    OnClick = Button1Click
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 338
    Height = 266
    Caption = #1052#1086#1085#1080#1090#1086#1088' '#8470' 1'
    TabOrder = 1
    object Shape1: TShape
      Left = 8
      Top = 16
      Width = 322
      Height = 242
    end
  end
  object Button2: TButton
    Left = 353
    Top = 50
    Width = 128
    Height = 25
    Caption = #1048#1089#1090#1086#1095#1085#1080#1082' '#1074#1080#1076#1077#1086
    Enabled = False
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 353
    Top = 80
    Width = 128
    Height = 25
    Caption = #1060#1086#1088#1084#1072#1090' '#1074#1080#1076#1077#1086
    Enabled = False
    TabOrder = 3
    OnClick = Button3Click
  end
  object XPManifest: TXPManifest
    Left = 392
    Top = 184
  end
end
