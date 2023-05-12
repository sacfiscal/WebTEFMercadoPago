using Newtonsoft.Json;
using RestSharp;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebTEFMercadoPago
{
    public class GetRefund
    {
        public async Task<RequestRefund> GetRefundData(string accessToken, string idPayment, int idRefund)
        {

            var options = new RestClientOptions("https://api.mercadopago.com")
            {
                MaxTimeout = -1,
            };
            var client = new RestClient(options);
            var request = new RestRequest($"/v1/payments/{idPayment}/refunds/{idRefund}", Method.Get);
            request.AddHeader("Authorization", $"Bearer {accessToken}");
            RestResponse response = await client.ExecuteAsync(request);

            if (response.StatusCode != System.Net.HttpStatusCode.Created && response.StatusCode != System.Net.HttpStatusCode.OK)
                throw new Exception(response.ErrorMessage);

            string json = response.Content;

            RequestRefund result = JsonConvert.DeserializeObject<RequestRefund>(json);

            return result;

        }       
    }


    public class RequestRefund
    {
        public int id { get; set; }
        public long payment_id { get; set; }
        public int amount { get; set; }
        public Metadata metadata { get; set; }

        [JsonProperty("sorce")]
        public ResultRefoundSource source { get; set; }
        public DateTime date_created { get; set; }
        public string unique_sequence_number { get; set; }
        public string refund_mode { get; set; }
        public int adjustment_amount { get; set; }
        public string status { get; set; }
        public object reason { get; set; }
        public object[] labels { get; set; }
        public int amount_refunded_to_payer { get; set; }
        public object additional_data { get; set; }
        public object[] partition_details { get; set; }
    }


    public class ResultRefoundSource
    {
        public string name { get; set; }
        public string id { get; set; }
        public string type { get; set; }
    }

}
