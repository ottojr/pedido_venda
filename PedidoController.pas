unit PedidoController;

interface

uses
  PedidoModel, System.SysUtils, FireDAC.Comp.Client;

type
  TPedidoController = class
  private
    FConnection: TFDConnection;
    FPedidoModel: TPedidoModel;
  public
    constructor Create(AConnection: TFDConnection);
    procedure GravarVenda(CodigoCliente: Integer;
      Produtos: TArray < TArray < Double >> );
  end;

implementation

constructor TPedidoController.Create(AConnection: TFDConnection);
begin
  FConnection := AConnection;
  FPedidoModel := TPedidoModel.Create(FConnection);
end;

procedure TPedidoController.GravarVenda(CodigoCliente: Integer;
  Produtos: TArray < TArray < Double >> );
var
  PedidoID: Integer;
  I: Integer;
  ValorTotal, Quantidade, ValorUnitario, ValorProdutoTotal: Double;
begin
  // Iniciar a transação
  FConnection.StartTransaction;
  try
    // Calcular o valor total da venda
    ValorTotal := 0;
    for I := Low(Produtos) to High(Produtos) do
    begin
      Quantidade := Produtos[I][1];
      ValorUnitario := Produtos[I][2];
      ValorProdutoTotal := Quantidade * ValorUnitario;
      ValorTotal := ValorTotal + ValorProdutoTotal;
    end;

    // Gravar o pedido
    PedidoID := FPedidoModel.GravarPedido(CodigoCliente, ValorTotal);

    // Gravar cada item do pedido
    for I := Low(Produtos) to High(Produtos) do
    begin
      FPedidoModel.GravarItemPedido(PedidoID, Round(Produtos[I][0]),
        Produtos[I][1], Produtos[I][2], Produtos[I][1] * Produtos[I][2]);
    end;

    FConnection.Commit;
  except
    on E: Exception do
    begin
      // Se houver algum erro, fazer rollback da transação
      FConnection.Rollback;
      raise Exception.Create('Erro ao gravar a venda: ' + E.Message);
    end;
  end;
end;

end.
