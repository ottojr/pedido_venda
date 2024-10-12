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
    tblPedido: TFDMemTable;
    tblPedidoCodigo_Produto: TIntegerField;
    tblPedidoProduto: TStringField;
    tblPedidoQuantidade: TFloatField;
    tblPedidoValor_Unitario: TFloatField;
    tblPedidoValor_Total: TFloatField;
    StatusBar1: TStatusBar;
    edtNomeProduto: TEdit;
    Label3: TLabel;
    btnGravarPedido: TSpeedButton;
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
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtCodProdutoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtPrecoUnitarioKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtQuantidadeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
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
  bkm: TBookmark;

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
  edtNomeProduto.Text         := '';
  lblNomeCliente.Caption      := '';
  lblCidade_UFCliente.Caption := '';
end;

procedure TfrmPrincipal.LimpaDadosProduto;
begin
  edtCodProduto.Text    := '';
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
    lrValorTotal := lrValorTotal + (tblPedido.FieldByName('Valor_Unitario').AsFloat * tblPedido.FieldByName('Quantidade').AsFloat);
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
  if not tblPedido.Active then
    tblPedido.Open;

  // Verifica se está no modo de edição ou inserção
  if FEditandoProduto then
  begin
    // Editar o produto no grid
    if tblPedido.Locate('Codigo_Produto', FCodigoProdutoEdicao, []) then
    begin
      tblPedido.Edit;
      tblPedidoValor_Total.Value := tblPedidoQuantidade.Value * tblPedidoValor_Unitario.Value;
      tblPedido.Post;
      FEditandoProduto := False; // Sai do modo de edição
      AtualizaValorTotal;
      if GridProdutos.DataSource.Dataset.BookmarkValid(bkm) then
      begin
        GridProdutos.DataSource.Dataset.GotoBookmark(bkm);
      end;
    end;
  end
  else
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

    if Length(trim(edtQuantidade.Text)) = 0 then
    begin
      ShowMessage('Falta informar a quantidade do produto.');
      edtQuantidade.SetFocus;
      exit;
    end;

    if StrToFloat(edtQuantidade.Text) <= 0 then
    begin
      ShowMessage('A quantidade deve ser maior que zero.');
      edtQuantidade.SetFocus;
      exit;
    end;

    if Length(trim(edtPrecoUnitario.Text)) = 0 then
    begin
      ShowMessage('Falta informar o preço unitário do produto.');
      edtPrecoUnitario.SetFocus;
      exit;
    end;

    if StrToInt(edtPrecoUnitario.Text) <= 0 then
    begin
      ShowMessage('O preço unitário deve ser maior que zero.');
      edtPrecoUnitario.SetFocus;
      exit;
    end;

    // Validando a informação em edtCodCliente
    btnPesquisarClienteClick(Self);

    // Adicionar um novo produto
    tblPedido.Append;
    tblPedidoCodigo_Produto.Value := StrToInt(edtCodProduto.Text);
    tblPedidoProduto.Value        := edtNomeProduto.Text;
    tblPedidoQuantidade.Value     := StrToFloat(edtQuantidade.Text);
    tblPedidoValor_Unitario.Value := StrToFloat(edtPrecoUnitario.Text);
    tblPedidoValor_Total.Value    := tblPedidoQuantidade.Value * tblPedidoValor_Unitario.Value;
    tblPedido.Post;

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
      rs     := TResourceStream.Create(hInstance, 'RC01', RT_RCDATA);
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

procedure TfrmPrincipal.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   case key of
     vk_F3: begin
               btnPesquisarClienteClick(Self);
            end;
     vk_F4: begin
               btnPesquisarProdutoClick(Self);
            end;
   end;
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
  tblPedido.EmptyDataSet;
  LimpaDadosProduto;
  LimpaDadosCliente;
  edtCodCliente.SetFocus;
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
        edtNomeProduto.Text   := QueryProduto.FieldByName('Descricao').AsString;
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

procedure TfrmPrincipal.edtCodProdutoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Key = 13 then
   begin
     btnPesquisarProdutoClick(self);
   end;
end;

procedure TfrmPrincipal.edtPrecoUnitarioKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Key = 13 then
   begin
     btnAdicionarProdutoClick(Self);
   end;
end;

procedure TfrmPrincipal.edtQuantidadeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then
  begin
    btnAdicionarProdutoClick(Self);
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

  // Inicializar o array de produtos
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
  else if ((Key = VK_RETURN) or (Key = VK_TAB)) AND (not tblPedidoCodigo_Produto.IsNull) then
  begin
    // Entra no modo de edição
    FEditandoProduto := True;
    FCodigoProdutoEdicao := tblPedidoCodigo_Produto.AsInteger;
    Key := 0; // Previne o comportamento padrão do Enter no grid
    bkm := GridProdutos.DataSource.DataSet.GetBookmark;
    btnAdicionarProdutoClick(self);
  end;
end;

end.
