object MainForm: TMainForm
  Left = 244
  Top = 266
  BorderStyle = bsDialog
  Caption = '-'
  ClientHeight = 509
  ClientWidth = 937
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
  object labelVideo: TLabel
    Left = 16
    Top = 8
    Width = 109
    Height = 13
    Caption = 'Video capture devices:'
  end
  object labelAudio: TLabel
    Left = 240
    Top = 8
    Width = 109
    Height = 13
    Caption = 'Audio capture devices:'
  end
  object labelVideoCompressor: TLabel
    Left = 16
    Top = 208
    Width = 127
    Height = 13
    Caption = 'Video compressor devices:'
  end
  object labelAudioCompressor: TLabel
    Left = 240
    Top = 208
    Width = 127
    Height = 13
    Caption = 'Audio compressor devices:'
  end
  object labelFileName: TLabel
    Left = 480
    Top = 360
    Width = 73
    Height = 13
    Caption = 'Path to AVI file:'
  end
  object panelVideo: TPanel
    Left = 472
    Top = 24
    Width = 449
    Height = 329
    Caption = 'VIDEO'
    Color = clGray
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clYellow
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
  end
  object listBoxVideo: TListBox
    Left = 16
    Top = 24
    Width = 209
    Height = 113
    ItemHeight = 13
    TabOrder = 1
    OnClick = listBoxVideoClick
  end
  object listBoxVideoCompressor: TListBox
    Left = 16
    Top = 224
    Width = 209
    Height = 241
    ItemHeight = 13
    TabOrder = 2
    OnClick = listBoxVideoCompressorClick
  end
  object listBoxAudio: TListBox
    Left = 240
    Top = 24
    Width = 209
    Height = 113
    ItemHeight = 13
    TabOrder = 3
    OnClick = listBoxAudioClick
  end
  object listBoxAudioCompressor: TListBox
    Left = 240
    Top = 224
    Width = 209
    Height = 241
    ItemHeight = 13
    TabOrder = 4
    OnClick = listBoxAudioCompressorClick
  end
  object panelRecord: TPanel
    Left = 472
    Top = 408
    Width = 449
    Height = 89
    TabOrder = 5
    object buttonStartCapture: TButton
      Left = 13
      Top = 24
      Width = 200
      Height = 49
      Caption = 'START'
      TabOrder = 0
      OnClick = buttonStartCaptureClick
    end
    object buttonStopCapture: TButton
      Left = 237
      Top = 24
      Width = 200
      Height = 49
      Caption = 'STOP'
      TabOrder = 1
      OnClick = buttonStopCaptureClick
    end
  end
  object editFileName: TEdit
    Left = 500
    Top = 376
    Width = 401
    Height = 21
    TabOrder = 6
    Text = 'c:\test.avi'
  end
  object checkBoxPreview: TCheckBox
    Left = 851
    Top = 6
    Width = 71
    Height = 17
    Caption = 'PREVIEW'
    Checked = True
    State = cbChecked
    TabOrder = 7
    OnClick = checkBoxPreviewClick
  end
  object buttonVideoProperties: TButton
    Left = 16
    Top = 144
    Width = 209
    Height = 25
    Caption = 'Video capture device properties'
    TabOrder = 8
    OnClick = buttonVideoPropertiesClick
  end
  object buttonVideoCompressorProperties: TButton
    Left = 16
    Top = 472
    Width = 209
    Height = 25
    Caption = 'Video compressor device properties'
    TabOrder = 9
    OnClick = buttonVideoCompressorPropertiesClick
  end
  object buttonAudioProperties: TButton
    Left = 240
    Top = 144
    Width = 209
    Height = 25
    Caption = 'Audio capture device properties'
    TabOrder = 10
    OnClick = buttonAudioPropertiesClick
  end
  object buttonAudioCompressorProperties: TButton
    Left = 240
    Top = 472
    Width = 209
    Height = 25
    Caption = 'Audio compressor device properties'
    TabOrder = 11
    OnClick = buttonAudioCompressorPropertiesClick
  end
  object buttonVideoPinProperties: TButton
    Left = 16
    Top = 176
    Width = 209
    Height = 25
    Caption = 'Video capture pin properties'
    TabOrder = 12
    OnClick = buttonVideoPinPropertiesClick
  end
  object buttonFileName: TButton
    Left = 900
    Top = 376
    Width = 21
    Height = 21
    Caption = '...'
    TabOrder = 13
    OnClick = buttonFileNameClick
  end
  object saveDialogMain: TSaveDialog
    DefaultExt = 'avi'
    Filter = 'AVI file|*.avi'
    Left = 888
    Top = 320
  end
end
