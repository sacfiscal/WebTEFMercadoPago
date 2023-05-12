using Newtonsoft.Json;
using RestSharp;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebTEFMercadoPago
{
    public class CreateRefund
    {
        public async Task<Refund> SendRefund(string accessToken, string idPayment)
        {

            var options = new RestClientOptions("https://api.mercadopago.com")
            {
                MaxTimeout = -1,
            };
            var client = new RestClient(options);
            var request = new RestRequest($"/v1/payments/{idPayment}/refunds", Method.Post);
            request.AddHeader("Authorization", $"Bearer {accessToken}");
            var body = @"";
            request.AddParameter("text/plain", body, ParameterType.RequestBody);

            request.AddParameter("text/plain", body, ParameterType.RequestBody);
            request.AddHeader("Content-Type", "application/json");
            request.AddHeader("Authorization", $"Bearer {accessToken}");
            RestResponse response = await client.ExecuteAsync(request);

            if (response.StatusCode != System.Net.HttpStatusCode.Created && response.StatusCode != System.Net.HttpStatusCode.OK)
                throw new Exception(response.ErrorMessage);

            string json = response.Content;

            Refund result = JsonConvert.DeserializeObject<Refund>(json);

            return result;

        }
    }


    public class Refund
    {
        public int id { get; set; }
        public long payment_id { get; set; }
        public int amount { get; set; }
        [JsonProperty("source")]
        public RefoundSource source { get; set; }
        public DateTime date_created { get; set; }
        public object unique_sequence_number { get; set; }
        public string refund_mode { get; set; }
        public int adjustment_amount { get; set; }
        public string status { get; set; }
        public object reason { get; set; }
        public object[] labels { get; set; }
        public int amount_refunded_to_payer { get; set; }
        public object additional_data { get; set; }
        public object[] partition_details { get; set; }
    }

    public class RefoundSource
    {
        public string id { get; set; }
        public string name { get; set; }
        public string type { get; set; }
    }

}
