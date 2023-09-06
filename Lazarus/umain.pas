unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls;

type

  { TFMain }

  TFMain = class(TForm)
    btBuscarPagamento: TButton;
    btCriarEstorno: TButton;
    btCriarPagto: TButton;
    btLimparCampos: TButton;
    btListarDevices: TButton;
    btListarTransacoes: TButton;
    btnAccessToken: TButton;
    btnAutorizarApp: TButton;
    btnModoOperacao: TButton;
    btnRefreshToken: TButton;
    btObterEstorno: TButton;
    btStatusPagto: TButton;
    Button1: TButton;
    cbCustoParcelas: TComboBox;
    chkImprimir: TCheckBox;
    edtAccessToken: TEdit;
    edtBandeira: TEdit;
    edtClientId: TEdit;
    edtClientSecret: TEdit;
    edtCodAutorizacao: TEdit;
    edtDescricao: TEdit;
    edtDevice: TEdit;
    edtIdCancelamento: TEdit;
    edtIdEstorno: TEdit;
    edtIdPagto: TEdit;
    edtIdPagtoEstornado: TEdit;
    edtIdPagtoEstorno: TEdit;
    edtIntencaoPagto: TEdit;
    edtParcelas: TEdit;
    edtRedirectUrl: TEdit;
    edtReferencia: TEdit;
    edtRefreshToken: TEdit;
    edtStatusEstorno: TEdit;
    edtStatusPagto: TEdit;
    edtTaxa: TEdit;
    edtTGCode: TEdit;
    edtValor: TEdit;
    edtValorEstornado: TEdit;
    edtValorEstorno: TEdit;
    edtValorRecebido: TEdit;
    GroupBox1: TGroupBox;
    Image1: TImage;
    Image10: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    Image9: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label3: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lbCustoParcelas: TLabel;
    lbParcelas: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    Memo4: TMemo;
    Memo5: TMemo;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    rbCredito: TRadioButton;
    rbDebito: TRadioButton;
    rbPDV: TRadioButton;
    rbSTANDALONE: TRadioButton;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    procedure btBuscarPagamentoClick(Sender: TObject);
    procedure btCriarEstornoClick(Sender: TObject);
    procedure btCriarPagtoClick(Sender: TObject);
    procedure btLimparCamposClick(Sender: TObject);
    procedure btListarDevicesClick(Sender: TObject);
    procedure btListarTransacoesClick(Sender: TObject);
    procedure btnAccessTokenClick(Sender: TObject);
    procedure btnAutorizarAppClick(Sender: TObject);
    procedure btnModoOperacaoClick(Sender: TObject);
    procedure btnRefreshTokenClick(Sender: TObject);
    procedure btObterEstornoClick(Sender: TObject);
    procedure btStatusPagtoClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  FMain: TFMain;

implementation

{$R *.lfm}

uses
  lclintf, fpjson,
  uWebTEFMercadoPago;

function IsJson(const AValue: string): Boolean;
var
  vJsonData: TJSONData;
begin
  try
    vJsonData := GetJSON(AValue);
    Result := vJsonData.Count > 0;
  except
    Result := False;
  end;
end;

{ TFMain }

procedure TFMain.btnAutorizarAppClick(Sender: TObject);
begin
  OpenURL(PChar('https://auth.mercadopago.com.br/authorization?client_id=' + edtClientId.Text +
              '&response_type=code&platform_id=mp&state=RANDOM_ID&redirect_uri=' + edtRedirectUrl.Text + '')
              );
end;

procedure TFMain.btnModoOperacaoClick(Sender: TObject);
var
  modoOperacao: string;
  JSONResponse: TJSONData;
  ResponseContent: string;
begin
  {TODO -oFabianoMorais -cWarning: Método PATCH não implementado no RESTRequest4Delphi-4.0.7,
    utilizando PUT, que gera erro. Corrigido e enviado PULL Request ao RESTRequest4Delphi}
  Memo2.Lines.Clear;
  try
    if (rbPDV.Checked) then
      modoOperacao := 'PDV'
    else
      modoOperacao := 'STANDALONE';

    ResponseContent := ChangeOperatingMode(edtAccessToken.Text, edtDevice.Text, modoOperacao);
    JSONResponse := GetJSON(ResponseContent);
    try
      Memo2.Lines.Add(JSONResponse.FormatJSON());
    finally
      JSONResponse.Free;
    end;
  except
      on e:Exception do
         Memo2.Lines.Add(e.Message);
  end;
end;

procedure TFMain.btnRefreshTokenClick(Sender: TObject);
var
  JSONResponse: TJSONData;
  ResponseContent: string;
