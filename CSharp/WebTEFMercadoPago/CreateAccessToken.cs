using Newtonsoft.Json;
using RestSharp;

namespace WebTEFMercadoPago
{
    public class CreateAccessToken
    {
        public async Task<CredentialAccessToken> GetAccessToken(string clientId, string clientSecret, string code, string redirectUri)
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
            request.AddParameter("grant_type", "authorization_code");
            request.AddParameter("code", code);
            request.AddParameter("redirect_uri", redirectUri);

            RestResponse response = await client.ExecuteAsync(request);
            if (response.StatusCode != System.Net.HttpStatusCode.Created && response.StatusCode != System.Net.HttpStatusCode.OK)
                throw new Exception(response.ErrorMessage);

            string json = response.Content;

            CredentialAccessToken credential = JsonConvert.DeserializeObject<CredentialAccessToken>(json);
            
            return credential;
        }
        
    }


    public class CredentialAccessToken
    {
        public CredentialAccessToken()
        {
            created = DateTime.Now;
            DateTime expires = created.AddMilliseconds(expires_in);
            expires = expires.AddMilliseconds(expires_in);
        }

        public bool Expired()
        {
            DateTime expires2 = DateTimeOffset.FromUnixTimeMilliseconds(expires_in).DateTime;
            DateTime expires = created.AddMilliseconds(expires_in);
            return expires < DateTime.Now;
            
        }

        public string access_token { get; set; }
        public string token_type { get; set; }
        public long expires_in { get; set; }
        public DateTime expires { get; set; }
        public string scope { get; set; }
        public int user_id { get; set; }
        public string refresh_token { get; set; }
        public string public_key { get; set; }
        public bool live_mode { get; set; }
        private DateTime created { get; set; }
    }

}