unit PedidoController;

interface

uses
  PedidoModel, System.SysUtils, FireDAC.Comp.Client;

type
  TPedidoController = class
  private
    FPedidoModel: TPedidoModel;
  public
    constructor Create(AConnection: TFDConnection);
    procedure GravarVenda(CodigoCliente: Integer; Produtos: TArray<TArray<Double>>);
  end;

implementation

constructor TPedidoController.Create(AConnection: TFDConnection);
begin
  FPedidoModel := TPedidoModel.Create(AConnection);
end;

procedure TPedidoController.GravarVenda(CodigoCliente: Integer; Produtos: TArray<TArray<Double>>);
var
  PedidoID: Integer;
  I: Integer;
  ValorTotal, Quantidade, ValorUnitario, ValorProdutoTotal: Double;
begin
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
    FPedidoModel.GravarItemPedido(PedidoID, Round(Produtos[I][0]), Produtos[I][1], Produtos[I][2], Produtos[I][1] * Produtos[I][2]);
  end;
end;

end.

