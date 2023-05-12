using Newtonsoft.Json;
using RestSharp;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebTEFMercadoPago
{
    public class ListDevices
    {
        public async Task<DeviceResult> GetDeviceList(string accessToken)
        {
            var options = new RestClientOptions("https://api.mercadopago.com")
            {
                MaxTimeout = -1,
            };
            var client = new RestClient(options);
            var request = new RestRequest("/point/integration-api/devices", Method.Get);
            request.AddHeader("Authorization", $"Bearer {accessToken}");

            RestResponse response = await client.ExecuteAsync(request);
            if (response.StatusCode != System.Net.HttpStatusCode.Created && response.StatusCode != System.Net.HttpStatusCode.OK)
                throw new Exception(response.ErrorMessage);

            string json = response.Content;

            DeviceResult deviceResult = JsonConvert.DeserializeObject<DeviceResult>(json);

            return deviceResult;

        }
    }


    public class DeviceResult
    {
        public Device[]? devices { get; set; }
        public Paging paging { get; set; }
    }

    public class Device
    {
        public string id { get; set; }
        public string operating_mode { get; set; }
    }

    public class Paging
    {
        public int total { get; set; }
        public int limit { get; set; }
        public int offset { get; set; }
    }
}
