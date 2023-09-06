unit uWebTEFMercadoPago;

interface

uses
  SysUtils, Classes, DateUtils, fpjson, openssl, opensslsockets,
  RESTRequest4D;

    function CreateAccessToken(const AClientSecret, AClientId, ACode, ARedirectUri: String): String;
    function CreateRefreshToken(const AClientSecret, AClientId, ARefreshToken: String): String;
    function ChangeOperatingMode(const AToken, ADevice, ANewMode: String): String;
    function CreatePayment(const AToken, ADevice, ADescription: String;
      const AAmount: Double; const AInstallments: Integer; const AType: String;
      const AInstallmentsCost: String; const AExternalReference: String;
      const APrintOnTerminal: Boolean): String;
    function CreateRefund(const AToken, AIdPayment: String; const AAmount: Double): String;
    function CancelPayment(const AToken, ADevice, APaymentIntentId: String): String;
    function GetDevices(const AToken: String): String;
    function GetPaymentIntents(const AToken, APaymentIntentId: String): String;
    function GetPaymentIntentsLastStatus(const AToken, APaymentIntentId: String): String;
    function GetPayment(const AToken, AIdPayment: String): String;
    function GetPaymentIntentsEvents(const AToken: String; const AStartDate, AEndDate: TDate): String;
    function GetPaymentsList(const AToken: String; const ADays: Integer): String;
    function GetRefund(const AToken, AIdPayment: String; AIdRefund: String): String;

const
   _BASE_URL                   : string = 'https://api.mercadopago.com';

   _TOKEN                      : string = '/oauth/token';
   _DEVICE_GET                 : string = '/point/integration-api/devices';
   _DEVICE_MODIFY              : string = '/point/integration-api/devices/{device_id}';
   _PAYMENT_CREATE             : string = '/point/integration-api/devices/{device_id}/payment-intents';
   _PAYMENT_CANCEL             : string = '/point/integration-api/devices/{device_id}/payment-intents/{payment_id}';
   _PAYMENT_GET_INTENTS        : string = '/point/integration-api/payment-intents/{payment_id}';
   _PAYMENT_LAST_STATUS        : string = '/point/integration-api/payment-intents/{payment_id}/events';
   _PAYMENT_GET_INTENTS_EVENTS : string = '/point/integration-api/payment-intents/events?startDate={dti}&endDate={dtf}';
   _PAYMENT_GET_LIST           : string = '/v1/payments/search?sort=date_created&criteria=desc&range=date_created&begin_date=NOW-{dias}DAYS&end_date=NOW';
   _PAYMENT_GET                : string = '/v1/payments/{payment_id}';
   _REFOUND_CREATE             : string = '/v1/payments/{payment_id}/refunds';
   _REFOUND_GET                : string = '/v1/payments/{payment_id}/refunds/{reembolso_id}';

implementation

function CreateAccessToken(const AClientSecret, AClientId, ACode, ARedirectUri: String): String;
var
  LResponse: IResponse;
begin
  Result := EmptyStr;
  try
    LResponse := TRequest
                         .New.BaseURL( _BASE_URL + _TOKEN )
                         .AddHeader('Content-Type', 'application/x-www-form-urlencoded')
                         .AddParam('grant_type','authorization_code')
                         .AddParam('client_secret', AClientSecret)
                         .AddParam('client_id', AClientId)
                         .AddParam('code', ACode)
                         .AddParam('redirect_uri', ARedirectUri)
                         .Post;

    if LResponse.StatusCode <> 200 then
      raise Exception.Create('[ERRO AO GERAR TOKEN]');

    Result := LResponse.Content;
  except
    on E:Exception do
      raise Exception.Create(e.Message + sLineBreak + LResponse.Content);
  end;
end;

function CreateRefreshToken(const AClientSecret, AClientId, ARefreshToken: String): String;
var
  LResponse: IResponse;
