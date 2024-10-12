program Pedido;

{$R *.dres}

uses
  Vcl.Forms,
  uPrincipal in 'uPrincipal.pas' {frmPrincipal},
  uDM in 'uDM.pas' {DM: TDataModule},
  ClienteModel in 'ClienteModel.pas',
  ClienteController in 'ClienteController.pas',
  PedidoModel in 'PedidoModel.pas',
  PedidoController in 'PedidoController.pas',
  ProdutoModel in 'ProdutoModel.pas',
  ProdutoController in 'ProdutoController.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TDM, DM);
  Application.Run;
end.
