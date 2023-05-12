using Newtonsoft.Json;
using RestSharp;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebTEFMercadoPago
{
    public class CancelPayment
    {
        public async Task<CancelResult> SetCancelPayment(string accessToken, string deviceId, string guidPayment)
        {
            var options = new RestClientOptions("https://api.mercadopago.com")
            {
                MaxTimeout = -1,
            };

            var client = new RestClient(options);
            var request = new RestRequest($"/point/integration-api/devices/{deviceId}/payment-intents/{guidPayment}", Method.Delete);
            request.AddHeader("Authorization", $"Bearer {accessToken}");
            RestResponse response = await client.ExecuteAsync(request);

            if (response.StatusCode != System.Net.HttpStatusCode.Created && response.StatusCode != System.Net.HttpStatusCode.OK)
                throw new Exception(response.ErrorMessage);

            string json = response.Content;

            CancelResult result = JsonConvert.DeserializeObject<CancelResult>(json);

            return result;
        }
    }


    public class CancelResult
    {
        public string id { get; set; }
    }

}
