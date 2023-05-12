using Newtonsoft.Json;
using RestSharp;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebTEFMercadoPago
{
    public class GetPayment
    {
        public async Task<StatusPayment> GetStatusPayment(string accessToken, string guidPayment)
        {
            var options = new RestClientOptions("https://api.mercadopago.com")
            {
                MaxTimeout = -1,
            };

            var client = new RestClient(options);
            var request = new RestRequest($"/point/integration-api/payment-intents/{guidPayment}", Method.Get);
            request.AddHeader("Authorization", $"Bearer {accessToken}");
            RestResponse response = await client.ExecuteAsync(request);

            if (response.StatusCode != System.Net.HttpStatusCode.Created && response.StatusCode != System.Net.HttpStatusCode.OK)
                throw new Exception(response.ErrorMessage);

            string json = response.Content;

            StatusPayment result = JsonConvert.DeserializeObject<StatusPayment>(json);

            return result;
        }
    }


    public class StatusPayment
    {
        public AdditionalInfo additional_info { get; set; }
        public int amount { get; set; }
        public string description { get; set; }
        public string device_id { get; set; }
        public string id { get; set; }
        public PaymentData payment { get; set; }
        public string payment_mode { get; set; }
        public string state { get; set; }
    }

    public class AdditionalInfo
    {
        public string external_reference { get; set; }
        public bool print_on_terminal { get; set; }
    }

    public class PaymentData
    {
        public string id { get; set; }
        public int installments { get; set; }
        public string installments_cost { get; set; }
        public string type { get; set; }
    }

}
