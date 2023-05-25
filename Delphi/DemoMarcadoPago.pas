unit DemoMarcadoPago;

interface

uses
  RESTRequest4D,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, IdHTTP, IdSSLOpenSSL,
  IdSSLOpenSSLHeaders, REST.Types, REST.Client, REST.Json, System.JSON, Vcl.ExtCtrls,
  Vcl.Imaging.jpeg, Vcl.Imaging.pngimage;

type
  TForm1 = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    edtClientId: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    edtClientSecret: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    edtRedirectUrl: TEdit;
    Label5: TLabel;
    edtTGCode: TEdit;
    Memo1: TMemo;
    Label6: TLabel;
    Label7: TLabel;
    edtAccessToken: TEdit;
    Label8: TLabel;
    edtRefreshToken: TEdit;
    btLimparCampos: TButton;
    TabSheet5: TTabSheet;
    Panel1: TPanel;
    Label10: TLabel;
    Memo2: TMemo;
    Panel2: TPanel;
    btListarDevices: TButton;
    Label9: TLabel;
    btnAccessToken: TButton;
    btnRefreshToken: TButton;
    GroupBox1: TGroupBox;
    rbPDV: TRadioButton;
    rbSTANDALONE: TRadioButton;
    btnModoOperacao: TButton;
    edtDevice: TEdit;
    Panel3: TPanel;
    Panel4: TPanel;
    Label11: TLabel;
    edtValor: TEdit;
    Label12: TLabel;
    cbCustoParcelas: TComboBox;
    rbDebito: TRadioButton;
    rbCredito: TRadioButton;
    lbParcelas: TLabel;
    edtParcelas: TEdit;
    lbCustoParcelas: TLabel;
    btCriarPagto: TButton;
    Memo3: TMemo;
    Label15: TLabel;
    edtDescricao: TEdit;
    Label13: TLabel;
    Label14: TLabel;
    edtReferencia: TEdit;
    chkImprimir: TCheckBox;
    edtIntencaoPagto: TEdit;
    Label16: TLabel;
    btStatusPagto: TButton;
    Label17: TLabel;
    edtIdPagto: TEdit;
    Label18: TLabel;
    edtStatusPagto: TEdit;
    btBuscarPagamento: TButton;
    Label19: TLabel;
    edtCodAutorizacao: TEdit;
    Label20: TLabel;
    edtTaxa: TEdit;
    Label21: TLabel;
    edtValorRecebido: TEdit;
    Label22: TLabel;
    edtBandeira: TEdit;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Panel5: TPanel;
    Image7: TImage;
    Image8: TImage;
    Label23: TLabel;
    edtIdPagtoEstorno: TEdit;
    Label24: TLabel;
    edtValorEstorno: TEdit;
    Label25: TLabel;
    Label26: TLabel;
    edtIdEstorno: TEdit;
    edtStatusEstorno: TEdit;
    btCriarEstorno: TButton;
    Label27: TLabel;
    Panel6: TPanel;
    Label28: TLabel;
    Memo4: TMemo;
    btObterEstorno: TButton;
    Label29: TLabel;
    edtIdPagtoEstornado: TEdit;
    Label30: TLabel;
    edtValorEstornado: TEdit;
    Button1: TButton;
    Label31: TLabel;
    edtIdCancelamento: TEdit;
    Label32: TLabel;
    Memo5: TMemo;
    Image9: TImage;
    Image10: TImage;
    btListarTransacoes: TButton;
    procedure btLimparCamposClick(Sender: TObject);
    procedure btListarDevicesClick(Sender: TObject);
    procedure btnAccessTokenClick(Sender: TObject);
    procedure btnRefreshTokenClick(Sender: TObject);
    procedure btnModoOperacaoClick(Sender: TObject);
    procedure rbCreditoClick(Sender: TObject);
    procedure rbDebitoClick(Sender: TObject);
    procedure btCriarPagtoClick(Sender: TObject);
    procedure btStatusPagtoClick(Sender: TObject);
    procedure btBuscarPagamentoClick(Sender: TObject);
    procedure btCriarEstornoClick(Sender: TObject);
    procedure btObterEstornoClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btListarTransacoesClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
var
  Form1: TForm1;

implementation

uses
  uWebTEFMercadoPago;

{$R *.dfm}

function IsJson(const AValue: string): Boolean;
begin
    try
      TJSONObject.ParseJSONValue(AValue);
      Result := True;
    except
      Result := False;
    end;
end;

procedure TForm1.btnModoOperacaoClick(Sender: TObject);
var
  modoOperacao, AccessToken, RefreshToken: string;
  JSONResponse: TJSONObject;
  ResponseContent: string;
