unit ProdutoModel;

interface

uses
  FireDAC.Comp.Client, System.SysUtils;

type
  TProdutoModel = class
  private
    FConnection: TFDConnection;
  public
    constructor Create(AConnection: TFDConnection);
    function BuscarProduto(CodigoProduto: Integer): TFDQuery;
  end;

implementation

constructor TProdutoModel.Create(AConnection: TFDConnection);
begin
  FConnection := AConnection;
end;

function TProdutoModel.BuscarProduto(CodigoProduto: Integer): TFDQuery;
var
  FDQuery: TFDQuery;
begin
  FDQuery := TFDQuery.Create(nil);
  try
    FDQuery.Connection := FConnection;
    FDQuery.SQL.Text :=
      'SELECT Codigo, Descricao, Preco_Venda FROM Produtos WHERE Codigo = :Codigo';
    FDQuery.ParamByName('Codigo').AsInteger := CodigoProduto;
    FDQuery.Open;

    if not FDQuery.IsEmpty then
      Result := FDQuery
    else
      raise Exception.Create('Produto não encontrado.');
  except
    FDQuery.Free;
    raise;
  end;
end;

end.