begin
  Memo1.Lines.Clear;
  try
    ResponseContent := CreateRefreshToken(edtClientSecret.Text, edtClientId.Text, edtRefreshToken.Text);

    JSONResponse := GetJSON(ResponseContent);
    try
      edtAccessToken.Text  := JSONResponse.FindPath('access_token').AsString;
      edtRefreshToken.Text := JSONResponse.FindPath('refresh_token').AsString;

      Memo1.Lines.Add(JSONResponse.FormatJSON());
    finally
      JSONResponse.Free;
    end;
  except
      on e:Exception do
         Memo1.Lines.Add(e.Message);
  end;
end;

procedure TFMain.btObterEstornoClick(Sender: TObject);
var
  JSONResponse: TJSONData;
  ResponseContent: string;
begin
  Memo4.Lines.Clear;
  try
    ResponseContent := GetRefund(edtAccessToken.Text, edtIdPagtoEstorno.Text, edtIdEstorno.Text);

    JSONResponse := GetJSON(ResponseContent);
    try
      edtIdPagtoEstornado.Text := JSONResponse.FindPath('payment_id').AsString;
      edtValorEstornado.Text := JSONResponse.FindPath('amount').AsString;

      Memo4.Lines.Add(JSONResponse.FormatJSON());
    finally
      JSONResponse.Free;
    end;
  except
    on e:Exception do
      Memo4.Lines.Add(e.Message);
  end;
end;

procedure TFMain.btStatusPagtoClick(Sender: TObject);
var
  JSONResponse, payment: TJSONData;
  ResponseContent: string;
begin
  Memo3.Lines.Clear;
  try
    ResponseContent := GetPaymentIntents(edtAccessToken.Text, edtIntencaoPagto.text);

    JSONResponse := GetJSON(ResponseContent);
    try
      payment := JSONResponse.FindPath('payment');
      if (payment.Count > 1) then
      begin
        edtIdPagto.Text        := payment.FindPath('id').AsString;
        edtIdPagtoEstorno.Text := payment.FindPath('id').AsString;
      end;
      edtStatusPagto.Text    := JSONResponse.FindPath('state').AsString;

      Memo3.Lines.Add(JSONResponse.FormatJSON());
    finally
      JSONResponse.Free;
    end;
  except
    on e:Exception do
      Memo3.Lines.Add(e.Message);
  end;
end;

procedure TFMain.Button1Click(Sender: TObject);
var
  JSONResponse: TJSONData;
  ResponseContent: string;
begin
  Memo4.Lines.Clear;
  try
    ResponseContent := CancelPayment(edtAccessToken.Text, edtDevice.Text, edtIntencaoPagto.Text);

    JSONResponse := GetJSON(ResponseContent);
    try
      edtIdCancelamento.Text := JSONResponse.FindPath('id').AsString;

      Memo4.Lines.Add(JSONResponse.FormatJSON());
    finally
      JSONResponse.Free;
    end;
  except
   on e:Exception do
     Memo4.Lines.Add(e.Message);
  end;
end;

procedure TFMain.FormShow(Sender: TObject);
begin
  edtClientId.Text := '';
  edtClientSecret.Text := '';
  edtRedirectUrl.Text := '';
  edtTGCode.Text := '';
  edtAccessToken.Text := '';
  edtRefreshToken.Text := '';
  edtDevice.Text := '';
end;

procedure TFMain.btnAccessTokenClick(Sender: TObject);
var
  JSONResponse: TJSONData;
  ResponseContent: string;
begin
  Memo1.Lines.Clear;
  try
    ResponseContent := CreateAccessToken(edtClientSecret.Text, edtClientId.Text, edtTGCode.Text, edtRedirectURL.Text);

    JSONResponse := GetJSON(ResponseContent);
    try
      edtAccessToken.Text  := JSONResponse.FindPath('access_token').AsString;
      edtRefreshToken.Text := JSONResponse.FindPath('refresh_token').AsString;

      Memo1.Lines.Add(JSONResponse.FormatJSON());
    finally
      JSONResponse.Free;
    end;
  except
      on e:Exception do
         Memo1.Lines.Add(e.Message);
  end;
end;

procedure TFMain.btLimparCamposClick(Sender: TObject);
begin
  edtClientId.Clear;
  edtClientSecret.Clear;
  edtRedirectUrl.Clear;
  edtTGCode.Clear;
  edtAccessToken.Clear;
  edtRefreshToken.Clear;
  Memo1.Lines.Clear;
end;

procedure TFMain.btCriarPagtoClick(Sender: TObject);
var
  JSONResponse: TJSONData;
  ResponseContent, TipoPagto, CustoParcela: string;
  valor : double;
  parcelas: integer;
