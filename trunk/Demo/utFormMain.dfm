object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 361
  ClientWidth = 670
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 160
    Top = 160
    Width = 203
    Height = 25
    Caption = 'Create DemoPlugIn1 and Save'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 424
    Top = 160
    Width = 169
    Height = 25
    Caption = 'Create DemoPlug1 && 2 and Save'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 160
    Top = 216
    Width = 203
    Height = 25
    Caption = 'Load DemoPlugIn1 FromFile'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 424
    Top = 216
    Width = 169
    Height = 25
    Caption = 'Load DemoPlug1 && 2 From File'
    TabOrder = 3
    OnClick = Button4Click
  end
end
