unit uWebTEFMercadoPago;

interface
uses
  REST.Types,
  Windows, SysUtils, Classes, Forms, System.JSON, System.DateUtils;


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

implementation
uses
  RESTRequest4D;

function CreateAccessToken(const AClientSecret, AClientId,
  ACode, ARedirectUri: String): String;
var
  LResponse: IResponse;
begin
  Result := EmptyStr;
  try
    LResponse := TRequest
                        .New.BaseURL('https://api.mercadopago.com/oauth/token')
                        .AddHeader('Content-Type', 'application/x-www-form-urlencoded')
                        .AddParam('grant_type','authorization_code', TRESTRequestParameterKind.pkGETorPOST)
                        .AddParam('client_secret', AClientSecret, TRESTRequestParameterKind.pkGETorPOST )
                        .AddParam('client_id', AClientId, TRESTRequestParameterKind.pkGETorPOST)
                        .AddParam('code', ACode, TRESTRequestParameterKind.pkGETorPOST)
                        .AddParam('redirect_uri', ARedirectUri, TRESTRequestParameterKind.pkGETorPOST)
                        .Post;

  finally
    if (LResponse.StatusCode <> 200) then
     raise Exception.Create(Format('Erro ao efetuar a requisição %d', [LResponse.StatusCode]));
    Result := LResponse.Content;

  end;
end;

function CreateRefreshToken(const AClientSecret, AClientId, ARefreshToken: String): String;
var
  LRequest: IRequest;
  LResponse: IResponse;
begin
  Result := EmptyStr;
  try
    try
      LResponse := TRequest
                        .New.BaseURL('https://api.mercadopago.com/oauth/token')
                        .AddHeader('Content-Type', 'application/x-www-form-urlencoded')
                        .AddParam('grant_type','refresh_token', TRESTRequestParameterKind.pkGETorPOST)
                        .AddParam('client_secret', AClientSecret, TRESTRequestParameterKind.pkGETorPOST )
                        .AddParam('client_id', AClientId, TRESTRequestParameterKind.pkGETorPOST)
                        .AddParam('refresh_token', ARefreshToken, TRESTRequestParameterKind.pkGETorPOST)
                        .Post;
    except
      on e:exception do
      begin
        raise Exception.Create(e.Message);
      end
    end;

  finally
    if (LResponse.StatusCode <> 200) then
     raise Exception.Create(Format('Erro ao efetuar a requisição %d', [LResponse.StatusCode]));

    Result := LResponse.Content;
  end;
end;

function GetDevices(const AToken: String): String;
var
  LResponse: IResponse;
begin
  try
    try
      LResponse := TRequest
                       .New.BaseURL('https://api.mercadopago.com/point/integration-api/devices')
                       .Accept('application/json')
                       .TokenBearer(AToken)
                       .Get;
    except
      on e:exception do
      begin
        raise Exception.Create(e.Message);
      end
    end;
  finally
    if (LResponse.StatusCode <> 200) then
     raise Exception.Create(Format('Erro ao efetuar a requisição %d', [LResponse.StatusCode]));

    Result := LResponse.Content;
  end;


end;

function ChangeOperatingMode(const AToken, ADevice, ANewMode: String): String;
var
  LResponse: IResponse;
  LJson: TJSONObject;
begin
  try
    try
      LJson := TJSONObject.Create;
      LJson.AddPair('operating_mode', ANewMode);
      LResponse := TRequest
                           .New.BaseURL('https://api.mercadopago.com/point/integration-api/devices/'+ADevice)
                           .Accept('application/json')
                           .TokenBearer(AToken)
                           .AddBody(LJson)
                           .Patch;
    except
      on e:exception do
      begin
        raise Exception.Create(e.Message);
      end
    end;
  finally
    if (LResponse.StatusCode <> 200) then
     raise Exception.Create(Format('Erro ao efetuar a requisição %d', [LResponse.StatusCode]));
  end;

  Result := LResponse.Content;

end;

function CreatePayment(const AToken, ADevice, ADescription: String;
  const AAmount: Double; const AInstallments: Integer; const AType: String;
  const AInstallmentsCost: String; const AExternalReference: String;
  const APrintOnTerminal: Boolean): String;