begin
  Memo3.Lines.Clear;
  try
    valor := StrToFloat(StringReplace(edtValor.Text, ',', '', [rfReplaceAll]));
    parcelas := StrToInt(edtParcelas.Text);

    if (rbDebito.Checked) then
       TipoPagto := 'debit_card'
    else
    begin
      TipoPagto := 'credit_card';
      if (parcelas > 1) and
       ((valor/parcelas) < 5) then
       raise Exception.Create('Valor da parcela não pode ser menor que R$ 5,00');
    end;

    if (cbCustoParcelas.ItemIndex = 0) then
      CustoParcela := 'seller'
    else if (cbCustoParcelas.ItemIndex = 1) then
      CustoParcela := 'buyer'
    else
      CustoParcela := '';

    ResponseContent := CreatePayment(edtAccessToken.Text,
                                     edtDevice.text,
                                     edtDescricao.Text,
                                     valor,
                                     parcelas,
                                     TipoPagto,
                                     CustoParcela,
                                     edtReferencia.text,
                                     chkImprimir.Checked);

    JSONResponse := GetJSON(ResponseContent);
    try
      edtIntencaoPagto.Text := JSONResponse.FindPath('id').AsString;

      Memo3.Lines.Add(JSONResponse.FormatJSON());
    finally
      JSONResponse.Free;
    end;
  except
    on e:Exception do
      Memo3.Lines.Add(e.Message);
  end;
end;

procedure TFMain.btBuscarPagamentoClick(Sender: TObject);
var
  JSONResponse, fee_details, transaction_details: TJSONData;
  ResponseContent: string;
begin
  Memo3.Lines.Clear;
  try
    ResponseContent := GetPayment(edtAccessToken.Text, edtIdPagto.text);

    JSONResponse := GetJSON(ResponseContent);
    try
      edtCodAutorizacao.Text := JSONResponse.FindPath('authorization_code').AsString;

      fee_details := JSONResponse.FindPath('fee_details[0]');
      if ( fee_details <> Nil ) then
      begin
        if fee_details.Count > 0 then
          edtTaxa.Text := fee_details.FindPath('amount').AsString;
      end;

      transaction_details   := JSONResponse.FindPath('transaction_details');
      edtValorRecebido.Text := transaction_details.FindPath('net_received_amount').AsString;
      edtBandeira.Text      := JSONResponse.FindPath('payment_method_id').AsString;

      Memo3.Lines.Add(JSONResponse.FormatJSON());
    finally
      JSONResponse.Free;
    end;
  except
     on e:Exception do
        Memo3.Lines.Add(e.Message);
  end;
end;

procedure TFMain.btCriarEstornoClick(Sender: TObject);
var
  valor : double;
  JSONResponse: TJSONData;
  ResponseContent: string;
begin
  Memo4.Lines.Clear;
  try
    if(edtValorEstorno.Text <> '') then
      valor := StrToFloat(StringReplace(edtValorEstorno.Text, ',', '', [rfReplaceAll]))
    else
      valor := 0;

    ResponseContent := CreateRefund(edtAccessToken.Text, edtIdPagtoEstorno.Text, valor);

    JSONResponse          := GetJSON(ResponseContent);
    try
      edtIdEstorno.Text     := JSONResponse.FindPath('id').AsString;
      edtStatusEstorno.Text := JSONResponse.FindPath('status').AsString;

      Memo4.Lines.Add(JSONResponse.FormatJSON());
    finally
      JSONResponse.Free;
    end;
  except
     on e:Exception do
        Memo4.Lines.Add(e.Message);
  end;
end;

procedure TFMain.btListarDevicesClick(Sender: TObject);
var
  JSONResponse,
  device: TJSONData;
  ResponseContent: String;
begin
  Memo2.Lines.Clear;
  try
    ResponseContent := GetDevices(edtAccessToken.Text);
    JSONResponse := GetJSON(ResponseContent);
    try
      device := JSONResponse.FindPath('devices[0]');
      if device <> Nil then
        edtDevice.Text := device.FindPath('id').AsString;

      Memo2.Lines.Add(JSONResponse.FormatJSON());
    finally
      JSONResponse.Free;
    end;
  except
     on e:Exception do
         Memo2.Lines.Add(e.Message);
  end;
end;

procedure TFMain.btListarTransacoesClick(Sender: TObject);
var
  JSONResponse: TJSONData;
  ResponseContent: string;
begin
  Memo5.Lines.Clear;
  try
    ResponseContent := GetPaymentsList(edtAccessToken.Text, 30);

    JSONResponse := GetJSON(ResponseContent);
    try
      Memo5.Lines.Add(JSONResponse.FormatJSON());
    finally
      JSONResponse.Free;
    end;
  except
     on e:Exception do
        Memo5.Lines.Add(e.Message);
  end;
end;

end.

