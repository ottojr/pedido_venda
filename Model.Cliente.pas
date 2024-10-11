unit Model.Cliente;

interface

type
  TCliente = class
  private
    FCodigo: Integer;
    FNome: string;
    FCidade: string;
    FUF: string;
  public
    property Codigo: Integer read FCodigo write FCodigo;
    property Nome: string read FNome write FNome;
    property Cidade: string read FCidade write FCidade;
    property UF: string read FUF write FUF;

    function BuscarClientePorCodigo(Codigo: Integer): Boolean;
  end;

implementation

uses
  FireDAC.Comp.Client, System.SysUtils, uDM;

{ TCliente }

function TCliente.BuscarClientePorCodigo(Codigo: Integer): Boolean;
var
  Query: TFDQuery;
begin
  Result := False;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := dm.conexao;
    Query.SQL.Text := 'SELECT * FROM Clientes WHERE Valido = 1 AND Codigo = :Codigo';
    Query.ParamByName('Codigo').AsInteger := Codigo;
    Query.Open;

    if not Query.IsEmpty then
    begin
      FCodigo := Query.FieldByName('Codigo').AsInteger;
      FNome := Query.FieldByName('Nome').AsString;
      FCidade := Query.FieldByName('Cidade').AsString;
      FUF := Query.FieldByName('UF').AsString;
      Result := True;
    end;
  finally
    Query.Free;
  end;
end;

end.

