using Newtonsoft.Json;
using RestSharp;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebTEFMercadoPago
{
    public class GetDetailPayment
    {
        public async Task<DetailPayment> GetAllPayment(string accessToken, string idPayment)
        {
            var options = new RestClientOptions("https://api.mercadopago.com")
            {
                MaxTimeout = -1,
            };
            var client = new RestClient(options);
            var request = new RestRequest($"/v1/payments/{idPayment}", Method.Get);
            request.AddHeader("Authorization", $"Bearer {accessToken}");
            RestResponse response = await client.ExecuteAsync(request);

            if (response.StatusCode != System.Net.HttpStatusCode.Created && response.StatusCode != System.Net.HttpStatusCode.OK)
                throw new Exception(response.ErrorMessage);

            string json = response.Content;

            DetailPayment result = JsonConvert.DeserializeObject<DetailPayment>(json);

            return result;

        }

    }

    public class DetailPayment
    {
        public object accounts_info { get; set; }
        public object[] acquirer_reconciliation { get; set; }
        public Detail_AdditionalInfo additional_info { get; set; }
        public string authorization_code { get; set; }
        public bool binary_mode { get; set; }
        public object brand_id { get; set; }
        public string build_version { get; set; }
        public object call_for_authorize_id { get; set; }
        public bool captured { get; set; }
        public Card card { get; set; }
        public Charges_Details[] charges_details { get; set; }
        public int collector_id { get; set; }
        public object corporation_id { get; set; }
        public object counter_currency { get; set; }
        public int coupon_amount { get; set; }
        public string currency_id { get; set; }
        public DateTime date_approved { get; set; }
        public DateTime date_created { get; set; }
        public DateTime date_last_updated { get; set; }
        public object date_of_expiration { get; set; }
        public object deduction_schema { get; set; }
        public string description { get; set; }
        public object differential_pricing_id { get; set; }
        public string external_reference { get; set; }
        public Fee_Details[] fee_details { get; set; }
        public object financing_group { get; set; }
        public long id { get; set; }
        public int installments { get; set; }
        public object integrator_id { get; set; }
        public string issuer_id { get; set; }
        public bool live_mode { get; set; }
        public int marketplace_owner { get; set; }
        public object merchant_account_id { get; set; }
        public object merchant_number { get; set; }
        public Metadata metadata { get; set; }
        public DateTime money_release_date { get; set; }
        public object money_release_schema { get; set; }
        public object money_release_status { get; set; }
        public object notification_url { get; set; }
        public string operation_type { get; set; }
        public Order order { get; set; }
        public Payer payer { get; set; }
        public Payment_Method payment_method { get; set; }
        public string payment_method_id { get; set; }
        public string payment_type_id { get; set; }
        public object platform_id { get; set; }
        public string pos_id { get; set; }
        public string processing_mode { get; set; }
        public object[] refunds { get; set; }
        public int shipping_amount { get; set; }
        public object sponsor_id { get; set; }
        public string statement_descriptor { get; set; }
        public string status { get; set; }
        public string status_detail { get; set; }
        public string store_id { get; set; }
        public object tags { get; set; }
        public int taxes_amount { get; set; }
        public int transaction_amount { get; set; }
        public int transaction_amount_refunded { get; set; }
        public Transaction_Details transaction_details { get; set; }
    }

    public class Detail_AdditionalInfo
    {
        public object authentication_code { get; set; }
        public object available_balance { get; set; }
        public object nsu_processadora { get; set; }
    }

    public class Card
    {
        public string bin { get; set; }
        public Cardholder cardholder { get; set; }
        public DateTime date_created { get; set; }
        public DateTime date_last_updated { get; set; }
        public int expiration_month { get; set; }
        public int expiration_year { get; set; }
        public string first_six_digits { get; set; }
        public object id { get; set; }
        public string last_four_digits { get; set; }
    }

    public class Cardholder
    {
        public Identification identification { get; set; }
        public string name { get; set; }
    }

    public class Identification
    {
        public object number { get; set; }
        public object type { get; set; }
    }

    public class Metadata
    {
        public bool was_pin { get; set; }
        public string payment_intent_id { get; set; }
        public string pin_validation { get; set; }
        public string integration { get; set; }
        public bool is_fallback { get; set; }
        public bool cdcvm_validation { get; set; }
    }

    public class Order
    {
    }

    public class Payer
    {
        public object email { get; set; }
        public object entity_type { get; set; }
        public object first_name { get; set; }
        public string id { get; set; }
        public Identification1 identification { get; set; }
        public object last_name { get; set; }
        public object operator_id { get; set; }
        public Phone phone { get; set; }
        public object type { get; set; }
    }

    public class Identification1
    {
        public object number { get; set; }
        public object type { get; set; }
    }

    public class Phone
    {
        public object area_code { get; set; }
        public object extension { get; set; }
        public object number { get; set; }
    }

    public class Payment_Method
    {
        public string id { get; set; }
        public string issuer_id { get; set; }
        public string type { get; set; }
    }

    public class Transaction_Details
    {
        public object acquirer_reference { get; set; }
        public object external_resource_url { get; set; }
        public object financial_institution { get; set; }
        public int installment_amount { get; set; }
        public float net_received_amount { get; set; }
        public int overpaid_amount { get; set; }
        public object payable_deferral_period { get; set; }
        public object payment_method_reference_id { get; set; }
        public int total_paid_amount { get; set; }
    }

    public class Charges_Details
    {
        public Accounts accounts { get; set; }
        public Amounts amounts { get; set; }
        public int client_id { get; set; }
        public DateTime date_created { get; set; }
        public string id { get; set; }
        public DateTime last_updated { get; set; }
        public Metadata1 metadata { get; set; }
        public string name { get; set; }
        public object[] refund_charges { get; set; }
        public object reserve_id { get; set; }
        public string type { get; set; }
    }

    public class Accounts
    {
        public string from { get; set; }
        public string to { get; set; }
    }

    public class Amounts
    {
        public float original { get; set; }
        public int refunded { get; set; }
    }

    public class Metadata1
    {
    }

    public class Fee_Details
    {
        public float amount { get; set; }
        public string fee_payer { get; set; }
        public string type { get; set; }
    }

}
