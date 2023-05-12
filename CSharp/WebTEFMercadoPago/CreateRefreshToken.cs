using Newtonsoft.Json;
using RestSharp;

namespace WebTEFMercadoPago
{
    public class CreateRefreshToken
    {
        public async Task<CredentialRefreshToken> GetRefreshToken(string clientId, string clientSecret, string code)
        {
            var options = new RestClientOptions("https://api.mercadopago.com")
            {
                MaxTimeout = -1,
            };

            var client = new RestClient(options);
            var request = new RestRequest("/oauth/token", Method.Post);
            request.AddHeader("Content-Type", "application/x-www-form-urlencoded");
            request.AddParameter("client_secret", clientSecret);
            request.AddParameter("client_id", clientId);
            request.AddParameter("grant_type", "refresh_token");
            request.AddParameter("refresh_token", code);

            RestResponse response = await client.ExecuteAsync(request);
            if (response.StatusCode != System.Net.HttpStatusCode.Created && response.StatusCode != System.Net.HttpStatusCode.OK)
                throw new Exception(response.ErrorMessage);

            string json = response.Content;

            CredentialRefreshToken credential = JsonConvert.DeserializeObject<CredentialRefreshToken>(json);

            return credential;
        }
    }


    public class CredentialRefreshToken
    {
        public CredentialRefreshToken()
        {
            created = DateTime.Now;
        }

        public bool Expired()
        {
            DateTime expires = created.AddMilliseconds(expires_in);
            return expires > DateTime.Now;
        }

        public string access_token { get; set; }
        public string token_type { get; set; }
        public long expires_in { get; set; }
        public string scope { get; set; }
        public int user_id { get; set; }
        public string refresh_token { get; set; }
        public string public_key { get; set; }
        public bool live_mode { get; set; }
        private DateTime created { get; set; }
    }

}
