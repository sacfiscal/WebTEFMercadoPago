using Newtonsoft.Json;
using RestSharp;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebTEFMercadoPago
{
    public class CreatePayment
    {
        public async Task<PaymentResult> SendPayment(string accessToken, string amount, string description, 
                                                        int _installments, string typePayment, string installmentsCost,
                                                        string externalReference, bool printTerminal, string deviceId)
        {
            RequestBody requestBody = new RequestBody
            {                
                amount = int.Parse(amount),
                description = description,
                payment = new Payment
                {
                    installments = _installments,
                    type = typePayment,
                    installments_cost = installmentsCost
                },
                additional_info = new DetailAdditionalInfo
                {
                    external_reference = externalReference,
                    print_on_terminal = printTerminal
                }
            };

            string body = JsonConvert.SerializeObject(requestBody);

            var options = new RestClientOptions("https://api.mercadopago.com")
            {
                MaxTimeout = -1,
            };
            var client = new RestClient(options);
            var request = new RestRequest($"/point/integration-api/devices/{deviceId}/payment-intents", Method.Post);

            request.AddParameter("text/plain", body, ParameterType.RequestBody);
            request.AddHeader("Content-Type", "application/json");
            request.AddHeader("Authorization", $"Bearer {accessToken}");
            RestResponse response = await client.ExecuteAsync(request);

            if (response.StatusCode != System.Net.HttpStatusCode.Created && response.StatusCode != System.Net.HttpStatusCode.OK)
                throw new Exception(response.ErrorMessage);

            string json = response.Content;

            PaymentResult result = JsonConvert.DeserializeObject<PaymentResult>(json);

            return result;

        }
    }

    public class RequestBody
    {
        public int amount { get; set; }
        public string description { get; set; }
        public Payment payment { get; set; }
        public DetailAdditionalInfo additional_info { get; set; }
    }

    public class PaymentResult
    {
        public DetailAdditionalInfo additional_info { get; set; }
        public int amount { get; set; }
        public string description { get; set; }
        public string device_id { get; set; }
        public string id { get; set; }
        public Payment payment { get; set; }
        public string payment_mode { get; set; }
    }

    public class Payment
    {
        public int installments { get; set; }
        public string installments_cost { get; set; }
        public string type { get; set; }
    }

    public class DetailAdditionalInfo
    {
        public string external_reference { get; set; }
        public bool print_on_terminal { get; set; }
    }    

}
