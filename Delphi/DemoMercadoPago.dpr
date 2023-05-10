program DemoMercadoPago;

uses
  Vcl.Forms,
  DemoMarcadoPago in 'DemoMarcadoPago.pas' {Form1},
  uWebTEFMercadoPago in 'src\uWebTEFMercadoPago.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