var
  LResponse: IResponse;
  LJson, LPayment, LAdditionalInfo: TJSONObject;
begin
  if (AInstallments > 1) and
     ((AAmount/AInstallments) < 5) then
     raise Exception.Create('Valor da parcela não pode ser menor que R% 5,00');

  Result := EmptyStr;
  try
    LJson := TJSONObject.Create;
    LJson.AddPair('amount', AAmount);//Trunc(AAmount*100));
    LJson.AddPair('description', ADescription);
    LPayment := TJSONObject.Create;

    if(AType = 'credit_card') then
    begin
      LPayment.AddPair('installments', AInstallments);
      LPayment.AddPair('installments_cost', AInstallmentsCost);
    end;
    LPayment.AddPair('type', AType);
    LJson.AddPair('payment', LPayment);
    LAdditionalInfo := TJSONObject.Create;
    LAdditionalInfo.AddPair('external_reference', AExternalReference);
    LAdditionalInfo.AddPair('print_on_terminal', APrintOnTerminal);
    LJson.AddPair('additional_info', LAdditionalInfo);

    try
      LResponse := TRequest
                           .New.BaseURL(Format('https://api.mercadopago.com/point/integration-api/devices/%s/payment-intents',[ADevice]))
                           .TokenBearer(AToken)
                           .ContentType('application/json')
                           .AddBody(LJson)
                           .Post;
    except
      on e:exception do
      begin
        raise Exception.Create(e.Message);
      end
    end;
  finally
    if (LResponse.StatusCode <> 201) then
     raise Exception.Create(Format('Erro ao efetuar a requisição %d', [LResponse.StatusCode]));
  end;
  Result := LResponse.Content;

end;

function CancelPayment(const AToken, ADevice, APaymentIntentId: String): String;
var
  LResponse: IResponse;
begin
  Result := EmptyStr;

  try
    try
      LResponse := TRequest
                       .New.BaseURL(Format('https://api.mercadopago.com/point/integration-api/devices/%s/payment-intents/%s',[ADevice, APaymentIntentId]))
                       .Accept('application/json')
                       .TokenBearer(AToken)
                       .Delete;
     except
      on e:exception do
      begin
        raise Exception.Create(e.Message);
      end
    end;
  finally
    if (LResponse.StatusCode <> 200) then
     raise Exception.Create(Format('Erro ao efetuar a requisição %d', [LResponse.StatusCode]));
  end;
  Result := LResponse.Content;

end;

function GetPaymentIntents(const AToken, APaymentIntentId: String): String;
var
  LResponse: IResponse;
begin
  Result := EmptyStr;
  try
    try
      LResponse := TRequest
                         .New.BaseURL(Format('https://api.mercadopago.com/point/integration-api/payment-intents/%s',[APaymentIntentId]))
                         .Accept('application/json')
                         .TokenBearer(AToken)
                         .Get;
    except
        on e:exception do
        begin
          raise Exception.Create(e.Message);
        end
    end;
  finally
  if (LResponse.StatusCode <> 200) then
     raise Exception.Create(Format('Erro ao efetuar a requisição %d', [LResponse.StatusCode]));
  end;

  Result := LResponse.Content;
end;

function GetPaymentIntentsLastStatus(const AToken, APaymentIntentId: String): String;
var
  LResponse: IResponse;
begin
  Result := EmptyStr;
  LResponse := TRequest
                       .New.BaseURL(Format('https://api.mercadopago.com/point/integration-api/payment-intents/%s/events',[APaymentIntentId]))
                       .Accept('application/json')
                       .TokenBearer(AToken)
                       .Get;

  Result := LResponse.Content;
  if (LResponse.StatusCode <> 200) then
     raise Exception.Create(Format('Erro ao efetuar a requisição %d', [LResponse.StatusCode]));
end;


function GetPayment(const AToken, AIdPayment: String): String;
var
  LResponse: IResponse;