begin
  Result := EmptyStr;
  try
    LResponse := TRequest
                         .New.BaseURL( _BASE_URL + _TOKEN )
                         .AddHeader('Content-Type', 'application/x-www-form-urlencoded')
                         .AddParam('grant_type','refresh_token')
                         .AddParam('client_secret', AClientSecret)
                         .AddParam('client_id', AClientId)
                         .AddParam('refresh_token', ARefreshToken)
                         .Post;

    if LResponse.StatusCode <> 200 then
      raise Exception.Create('[ERRO AO ATUALIZAR TOKEN]');

    Result := LResponse.Content;
  except
    on E:Exception do
      raise Exception.Create(e.Message + sLineBreak + LResponse.Content);
  end;
end;

function GetDevices(const AToken: String): String;
var
  LResponse: IResponse;
begin
  Result := EmptyStr;
  try
    LResponse := TRequest
                         .New.BaseURL( _BASE_URL + _DEVICE_GET )
                         .Accept('application/json')
                         .TokenBearer(AToken)
                         .Get;

    if LResponse.StatusCode <> 200 then
      raise Exception.Create('[ERRO AO LER DEVICES]');

    Result := LResponse.Content;
  except
    on E:Exception do
      raise Exception.Create(e.Message + sLineBreak + LResponse.Content);
  end;
end;
function ChangeOperatingMode(const AToken, ADevice, ANewMode: String): String;
var
  LResponse: IResponse;
  LJson: TJSONObject;
  texto: String;
begin
  Result := EmptyStr;
  LJson  := TJSONObject.Create;

  try
    LJson.Add('operating_mode', ANewMode);
    LResponse := TRequest
                         .New.BaseURL( _BASE_URL + _DEVICE_MODIFY.Replace('{device_id}', ADevice) )
                         .Accept('application/json')
                         .TokenBearer(AToken)
                         .AddBody(LJson)
                         .Patch;

    if LResponse.StatusCode <> 200 then
       raise Exception.Create('[ERRO AO MODIFICAR OPERATION MODE]');

    Result := LResponse.Content;
  except
    on E:Exception do
      raise Exception.Create(e.Message + sLineBreak + LResponse.Content);
  end;
end;

function CreatePayment(const AToken, ADevice, ADescription: String;
  const AAmount: Double; const AInstallments: Integer; const AType: String;
  const AInstallmentsCost: String; const AExternalReference: String;
  const APrintOnTerminal: Boolean): String;
var
  LResponse: IResponse;
  LJson, LPayment, LAdditionalInfo: TJSONObject;
begin
  Result          := EmptyStr;
  LJson           := TJSONObject.Create;
  LPayment        := TJSONObject.Create;
  LAdditionalInfo := TJSONObject.Create;

  try
    if (AInstallments > 1) and
      ((AAmount/AInstallments) < 5) then
      raise Exception.Create('Valor da parcela não pode ser menor que R% 5,00');

    LJson.Add('amount', AAmount);//Trunc(AAmount*100));
   // LJson.Add('amount', TJSONNumber.Create(AAmount));//Trunc(AAmount*100));

    LJson.Add('description', ADescription);
    if(AType = 'credit_card') then
    begin
      LPayment.Add('installments', AInstallments);
      LPayment.Add('installments_cost', AInstallmentsCost);

      //LPayment.Add('installments', TJSONNumber.Create(AInstallments));
      //LPayment.Add('installments_cost', TJSONNumber.Create(AInstallmentsCost));
    end;

    LPayment.Add('type', AType);
    LJson.Add('payment', LPayment);
    LAdditionalInfo.Add('external_reference', AExternalReference);

    LAdditionalInfo.Add('print_on_terminal', APrintOnTerminal);
    //LAdditionalInfo.Add('print_on_terminal', TJSONBool.Create(APrintOnTerminal));

    LJson.Add('additional_info', LAdditionalInfo);

    LResponse := TRequest
                         .New.BaseURL( _BASE_URL + _PAYMENT_CREATE.Replace('{device_id}', ADevice) )
                         .TokenBearer(AToken)
                         .ContentType('application/json')
                         .AddBody(LJson)
                         .Post;

    if LResponse.StatusCode <> 201 then
      raise Exception.Create('[ERRO AO CRIAR PAYMENT]');

    Result := LResponse.Content;
  except
    on E:Exception do
    begin
      if LResponse = nil then
        raise Exception.Create(e.Message)
      else
        raise Exception.Create(e.Message + sLineBreak + LResponse.Content);
    end;
  end;
