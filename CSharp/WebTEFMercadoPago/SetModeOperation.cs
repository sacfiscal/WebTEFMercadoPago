using Newtonsoft.Json;
using RestSharp;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebTEFMercadoPago
{
    public class SetModeOperation
    {
        public async Task<DeviceMode> SetDeviceMode(string accessToken, string deviceMode)
        {
            var options = new RestClientOptions("https://api.mercadopago.com")
            {
                MaxTimeout = -1,
            };

            DeviceMode operatingMode = new DeviceMode { operating_mode = deviceMode };
            string body = JsonConvert.SerializeObject(operatingMode);

            var client = new RestClient(options);
            var request = new RestRequest("/point/integration-api/devices/GERTEC_MP35P__8701442341443345", Method.Patch);
            request.AddHeader("Content-Type", "application/json");
            request.AddHeader("Authorization", $"Bearer {accessToken}");
            //var body = @"{
            //    " + "\n" +
            //                @"  ""operating_mode"": ""PDV""
            //    " + "\n" +
            //                @"}";
            request.AddStringBody(body, DataFormat.Json);

            RestResponse response = await client.ExecuteAsync(request);

            if (response.StatusCode != System.Net.HttpStatusCode.Created && response.StatusCode != System.Net.HttpStatusCode.OK)
                throw new Exception(response.ErrorMessage);

            string json = response.Content;

            DeviceMode result = JsonConvert.DeserializeObject<DeviceMode>(json);

            return result;

        }
    }


    public class DeviceMode
    {
        [JsonProperty("operating_mode")]
        public string operating_mode { get; set; }
    }

}
