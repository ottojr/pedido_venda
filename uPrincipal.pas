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
  FireDAC.Comp.DataSet, Vcl.Grids, Vcl.DBGrids, Vcl.ExtCtrls;
  
type
  TfrmPrincipal = class(TForm)
    GroupBox1: TGroupBox;
    edtCodCliente: TEdit;
    lblCodCliente: TLabel;
    btnPesquisarCliente: TSpeedButton;
    lblNomeCliente: TLabel;
    lblCidade_UFCliente: TLabel;
    GroupBox2: TGroupBox;
    GridProdutos: TDBGrid;
    dsPedido: TDataSource;
    lblCodProduto: TLabel;
    edtCodProduto: TEdit;
    btnPesquisarProduto: TSpeedButton;
    edtQuantidade: TEdit;
    Label1: TLabel;
    edtPrecoUnitario: TEdit;
    Label2: TLabel;
    btnAdicionarProduto: TSpeedButton;
    btnExcluirProduto: TSpeedButton;
    Panel1: TPanel;
    btnGravarPedido: TSpeedButton;
    tblPedido: TFDMemTable;
    tblPedidoCodigo_Produto: TIntegerField;
    tblPedidoProduto: TStringField;
    tblPedidoQuantidade: TFloatField;
    tblPedidoValor_Unitario: TFloatField;
    tblPedidoValor_Total: TFloatField;
    lblProduto: TLabel;
    StatusBar1: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnPesquisarClienteClick(Sender: TObject);
    procedure edtCodClienteKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tblPedidoCalcFields(DataSet: TDataSet);
    procedure btnPesquisarProdutoClick(Sender: TObject);
    procedure btnAdicionarProdutoClick(Sender: TObject);
    procedure btnExcluirProdutoClick(Sender: TObject);
    procedure dsPedidoDataChange(Sender: TObject; Field: TField);
    procedure GridProdutosKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnGravarPedidoClick(Sender: TObject);
  private
    { Private declarations }
    FEditandoProduto: Boolean;
    FCodigoProdutoEdicao: Integer;
    
    procedure LimpaDadosCliente;
    procedure LimpaDadosProduto;
    procedure AtualizaValorTotal;
    procedure GravarVenda;
  public
    { Public declarations }
    function GetDMInstance: Tdm;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

uses ClienteModel, ClienteController, PedidoController, ProdutoController;

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

procedure TfrmPrincipal.LimpaDadosProduto;
begin
  edtCodProduto.Text    := '';
  lblProduto.Caption    := '';
  edtQuantidade.Text    := '';
  edtPrecoUnitario.Text := '0,00';
end;

procedure TfrmPrincipal.AtualizaValorTotal;
var
  lrValorTotal: Double;
begin
  lrValorTotal := 0;
  tblPedido.First;
  while not tblPedido.Eof do
  begin
    lrValorTotal := lrValorTotal + tblPedido.FieldByName('Valor_Total').AsFloat;
    tblPedido.Next;
  end;
  StatusBar1.Panels[0].Text := 'Valor total: ' + FormatFloat('###,##0.00', lrValorTotal);
  StatusBar1.Update;
end;
procedure TfrmPrincipal.btnAdicionarProdutoClick(Sender: TObject);
var
  Cliente: TCliente;
  CodigoCliente: Integer;
  ClienteController : TClienteController;
begin
  if Length(trim(edtCodCliente.Text)) = 0 then
  begin
    ShowMessage('Falta informar um código de cliente.');
    edtCodCliente.SetFocus;
    exit;
  end;

  if Length(trim(edtCodProduto.Text)) = 0 then
  begin
    ShowMessage('Falta informar um código de produto.');
    edtCodProduto.SetFocus;
    exit;
  end;

  // Validando a informação em edtCodCliente
  btnPesquisarClienteClick(Self);

  try
    if not tblPedido.Active then
      tblPedido.Open;

    // Verifica se está no modo de edição ou inserção
    if FEditandoProduto then
    begin
      // Editar o produto no grid
      if tblPedido.Locate('Codigo_Produto', FCodigoProdutoEdicao, []) then
      begin
        tblPedido.Edit;
        tblPedidoQuantidade.Value     := StrToFloat(edtQuantidade.Text);
        tblPedidoValor_Unitario.Value := StrToFloat(edtPrecoUnitario.Text);
        tblPedidoValor_Total.Value    := tblPedidoQuantidade.Value * tblPedidoValor_Unitario.Value;
        tblPedido.Post;
        FEditandoProduto := False; // Sai do modo de edição
      end;
    end
    else
    begin
      // Adicionar um novo produto
      tblPedido.Append;
      tblPedidoCodigo_Produto.Value := StrToInt(edtCodProduto.Text);
      tblPedidoProduto.Value        := lblProduto.Caption;
      tblPedidoQuantidade.Value     := StrToFloat(edtQuantidade.Text);
      tblPedidoValor_Unitario.Value := StrToFloat(edtPrecoUnitario.Text);
      tblPedidoValor_Total.Value    := tblPedidoQuantidade.Value * tblPedidoValor_Unitario.Value;
      tblPedido.Post;
    end;      
  finally
    AtualizaValorTotal;
    edtCodProduto.SetFocus;
  end;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