begin
    Memo2.Lines.Clear;
    try
        if (rbPDV.Checked) then
           modoOperacao := 'PDV'
        else
           modoOperacao := 'STANDALONE';

        ResponseContent := ChangeOperatingMode(edtAccessToken.Text, edtDevice.Text, modoOperacao);
        JSONResponse := TJSONObject.ParseJSONValue(ResponseContent) as TJSONObject;

        Memo2.Lines.Add(JSONResponse.Format(2));
    except
        on e:Exception do
           Memo2.Lines.Add(e.Message);
    end;

end;

procedure TForm1.btnRefreshTokenClick(Sender: TObject);
var
  JSONResponse: TJSONObject;
  ResponseContent: string;
begin
    Memo1.Lines.Clear;
    try
        ResponseContent := CreateRefreshToken(edtClientSecret.Text, edtClientId.Text, edtRefreshToken.Text);

        JSONResponse         := TJSONObject.ParseJSONValue(ResponseContent) as TJSONObject;
        edtAccessToken.Text  := JSONResponse.GetValue('access_token').Value;
        edtRefreshToken.Text := JSONResponse.GetValue('refresh_token').Value;

        Memo1.Lines.Add(JSONResponse.Format(2));
    except
        on e:Exception do
           Memo1.Lines.Add(e.Message);
    end;
end;

procedure TForm1.btObterEstornoClick(Sender: TObject);
var
 JSONResponse: TJSONObject;
 ResponseContent: string;
begin
    Memo4.Lines.Clear;
    try
        ResponseContent := GetRefund(edtAccessToken.Text, edtIdPagtoEstorno.Text, edtIdEstorno.Text);
        JSONResponse := TJSONObject.ParseJSONValue(ResponseContent) as TJSONObject;
        edtIdPagtoEstornado.Text := JSONResponse.GetValue('payment_id').Value;
        edtValorEstornado.Text := JSONResponse.GetValue('amount').Value;

        Memo4.Lines.Add(JSONResponse.Format(2));
    except
        on e:Exception do
           Memo4.Lines.Add(e.Message);
    end;
end;

procedure TForm1.btStatusPagtoClick(Sender: TObject);
var
  JSONResponse, payment: TJSONObject;
  ResponseContent: string;
begin
    Memo3.Lines.Clear;
    try
        ResponseContent := GetPaymentIntents(edtAccessToken.Text, edtIntencaoPagto.text);

        JSONResponse := TJSONObject.ParseJSONValue(ResponseContent) as TJSONObject;
        payment                := JSONResponse.GetValue('payment') as TJSONObject;

        edtIdPagto.Text        := payment.GetValue('id').Value;
        edtIdPagtoEstorno.Text := payment.GetValue('id').Value;
        edtStatusPagto.Text    := JSONResponse.GetValue('state').Value;

        Memo3.Lines.Add(JSONResponse.Format(2));
    except
        on e:Exception do
           Memo3.Lines.Add(e.Message);
    end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  JSONResponse: TJSONObject;
  ResponseContent: string;
begin
    Memo4.Lines.Clear;
    try
        ResponseContent := CancelPayment(edtAccessToken.Text, edtDevice.Text, edtIntencaoPagto.Text);
        JSONResponse := TJSONObject.ParseJSONValue(ResponseContent) as TJSONObject;
        edtIdCancelamento.Text := JSONResponse.GetValue('id').Value;

        Memo4.Lines.Add(JSONResponse.Format(2));
    except
       on e:Exception do
          Memo4.Lines.Add(e.Message);
    end;
end;

procedure TForm1.btListarTransacoesClick(Sender: TObject);
var
  JSONResponse: TJSONObject;
  ResponseContent: string;
begin
    Memo5.Lines.Clear;
    try
       ResponseContent := GetPaymentsList(edtAccessToken.Text, 30);
       JSONResponse := TJSONObject.ParseJSONValue(ResponseContent) as TJSONObject;

       Memo5.Lines.Add(JSONResponse.Format(2));
    except
       on e:Exception do
          Memo5.Lines.Add(e.Message);
    end;

end;

procedure TForm1.btCriarEstornoClick(Sender: TObject);
var
  valor : double;
  JSONResponse: TJSONObject;
  ResponseContent: string;
