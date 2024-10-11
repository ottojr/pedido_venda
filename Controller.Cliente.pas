unit Controller.Cliente;

interface

uses
  Model.Cliente;

type
  TClienteController = class
  private
    FCliente: TCliente;
  public
    constructor Create;
    destructor Destroy; override;

    // Método para buscar cliente pelo código
    function BuscarCliente(Codigo: Integer): TCliente;
  end;

implementation

{ TClienteController }

constructor TClienteController.Create;
begin
  FCliente := TCliente.Create;
end;

destructor TClienteController.Destroy;
begin
  FCliente.Free;
  inherited;
end;

function TClienteController.BuscarCliente(Codigo: Integer): TCliente;
begin
  if FCliente.BuscarClientePorCodigo(Codigo) then
    Result := FCliente
  else
    Result := nil;
end;

end.