end;

function CancelPayment(const AToken, ADevice, APaymentIntentId: String): String;
var
  LResponse: IResponse;
begin
  Result := EmptyStr;
  try
    LResponse := TRequest
                     .New.BaseURL( _BASE_URL + _PAYMENT_CANCEL.Replace('{device_id}', ADevice)
                                                              .Replace('{payment_id}', APaymentIntentId) )
                     .Accept('application/json')
                     .TokenBearer(AToken)
                     .Delete;

    if LResponse.StatusCode <> 200 then
      raise Exception.Create('[ERRO AO CANCELAR PAYMENT]');

    Result := LResponse.Content;
  except
    on E:Exception do
      raise Exception.Create(e.Message + sLineBreak + LResponse.Content);
  end;
end;

function GetPaymentIntents(const AToken, APaymentIntentId: String): String;
var
  LResponse: IResponse;
begin
  Result := EmptyStr;
  try
    LResponse := TRequest
                         .New.BaseURL( _BASE_URL + _PAYMENT_GET_INTENTS.Replace('{payment_id}', APaymentIntentId) )
                         .Accept('application/json')
                         .TokenBearer(AToken)
                         .Get;

    if LResponse.StatusCode <> 200 then
      raise Exception.Create('[ERRO AO CONSULTAR PAYMENT INTENTS]');

    Result := LResponse.Content;
  except
    on E:Exception do
      raise Exception.Create(e.Message + sLineBreak + LResponse.Content);
  end;
end;

function GetPaymentIntentsLastStatus(const AToken, APaymentIntentId: String): String;
var
  LResponse: IResponse;
begin
  Result := EmptyStr;
  try
    LResponse := TRequest
                         .New.BaseURL( _BASE_URL + _PAYMENT_LAST_STATUS.Replace('{payment_id}', APaymentIntentId) )
                         .Accept('application/json')
                         .TokenBearer(AToken)
                         .Get;

    if LResponse.StatusCode <> 200 then
      raise Exception.Create('[ERRO AO CONSULTAR ÚLTIMO STATUS PAYMENT]');

    Result := LResponse.Content;
  except
     on E:Exception do
        raise Exception.Create(e.Message + sLineBreak + LResponse.Content);
  end;
end;

function GetPayment(const AToken, AIdPayment: String): String;
var
  LResponse: IResponse;
begin
  Result := EmptyStr;
  try
    if (AIdPayment = EmptyStr) then
      raise Exception.Create('Id do Pagamento não informado');

    LResponse := TRequest
                         .New.BaseURL( _BASE_URL + _PAYMENT_GET.Replace('{payment_id}', AIdPayment) )
                         .Accept('application/json')
                         .TokenBearer(AToken)
                         .Get;

    if LResponse.StatusCode <> 200 then
      raise Exception.Create('[ERRO AO CONSULTAR PAYMENT]');

    Result := LResponse.Content;
  except
    on E:Exception do
    begin
      if LResponse = nil then
        raise Exception.Create(e.Message)
      else
        raise Exception.Create(e.Message + sLineBreak + LResponse.Content);
    end;
  end;
end;

function CreateRefund(const AToken, AIdPayment: String; const AAmount: Double): String;
var
  LResponse: IResponse;
  LJson: TJSONObject;