begin
    Memo4.Lines.Clear;
    try
        if(edtValorEstorno.Text <> '') then
           valor := StrToFloat(StringReplace(edtValorEstorno.Text, ',', '', [rfReplaceAll]))
        else
           valor := 0;

        ResponseContent := CreateRefund(edtAccessToken.Text, edtIdPagtoEstorno.Text, valor);

        JSONResponse          := TJSONObject.ParseJSONValue(ResponseContent) as TJSONObject;
        edtIdEstorno.Text     := JSONResponse.GetValue('id').Value;
        edtStatusEstorno.Text := JSONResponse.GetValue('status').Value;

        Memo4.Lines.Add(JSONResponse.Format(2));
    except
       on e:Exception do
          Memo4.Lines.Add(e.Message);
    end;
end;

procedure TForm1.btBuscarPagamentoClick(Sender: TObject);
var
  JSONResponse, fee_details, transaction_details: TJSONObject;
  ResponseContent: string;
begin
    Memo3.Lines.Clear;
    try
        ResponseContent := GetPayment(edtAccessToken.Text, edtIdPagto.text);

        JSONResponse := TJSONObject.ParseJSONValue(ResponseContent) as TJSONObject;
        edtCodAutorizacao.Text := JSONResponse.GetValue('authorization_code').Value;

        if (JSONResponse.TryGetValue<TJSONObject>('fee_details[0]', fee_details)) then
           edtTaxa.Text := fee_details.GetValue('amount').Value;

        transaction_details   := JSONResponse.GetValue('transaction_details') as TJSONObject;
        edtValorRecebido.Text := transaction_details.GetValue('net_received_amount').Value;
        edtBandeira.Text      := JSONResponse.GetValue('payment_method_id').Value;

        Memo3.Lines.Add(JSONResponse.Format(2));
    except
       on e:Exception do
          Memo3.Lines.Add(e.Message);
    end;
end;

procedure TForm1.btLimparCamposClick(Sender: TObject);
begin
    edtClientId.Clear;
    edtClientSecret.Clear;
    edtRedirectUrl.Clear;
    edtTGCode.Clear;
    edtAccessToken.Clear;
    edtRefreshToken.Clear;
    Memo1.Lines.Clear;
end;

procedure TForm1.rbCreditoClick(Sender: TObject);
begin
  lbParcelas.Visible := true;
  edtParcelas.Visible := true;
  lbCustoParcelas.Visible := true;
  cbCustoParcelas.Visible := true;
  cbCustoParcelas.ItemIndex := 0;
end;

procedure TForm1.rbDebitoClick(Sender: TObject);
begin
    lbParcelas.Visible := false;
    edtParcelas.Visible := false;
    lbCustoParcelas.Visible := false;
    cbCustoParcelas.Visible := false;
    cbCustoParcelas.ItemIndex := -1;
end;

procedure TForm1.btCriarPagtoClick(Sender: TObject);
var
  JSONResponse: TJSONObject;
  ResponseContent, TipoPagto, CustoParcela, idPagto: string;
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
             raise Exception.Create('Valor da parcela não pode ser menor que R% 5,00');
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

        JSONResponse := TJSONObject.ParseJSONValue(ResponseContent) as TJSONObject;
        idPagto := JSONResponse.GetValue('id').Value;
        edtIntencaoPagto.Text := idPagto;

        Memo3.Lines.Add(JSONResponse.Format(2));
    except
       on e:Exception do
          Memo3.Lines.Add(e.Message);
    end;
end;

procedure TForm1.btListarDevicesClick(Sender: TObject);
var
  JSONResponse, device: TJSONObject;
  ResponseContent: string;
  AccessToken, RefreshToken : string;
begin
   Memo2.Lines.Clear;
   try
      ResponseContent := GetDevices(edtAccessToken.Text);
      JSONResponse := TJSONObject.ParseJSONValue(ResponseContent) as TJSONObject;

      if JSONResponse.TryGetValue<TJSONObject>('devices[0]', device) then
         edtDevice.Text := device.GetValue('id').Value;

      Memo2.Lines.Add(JSONResponse.Format(2));
   except
       on e:Exception do
           Memo2.Lines.Add(e.Message);
   end;
end;

procedure TForm1.btnAccessTokenClick(Sender: TObject);
var
  JSONResponse: TJSONObject;
  ResponseContent: string;
begin
    Memo1.Lines.Clear;
    try
        ResponseContent := CreateAccessToken(edtClientSecret.Text, edtClientId.Text, edtTGCode.Text, edtRedirectURL.Text);

        JSONResponse         := TJSONObject.ParseJSONValue(ResponseContent) as TJSONObject;
        edtAccessToken.Text  := JSONResponse.GetValue('access_token').Value;
        edtRefreshToken.Text := JSONResponse.GetValue('refresh_token').Value;

        Memo1.Lines.Add(JSONResponse.Format(2));
    except
        on e:Exception do
           Memo1.Lines.Add(e.Message);
    end;
end;

end.
