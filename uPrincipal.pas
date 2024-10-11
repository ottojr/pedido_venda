unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.IniFiles, System.SysUtils, 
  System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, 
  Vcl.Dialogs, uDM, Vcl.Buttons, Vcl.StdCtrls, 
  FireDAC.Comp.Client,
  FireDAC.Stan.Def,
  FireDAC.Stan.Async,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt, Vcl.ComCtrls, Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, Vcl.Grids, Vcl.DBGrids;
  
type
  TfrmPrincipal = class(TForm)
    GroupBox1: TGroupBox;
    edtCodCliente: TEdit;
    lblCodCliente: TLabel;
    btnPesquisarCliente: TSpeedButton;
    lblNomeCliente: TLabel;
    lblCidade_UFCliente: TLabel;
    StatusBar1: TStatusBar;
    GroupBox2: TGroupBox;
    DBGrid1: TDBGrid;
    qryVenda: TFDQuery;
    dsVenda: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnPesquisarClienteClick(Sender: TObject);
    procedure edtCodClienteKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    procedure LimpaDadosCliente;
    procedure GravarVenda;    
  public
    { Public declarations }
    function GetDMInstance: Tdm;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

uses Model.Cliente, Controller.Cliente, PedidoController;

function TfrmPrincipal.GetDMInstance: Tdm;
begin
  if not Assigned(dm) then
    dm := Tdm.Create(nil);
  Result := dm;
end; 

procedure TfrmPrincipal.LimpaDadosCliente;
begin
  edtCodCliente.Text          := '';
  lblNomeCliente.Caption      := '';
  lblCidade_UFCliente.Caption := '';
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
var
  fs: TFileStream;
  rs: TResourceStream;
  lslibmysql, lsConfigINI, lsFile : string;
  Ini: TIniFile; Server, Database, Username, Password, DriverLibrary: string; Port: Integer;  
begin
  lslibmysql := ExtractFilePath(Application.ExeName) + 'libmysql.dll';
  
  if not FileExists(lslibmysql) then
  begin
    try
      rs     := TResourceStream.Create(hInstance, 'RC1', RT_RCDATA);
      lsFile := lslibmysql;
      fs     := TFileStream.Create(lsFile,fmCreate);
      rs.SaveToStream(fs);
    finally
      FreeAndNil(fs);
      FreeAndNil(rs);
    end;
  end;

  lsConfigINI := ExtractFilePath(Application.ExeName) + 'config.ini';
  if not FileExists(lsConfigINI) then
  begin
    Ini := TIniFile.Create(lsConfigINI); 
    try
      Ini.WriteString('Database', 'Server', 'localhost'); 
      Ini.WriteInteger('Database', 'Port', 3306); 
      Ini.WriteString('Database', 'Database', 'dbvarejo'); 
      Ini.WriteString('Database', 'Username', 'root'); 
      Ini.WriteString('Database', 'Password', 'root'); 
      Ini.WriteString('Database', 'DriverLibrary', lslibmysql);
    finally
      FreeAndNil(Ini);
    end;
  end;  

  Ini := TIniFile.Create(lsConfigINI);
  try
    Server        := Ini.ReadString('Database', 'Server', 'localhost'); 
    Port          := Ini.ReadInteger('Database', 'Port', 3306); 
    Database      := Ini.ReadString('Database', 'Database', 'dbvarejo'); 
    Username      := Ini.ReadString('Database', 'Username', 'root'); 
    Password      := Ini.ReadString('Database', 'Password', 'root'); 
    DriverLibrary := Ini.ReadString('Database', 'DriverLibrary', lslibmysql);
  finally
    FreeAndNil(Ini);
  end;

  dm := GetDMInstance;
  
  // Configurar a conexão
  dm.conexao.Params[0] := 'Database='+ Database;
  dm.conexao.Params[1] := 'User_Name='+ Username;
  dm.conexao.Params[2] := 'Password='+ Password;
  dm.conexao.Params[3] := 'CharacterSet=utf8';
  dm.conexao.Params[4] := 'Server='+ Server;
  dm.conexao.Params[5] := 'UseSSL=True';
  dm.conexao.Params[6] := 'DriverID=MySQL';

  // Configurar a biblioteca do driver
  dm.FDPhysMySQLDriverLink1.VendorLib := DriverLibrary;  

  try
    dm.conexao.Connected := True;
  except
    on E: Exception do
      ShowMessage('Erro ao conectar ao banco de dados: ' + E.Message);
  end;

  LimpaDadosCliente;
end;

procedure TfrmPrincipal.btnPesquisarClienteClick(Sender: TObject);
var
  Cliente: TCliente;
  CodigoCliente: Integer;
  ClienteController : TClienteController;
begin
  CodigoCliente := StrToIntDef(edtCodCliente.Text, 0);
  
  if CodigoCliente > 0 then
  begin
    ClienteController := TClienteController.Create();
    try
      Cliente := ClienteController.BuscarCliente(CodigoCliente);
    
      if Assigned(Cliente) then
      begin                      
        lblNomeCliente.Caption   := 'Nome: ' + Cliente.Nome;
        lblCidade_UFCliente.Caption := 'Cidade: ' + Cliente.Cidade +' UF: ' + Cliente.UF;
      end
      else
      begin
        ShowMessage('Cliente não encontrado!');
        LimpaDadosCliente;
      end;
    finally
      FreeAndNil(ClienteController)
    end;
  end
  else
    ShowMessage('Código de cliente inválido.');
end;

procedure TfrmPrincipal.edtCodClienteKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Key = 13 then
   begin
     btnPesquisarClienteClick(self);
   end;
end;

procedure TfrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(dm) then
  begin
    dm.conexao.close;
    freeandnil(dm);
  end;
end;


procedure TfrmPrincipal.GravarVenda;
var
  Produtos: TArray<TArray<Double>>;
  I: Integer;
begin
  // Inicializar o array de produtos com base no grid
  SetLength(Produtos, GridProdutos.RowCount);
  for I := 0 to GridProdutos.RowCount - 1 do
  begin
    Produtos[I] := TArray<Double>.Create(
      StrToFloat(GridProdutos.Cells[0, I]), // Código do produto
      StrToFloat(GridProdutos.Cells[2, I]), // Quantidade
      StrToFloat(GridProdutos.Cells[3, I])  // Valor unitário
    );
  end;

  // Chamar o controller para gravar a venda
  with TPedidoController.Create(FDConnection1) do
  try
    GravarVenda(StrToInt(EditCodigoCliente.Text), Produtos);
    ShowMessage('Venda gravada com sucesso!');
  finally
    Free;
  end;
end;

end.
