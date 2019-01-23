object Form1: TForm1
  Left = 315
  Top = 230
  BorderStyle = bsSingle
  Caption = 'Form1'
  ClientHeight = 36
  ClientWidth = 269
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object BitBtn1: TBitBtn
    Left = 8
    Top = 8
    Width = 89
    Height = 25
    Caption = 'Open and Play'
    TabOrder = 0
    OnClick = BitBtn1Click
  end
  object BitBtn3: TBitBtn
    Left = 96
    Top = 8
    Width = 73
    Height = 25
    Caption = 'Stop'
    TabOrder = 1
    OnClick = BitBtn3Click
  end
  object BitBtn4: TBitBtn
    Left = 168
    Top = 8
    Width = 89
    Height = 25
    Caption = 'Pause/Resume'
    TabOrder = 2
    OnClick = BitBtn4Click
  end
  object OpenDialog1: TOpenDialog
    Left = 240
    Top = 8
  end
end