begin
  if (AIdPayment = EmptyStr) then
    raise Exception.Create('Id do Pagamento não informado');

  Result := EmptyStr;
  LResponse := TRequest
                       .New.BaseURL(Format('https://api.mercadopago.com/v1/payments/%s',[AIdPayment]))
                       .Accept('application/json')
                       .TokenBearer(AToken)
                       .Get;

  Result := LResponse.Content;
  if (LResponse.StatusCode <> 200) then
    raise Exception.Create(Format('Erro ao efetuar a requisição %d', [LResponse.StatusCode]));
end;

function CreateRefund(const AToken, AIdPayment: String; const AAmount: Double): String;
var
  LResponse: IResponse;
  LJson: TJSONObject;
begin
  Result := EmptyStr;
  try
    LJson := TJSONObject.Create;

    if(AAmount > 0) then
      LJson.AddPair('amount', AAmount); //Trunc(AAmount*100));

    try
      LResponse := TRequest
                         .New.BaseURL(Format('https://api.mercadopago.com/v1/payments/%s/refunds',[AIdPayment]))
                         .TokenBearer(AToken)
                         .ContentType('application/json')
                         .AddBody(LJson)
                         .Post;
    except
        on e:exception do
        begin
          raise Exception.Create(e.Message);
        end
    end;
  finally
    if (LResponse.StatusCode <> 201) then
     raise Exception.Create(Format('Erro ao efetuar a requisição %d', [LResponse.StatusCode]));
  end;

  Result := LResponse.Content;
end;

function GetRefund(const AToken, AIdPayment: String; AIdRefund: String): String;
var
  LResponse: IResponse;
  LJson: TJSONObject;
begin

  if (AIdPayment = EmptyStr) then
    raise Exception.Create('Id do Pagamento não informado');

  if (AIdRefund = EmptyStr) then
    raise Exception.Create('Id do Estorno não informado');

  try
    try
      Result := EmptyStr;
      LResponse := TRequest
                           .New.BaseURL(Format('https://api.mercadopago.com/v1/payments/%s/refunds/%s',[AIdPayment, AIdRefund]))
                           .Accept('application/json')
                           .TokenBearer(AToken)
                           .Get;
    except
        on e:exception do
        begin
          raise Exception.Create(e.Message);
        end
    end;
  finally
    if (LResponse.StatusCode <> 200) then
     raise Exception.Create(Format('Erro ao efetuar a requisição %d', [LResponse.StatusCode]));
  end;

  Result := LResponse.Content;
end;

function GetPaymentIntentsEvents(const AToken: String; const AStartDate, AEndDate: TDate): String;
var
  LResponse: IResponse;
begin
  if (AStartDate > AEndDate) then
    raise Exception.Create('Data Inicial não pode ser maior que a data final');

  if (DaysBetween(AStartDate, AEndDate) > 30) then
    raise Exception.Create('O intervalo não pode ser maior que 30 dias');

  Result := EmptyStr;
  LResponse := TRequest
                       .New.BaseURL(Format('https://api.mercadopago.com/point/integration-api/payment-intents/events?startDate=%s&endDate=%s',
                                           [FormatDateTime('yyyy-mm-dd',AStartDate), FormatDateTime('yyyy-mm-dd',AEndDate)]))
                       .Accept('application/json')
                       .TokenBearer(AToken)
                       .Get;

  Result := LResponse.Content;
  if (LResponse.StatusCode <> 200) then
     raise Exception.Create(Format('Erro ao efetuar a requisição %d', [LResponse.StatusCode]));
end;

function GetPaymentsList(const AToken: String; const ADays: Integer): String;
var
  LResponse: IResponse;
begin
  Result := EmptyStr;
  LResponse := TRequest
                       .New.BaseURL(Format('https://api.mercadopago.com/v1/payments/search?sort=date_created&criteria=desc&range=date_created&begin_date=NOW-%dDAYS&end_date=NOW',
                                           [ADays]))
                       .Accept('application/json')
                       .TokenBearer(AToken)
                       .Get;

  Result := LResponse.Content;
  if (LResponse.StatusCode <> 200) then
     raise Exception.Create(Format('Erro ao efetuar a requisição %d', [LResponse.StatusCode]));
end;

end.