begin
  Result := EmptyStr;
  LJson := TJSONObject.Create;

  if(AAmount > 0) then
    LJson.Add('amount', AAmount);
    //LJson.AddPair('amount', TJSONNumber.Create(AAmount));//Trunc(AAmount*100));

  try
    LResponse := TRequest
                         .New.BaseURL( _BASE_URL + _REFOUND_CREATE.Replace('{payment_id}', AIdPayment) )
                         .TokenBearer(AToken)
                         .ContentType('application/json')
                         .AddBody(LJson)
                         .Post;

    if LResponse.StatusCode <> 201 then
      raise Exception.Create('[ERRO AO CRIAR REEMBOLSO]');

    Result := LResponse.Content;
  except
    on E:Exception do
      raise Exception.Create(e.Message + sLineBreak + LResponse.Content);
  end;
end;

function GetRefund(const AToken, AIdPayment: String; AIdRefund: String): String;
var
  LResponse: IResponse;
begin
  Result := EmptyStr;
  try
    if (AIdPayment = EmptyStr) then
      raise Exception.Create('Id do Pagamento não informado');

    if (AIdRefund = EmptyStr) then
      raise Exception.Create('Id do Estorno não informado');

    LResponse := TRequest
                         .New.BaseURL( _BASE_URL + _REFOUND_GET.Replace('{payment_id}', AIdPayment)
                                                               .Replace('{reembolso_id}', AIdRefund) )
                         .Accept('application/json')
                         .TokenBearer(AToken)
                         .Get;

    if LResponse.StatusCode <> 200 then
      raise Exception.Create('[ERRO AO CONSULTAR REEMBOLSO]');

    Result := LResponse.Content;
  except
    on E:Exception do
    begin
      if LResponse = nil then
        raise Exception.Create(e.Message)
      else
        raise Exception.Create(e.Message + sLineBreak + LResponse.Content);
    end;
  end;
end;

function GetPaymentIntentsEvents(const AToken: String; const AStartDate, AEndDate: TDate): String;
var
  LResponse: IResponse;
begin
  Result := EmptyStr;
  try
    if (AStartDate > AEndDate) then
      raise Exception.Create('Data Inicial não pode ser maior que a data final');

    if (DaysBetween(AStartDate, AEndDate) > 30) then
      raise Exception.Create('O intervalo não pode ser maior que 30 dias');

    LResponse := TRequest
                         .New.BaseURL( _BASE_URL + _PAYMENT_GET_INTENTS_EVENTS.Replace('{dti}', FormatDateTime('yyyy-mm-dd',AStartDate))
                                                                              .Replace('{dtf}', FormatDateTime('yyyy-mm-dd',AEndDate)) )
                         .Accept('application/json')
                         .TokenBearer(AToken)
                         .Get;

    if LResponse.StatusCode <> 200 then
       raise Exception.Create('[ERRO AO CONSULTAR PAYMENT INTENTS EVENTS]');

    Result := LResponse.Content;
  except
    on E:Exception do
    begin
      if LResponse = nil then
        raise Exception.Create(e.Message)
      else
        raise Exception.Create(e.Message + sLineBreak + LResponse.Content);
    end;
  end;
end;

function GetPaymentsList(const AToken: String; const ADays: Integer): String;
var
  LResponse: IResponse;
begin
  Result := EmptyStr;
  try
    LResponse := TRequest.New
                             .BaseURL( _BASE_URL + _PAYMENT_GET_LIST.Replace('{dias}', ADays.ToString) )
                             .Accept('application/json')
                             .TokenBearer(AToken)
                             .Get;

    if LResponse.StatusCode <> 200 then
      raise Exception.Create('[ERRO AO CONSULTAR PAYMENT LIST]');

    Result := LResponse.Content;
  except
    on E:Exception do
      raise Exception.Create(e.Message + sLineBreak + LResponse.Content);
  end;
end;
end.
