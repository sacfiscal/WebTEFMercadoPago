using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Diagnostics;
using WebTEFMercadoPago;


namespace DemoConsole
{
    public class Program
    {
        public static async Task Main(string[] args)
        {
            string _clientId = "your client id", 
                   _clientSecret = "your client secret", 
                   _code = "your TG code", 
                   _redirectUri = "your redirect uri",
                   _accessToken = "access token generate", 
                   _refreshToken = "new code TG",
                   _url = $"https://auth.mercadopago.com.br/authorization?client_id={_clientId}&response_type=code&platform_id=mp&state=RANDOM_ID&redirect_uri={_redirectUri}";

            bool _refreshCredential = false;

            string _modeOperation = "PDV"; // PDV or STANDALONE

            //Authorize Application
            try
            {
                var process = Process.Start(_url);                
                await Task.Run(() => process.WaitForExit());
            }
            catch (Exception ex)
            {
                Console.WriteLine("Erro ao abrir o navegador: " + ex.Message);
            }


            //Generate first credentials
            if (_accessToken == null)
            {
                CreateAccessToken credenciais = new CreateAccessToken();
                var accessToken = await credenciais.GetAccessToken(_clientId, _clientSecret, _code, _redirectUri);
                _accessToken = accessToken.access_token;
                _refreshToken = accessToken.refresh_token;

                Console.WriteLine($"First AccessToken: {accessToken.access_token}");
            }

            //Refresh Credentials
            if (_refreshCredential) 
            {
                CreateRefreshToken credenciaisRefreshToken = new CreateRefreshToken();
                var newAccessToken = await credenciaisRefreshToken.GetRefreshToken(_clientId, _clientSecret, _refreshToken);
                _accessToken = newAccessToken.access_token;
                _refreshToken = newAccessToken.refresh_token;

                Console.WriteLine($"New AccessToken: {newAccessToken.access_token}");

            }

            //List Devices
            List<string> _deviceId = new List<string>();
            ListDevices listDevices = new ListDevices();
            var deviceList = await listDevices.GetDeviceList(_accessToken);
            if(deviceList != null)
            {
                foreach (var device in deviceList.devices)
                {
                    _deviceId.Add(device.id);
                    Console.WriteLine($"Id: {device.id}, Operating Mode: {device.operating_mode}");
                }

                _deviceId.ForEach(i => Console.WriteLine($"Device: {(i)}"));
                Console.WriteLine($"Total: {deviceList.paging.total}, Limit: {deviceList.paging.limit}, Offset: {deviceList.paging.offset}");
            }

            //Set Device Mode: PDV or STANDALONE
            if(_modeOperation != "")
            {
                SetModeOperation operation = new SetModeOperation();
                var modeOperation = await operation.SetDeviceMode(_accessToken, _modeOperation);
                _modeOperation = modeOperation.operating_mode;
                
                Console.WriteLine($"Operation Mode: {_modeOperation}");
            }

            // Create Payment
            string guidPayment= "";
            if(_deviceId.Count > 0)
            {
                CreatePayment payment = new CreatePayment();
                var paymentResult = await payment.SendPayment(_accessToken, "100", "Pedido 001 - C.Crédito", 1, "credit_card", "seller", "Pedido 001", true, _deviceId.FirstOrDefault());
                guidPayment = paymentResult.id;
                
                Console.WriteLine($"guid payment: {guidPayment}");
            }

            //Set Cancel Payment
            //if (guidPayment != "")
            //{
            //    CancelPayment cancelPayment = new CancelPayment();
            //    var cancelResult = cancelPayment.SetCancelPayment(_accessToken, _deviceId.FirstOrDefault(), guidPayment);

            //    Console.WriteLine($"guid cancel payment: {cancelResult.Id}");
            //}

            // Get Stataus Payment
            int _amount, _installments;
            string _device_Id, _guidPayment, _paymentId, _installments_cost, _type, _paymentMode, _state;
            _paymentId = "";
            if(guidPayment != "")
            {
                GetPayment statusPayment = new GetPayment();
                var statusResult = statusPayment.GetStatusPayment(_accessToken, guidPayment);
                _amount = statusResult.Result.amount;
                _device_Id = statusResult.Result.device_id;
                _guidPayment = statusResult.Result.id;
                _paymentId = statusResult.Result.payment.id;
                _installments = statusResult.Result.payment.installments;
                _installments_cost = statusResult.Result.payment.installments_cost;
                _type = statusResult.Result.payment.type;
                _paymentMode = statusResult.Result.payment_mode;
                _state = statusResult.Result.state;

                Console.WriteLine($"id payment: {_paymentId} - Amount: {_amount.ToString()} - Mode: {_paymentMode}");

            }

            // Get Detail Payment
            int detail_amount, detail_installments;
            decimal detail_feeAmount, detail_netReceivedAmount;
            string detail_authorizationCode, detail_dateApproved, detail_paymentIntentId, detail_paymentMethodId,
                   detail_statementDescriptor, detail_status,
                   detail_devicedetail_Id, detail_guidPayment, detail_paymentId, detail_installmentsdetail_cost, 
                   detail_type, detail_paymentMode, detail_state;
            if (_paymentId != "")
            {
                GetDetailPayment statusPayment = new GetDetailPayment();
                var statusResult = statusPayment.GetAllPayment(_accessToken, guidPayment);
                detail_feeAmount = (Decimal)statusResult.Result.charges_details[0].amounts.original;
                detail_netReceivedAmount = (Decimal)(statusResult.Result.transaction_details.net_received_amount);
                detail_paymentId = statusResult.Result.id.ToString();
                detail_paymentMethodId = statusResult.Result.payment_method_id;
                detail_installments = statusResult.Result.installments;
                detail_type = statusResult.Result.payment_method.type;
                detail_state = statusResult.Result.status;

                Console.WriteLine($"id payment: {detail_paymentId} - Received: {detail_netReceivedAmount.ToString()} - Mode: {detail_paymentMethodId}");

            }

            //Create Refund
            int idRefund;
            string statusRefund;
            decimal amountRefund;
            CreateRefund refund = new CreateRefund();
            var refundResult = refund.SendRefund(_accessToken, _paymentId);

            idRefund = refundResult.Result.id;
            statusRefund = refundResult.Result.status;
            amountRefund = refundResult.Result.amount;

            Console.WriteLine($"id refund: {idRefund} - stataus: {statusRefund} - amount: {amountRefund}");

            // Get Refund Data
            GetRefund refundData = new GetRefund();
            var refundDataResult = refundData.GetRefundData(_accessToken, _paymentId, idRefund);

            idRefund = refundDataResult.Result.id;
            statusRefund = refundDataResult.Result.status;
            amountRefund = refundDataResult.Result.amount;

            Console.WriteLine($"id refund: {idRefund} - stataus: {statusRefund} - amount: {amountRefund}");

        }
    }
}
