unit ProdutoController;

interface

uses
  ProdutoModel, FireDAC.Comp.Client, System.SysUtils;

type
  TProdutoController = class
  private
    FProdutoModel: TProdutoModel;
  public
    constructor Create(AConnection: TFDConnection);
    function BuscarProduto(CodigoProduto: Integer): TFDQuery;
  end;

implementation

constructor TProdutoController.Create(AConnection: TFDConnection);
begin
  FProdutoModel := TProdutoModel.Create(AConnection);
end;

function TProdutoController.BuscarProduto(CodigoProduto: Integer): TFDQuery;
begin
  try
    Result := FProdutoModel.BuscarProduto(CodigoProduto);
  except
    raise Exception.Create('Erro ao buscar o produto.');
  end;
end;

end.

