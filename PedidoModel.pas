unit PedidoModel;

interface

uses
  System.SysUtils, FireDAC.Comp.Client, FireDAC.DApt;

type
  TPedidoModel = class
  private
    FConnection: TFDConnection;
  public
    constructor Create(AConnection: TFDConnection);
    function GravarPedido(CodigoCliente: Integer; ValorTotal: Double): Integer;
    procedure GravarItemPedido(PedidoID, CodigoProduto: Integer; Quantidade, ValorUnitario, ValorTotal: Double);
  end;

implementation

constructor TPedidoModel.Create(AConnection: TFDConnection);
begin
  FConnection := AConnection;
end;

function TPedidoModel.GravarPedido(CodigoCliente: Integer; ValorTotal: Double): Integer;
var
  FDQuery: TFDQuery;
begin
  FDQuery := TFDQuery.Create(nil);
  try
    FDQuery.Connection := FConnection;
    FDQuery.SQL.Text := 'INSERT INTO Pedidos (DataEmissao, Codigo_Cliente, ValorTotal) ' +
                        'VALUES (:DataEmissao, :CodigoCliente, :ValorTotal)';
    FDQuery.ParamByName('DataEmissao').AsDateTime := Now;
    FDQuery.ParamByName('CodigoCliente').AsInteger := CodigoCliente;
    FDQuery.ParamByName('ValorTotal').AsFloat := ValorTotal;
    FDQuery.ExecSQL;

    // Retornar o ID do pedido recém-criado
    Result := FConnection.ExecSQLScalar('SELECT LAST_INSERT_ID()');
  finally
    FDQuery.Free;
  end;
end;

procedure TPedidoModel.GravarItemPedido(PedidoID, CodigoProduto: Integer; Quantidade, ValorUnitario, ValorTotal: Double);
var
  FDQuery: TFDQuery;
begin
  FDQuery := TFDQuery.Create(nil);
  try
    FDQuery.Connection := FConnection;
    FDQuery.SQL.Text := 'INSERT INTO Pedidos_Produtos (Id_Pedido, Codigo_Produto, Quantidade, Valor_Unitario) ' +
                        'VALUES (:NumeroPedido, :CodigoProduto, :Quantidade, :ValorUnitario)';
    FDQuery.ParamByName('NumeroPedido').AsInteger := PedidoID;
    FDQuery.ParamByName('CodigoProduto').AsInteger := CodigoProduto;
    FDQuery.ParamByName('Quantidade').AsFloat := Quantidade;
    FDQuery.ParamByName('ValorUnitario').AsFloat := ValorUnitario;
    FDQuery.ExecSQL;
  finally
    FDQuery.Free;
  end;
end;

end.

