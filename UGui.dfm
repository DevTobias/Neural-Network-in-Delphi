object Form1: TForm1
  Left = 0
  Top = 0
  ClientHeight = 435
  ClientWidth = 474
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 139
    Top = 100
    Width = 108
    Height = 102
    AutoSize = True
  end
  object Label1: TLabel
    Left = 253
    Top = 56
    Width = 51
    Height = 13
    Caption = 'Sicherheit:'
  end
  object Label2: TLabel
    Left = 139
    Top = 82
    Width = 30
    Height = 13
    Caption = 'Input:'
  end
  object Label3: TLabel
    Left = 139
    Top = 208
    Width = 45
    Height = 13
    Caption = 'Output: -'
  end
  object Label4: TLabel
    Left = 253
    Top = 75
    Width = 44
    Height = 13
    Caption = 'Quallit'#228't:'
  end
  object Label5: TLabel
    Left = 139
    Top = 226
    Width = 70
    Height = 13
    Caption = 'True Output: -'
  end
  object Button1: TButton
    Left = 253
    Top = 100
    Width = 108
    Height = 26
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 138
    Top = 25
    Width = 108
    Height = 26
    Caption = 'Button2'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 252
    Top = 25
    Width = 108
    Height = 25
    Caption = 'Button3'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 138
    Top = 245
    Width = 108
    Height = 25
    Caption = 'Button4'
    TabOrder = 3
    OnClick = Button4Click
  end
  object Edit1: TEdit
    Left = 139
    Top = 56
    Width = 108
    Height = 21
    TabOrder = 4
    Text = 'Edit1'
    TextHint = 'Datenbasis Index'
  end
  object ListBox1: TListBox
    Left = 24
    Top = 25
    Width = 108
    Height = 286
    ItemHeight = 13
    TabOrder = 5
  end
  object Edit2: TEdit
    Left = 253
    Top = 132
    Width = 109
    Height = 21
    TabOrder = 6
    Text = 'Edit2'
    TextHint = 'Lerndurchg'#228'nge'
  end
  object Button5: TButton
    Left = 312
    Top = 216
    Width = 75
    Height = 25
    Caption = 'Button5'
    TabOrder = 7
    OnClick = Button5Click
  end
  object Edit3: TEdit
    Left = 312
    Top = 189
    Width = 121
    Height = 21
    TabOrder = 8
    Text = 'Edit3'
  end
  object MainMenu1: TMainMenu
    Left = 352
    Top = 65528
    object File1: TMenuItem
      Caption = '&Datei'
      object New1: TMenuItem
        Caption = '&Neues Netzwerk'
      end
      object Open1: TMenuItem
        Caption = 'Netzwerk '#214'&ffnen...'
      end
      object Save1: TMenuItem
        Caption = 'Netzwerk &Speichern'
      end
      object SaveAs1: TMenuItem
        Caption = 'Netzwerk Speichern &unter...'
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = '&Beenden'
      end
    end
    object Help1: TMenuItem
      Caption = '&Hilfe'
      object Contents1: TMenuItem
        Caption = '&Inhalt'
      end
      object Index1: TMenuItem
        Caption = 'Inde&x'
      end
      object Commands1: TMenuItem
        Caption = '&Befehle'
      end
      object Procedures1: TMenuItem
        Caption = '&Anleitungen'
      end
      object Keyboard1: TMenuItem
        Caption = '&Tastatur'
      end
      object SearchforHelpOn1: TMenuItem
        Caption = '&Suchen'
      end
      object Tutorial1: TMenuItem
        Caption = '&Lernprogramm'
      end
      object HowtoUseHelp1: TMenuItem
        Caption = '&Hilfe verwenden'
      end
      object About1: TMenuItem
        Caption = 'In&fo...'
      end
    end
  end
end