var
  fs: TFileStream;
  rs: TResourceStream;
  lslibmysql, lsConfigINI, lsFile : string;
  Ini: TIniFile; Server, Database, Username, Password, DriverLibrary: string; Port: Integer;
begin
  // Configurar o separador decimal e de milhar
  FormatSettings.DecimalSeparator := ',';
  FormatSettings.ThousandSeparator := '.';

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
  dm.conexao.Params[5] := 'DriverID=MySQL';
  // Configurar a biblioteca do driver
  dm.FDPhysMySQLDriverLink1.VendorLib := DriverLibrary;  

  try
    dm.conexao.Connected := True;
  except
    on E: Exception do
      ShowMessage('Erro ao conectar ao banco de dados: ' + E.Message);
  end;

  LimpaDadosCliente;
  LimpaDadosProduto;
end;

procedure TfrmPrincipal.btnExcluirProdutoClick(Sender: TObject);
begin
  if not tblPedido.IsEmpty then
  begin
    if MessageDlg('Você realmente deseja apagar este registro selecionado ?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      tblPedido.Delete;
      AtualizaValorTotal;
      LimpaDadosProduto;
      edtCodProduto.SetFocus;
    end;
  end;
end;

procedure TfrmPrincipal.btnGravarPedidoClick(Sender: TObject);
begin
  GravarVenda;
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

procedure TfrmPrincipal.btnPesquisarProdutoClick(Sender: TObject);
var
  ProdutoController: TProdutoController;
  CodigoProduto: Integer;
  QueryProduto: TFDQuery;
begin
  CodigoProduto := StrToIntDef(edtCodProduto.Text, 0);

  if CodigoProduto > 0 then
  begin
    ProdutoController := TProdutoController.Create(dm.conexao);
    try
      QueryProduto := ProdutoController.BuscarProduto(StrToInt(edtCodProduto.Text));

      if Assigned(QueryProduto) then
      begin
        lblProduto.Caption    := QueryProduto.FieldByName('Descricao').AsString;
        edtPrecoUnitario.Text := QueryProduto.FieldByName('Preco_Venda').AsString;
      end;
    except
      on E: Exception do
        ShowMessage('Erro: ' + E.Message);
    end;

    edtQuantidade.SetFocus;
  end
  else
    ShowMessage('Código de produto inválido.');
end;

procedure TfrmPrincipal.dsPedidoDataChange(Sender: TObject; Field: TField);
begin
  btnExcluirProduto.Enabled := not tblPedido.IsEmpty;
  btnGravarPedido.Enabled := not tblPedido.IsEmpty;
end;

procedure TfrmPrincipal.edtCodClienteKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Key = 13 then
   begin
     btnPesquisarClienteClick(self);
   end;
end;

procedure TfrmPrincipal.tblPedidoCalcFields(DataSet: TDataSet);
begin
  if tblPedidoQuantidade.AsFloat > 0 then
  begin
    tblPedidoValor_Total.AsFloat := tblPedidoValor_Unitario.AsFloat * tblPedidoQuantidade.AsFloat;
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
  if not dsPedido.DataSet.Active then
    Exit;

  // Inicializar o array de produtos com base no grid
  SetLength(Produtos, dsPedido.DataSet.RecordCount);
  dsPedido.DataSet.First;
  I := 0;
  while not dsPedido.DataSet.EOF do
  begin
    Produtos[I] := TArray<Double>.Create(
      dsPedido.DataSet.FieldByName('Codigo_Produto').AsInteger,
      dsPedido.DataSet.FieldByName('Quantidade').AsFloat,
      dsPedido.DataSet.FieldByName('Valor_Unitario').AsFloat
    );
    I := I + 1;
    dsPedido.DataSet.Next;
  end;
  
  // Chamar o controller para gravar a venda
  with TPedidoController.Create(dm.conexao) do
  try
    GravarVenda(StrToInt(edtCodCliente.Text), Produtos);
    ShowMessage('Venda gravada com sucesso!');
  finally
    Free;
  end;
end;

procedure TfrmPrincipal.GridProdutosKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_DELETE) and (Shift = []) then
  begin
    if tblPedido.IsEmpty then
      exit;
    btnExcluirProdutoClick(Self);
  end
  else if (Key = VK_RETURN) AND (not tblPedidoCodigo_Produto.IsNull) then
  begin
    // Muda para o modo de edição
    FEditandoProduto      := True;
    FCodigoProdutoEdicao  := tblPedidoCodigo_Produto.Value;
    edtCodProduto.Text    := IntToStr(tblPedidoCodigo_Produto.Value);
    lblProduto.Caption    := tblPedidoProduto.Value;
    edtQuantidade.Text    := FloatToStr(tblPedidoQuantidade.Value);
    edtPrecoUnitario.Text := FloatToStr(tblPedidoValor_Unitario.Value);

    Key := 0; // Previne o comportamento padrão da tecla Enter no grid
  end;  
end;

end.
