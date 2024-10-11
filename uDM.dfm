object DM: TDM
  Height = 480
  Width = 640
  object conexao: TFDConnection
    Params.Strings = (
      'Database=dbvarejo'
      'User_Name=root'
      'Password=root'
      'CharacterSet=utf8'
      'Server=localhost'
      'UseSSL=True'
      'DriverID=MySQL')
    LoginPrompt = False
    Left = 80
    Top = 40
  end
  object FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink
    Left = 56
    Top = 112
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 88
    Top = 112
  end
end
