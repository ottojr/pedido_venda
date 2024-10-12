object DM: TDM
  Height = 600
  Width = 800
  PixelsPerInch = 120
  object conexao: TFDConnection
    Params.Strings = (
      'Database=dbvarejo'
      'User_Name=root'
      'Password=root'
      'CharacterSet=utf8'
      'Server=localhost'
      'DriverID=MySQL')
    LoginPrompt = False
    Left = 100
    Top = 50
  end
  object FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink
    Left = 70
    Top = 140
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 110
    Top = 140
  end
end
