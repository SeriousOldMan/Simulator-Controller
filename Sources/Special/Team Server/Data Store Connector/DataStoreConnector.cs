using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;

namespace TeamServer {
    public class DataConnector {
		static readonly HttpClient httpClient = new HttpClient();

		public class Parameters : Dictionary<string, string> {
			public Parameters() { }

			public Parameters(string keyValues) {
				foreach (var kv in ParseKeyValues(keyValues))
					this[kv.Key] = kv.Value;
            }

			public static Dictionary<string, string> ParseKeyValues(string text)
			{
				var keyValues = text.Replace("\r", "").Split('\n');

				return keyValues.Select(value => value.Split('=')).ToDictionary(pair => pair[0].Trim(), pair => pair[1].Trim());
			}
		}

		string Server = "";

		public string Token { get; set; } = "";
		
		public DataConnector() {
			ServicePointManager.SecurityProtocol |= SecurityProtocolType.Tls12 | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls;
		}

		public void Initialize(string url, string token = null) {
			Server = url + ((url[url.Length - 1] == '/') ? "api/" : "/api/");

			Token = "";
		}

		#region Requests
		public void ValidateResult(string result) {
			if (result.StartsWith("Error:"))
				throw new Exception(result.Replace("Error:", "").Trim());
		}

		public string BuildBody(Parameters parameters) {
			string keyValues = "";

			if (parameters.Count > 0)
				foreach (var kv in parameters) {
					if (keyValues.Length > 0)
						keyValues += '\n';

					keyValues += kv.Key + "=" + kv.Value;
				}

			return keyValues;
		}

		public string BuildRequest(string request, Parameters parameters = null) {
			string arguments = (Token.Length > 0) ? "token=" + Token : "";

			if ((parameters != null) && (parameters.Count > 0)) {
				foreach (var kv in parameters) {
					if (arguments.Length > 0)
						arguments += "&";

					arguments += kv.Key + "=" + kv.Value;
				}
			}

			if (arguments.Length > 0)
				arguments = "?" + arguments;

			return Server + request + arguments;
		}

		public string Get(string request, Parameters arguments = null, string body = null) {
			string result;

			try {
                string uri = BuildRequest(request, arguments);

				if (body == null)
					result = httpClient.GetStringAsync(uri).Result;
				else
                {
					var httpRequest = new HttpRequestMessage
					{
						Method = HttpMethod.Get,
						RequestUri = new Uri(uri),
						Content = new StringContent(body, Encoding.Unicode)
					};

					var response = httpClient.SendAsync(httpRequest).Result;

					response.EnsureSuccessStatusCode();

					result = response.Content.ReadAsStringAsync().Result;
				}
			}
			catch (Exception e) {
				result = "Error: " + e.Message;
			}

			ValidateResult(result);

			return result;
		}

		public string Put(string request, Parameters arguments = null, string body = "") {
			string result;

			try {
				HttpContent content = new StringContent(body, Encoding.Unicode);

				HttpResponseMessage response = httpClient.PutAsync(BuildRequest(request, arguments), content).Result;

				response.EnsureSuccessStatusCode();

				result = response.Content.ReadAsStringAsync().Result;
			}
			catch (Exception e) {
				result = "Error: " + e.Message;
			}

			ValidateResult(result);

			return result;
		}

		public string Post(string request, Parameters arguments = null, string body = "") {
			string result;

			try {
				HttpContent content = new StringContent(body, Encoding.Unicode);

				HttpResponseMessage response = httpClient.PostAsync(BuildRequest(request, arguments), content).Result;

				response.EnsureSuccessStatusCode();

				result = response.Content.ReadAsStringAsync().Result;
			}
			catch (Exception e) {
				result = "Error: " + e.Message;
			}

			ValidateResult(result);

			return result;
		}

		public void Delete(string request, Parameters arguments = null) {
			string result;

			try {
				HttpResponseMessage response = httpClient.DeleteAsync(BuildRequest(request, arguments)).Result;

				response.EnsureSuccessStatusCode();

				result = response.Content.ReadAsStringAsync().Result;
			}
			catch (Exception e) {
				result = "Error: " + e.Message;
			}

			ValidateResult(result);
		}
		#endregion

		#region Access
		public string Login(string name, string password) {
			string token = Get("login", new Parameters() { { "Name", name }, { "Password", password } });

			Token = token;

			return token;
		}

		public string GetSessionToken()
		{
			return Get("login/token/session", new Parameters() { { "token", Token } });
		}

		public string GetDataToken()
		{
			return Get("login/token/data", new Parameters() { { "token", Token } });
		}

		public string Connect(string token, string client, string name)
		{
			string connection = Get("login/connect/data", new Parameters() { { "token", token },
																			 { "client", client }, { "name", name } });

			Token = token;

			return connection;
		}

		public void KeepAlive(string identifier)
		{
			GetConnection(identifier);
		}

		public void Logout() {
			Token = "";

			Delete("logout");
		}

		public string GetConnection(string identifier)
		{
			return Get("login/" + identifier);
		}
		#endregion

		#region Data
		public string QueryData(string table, string where)
		{
			return Get("data/query/" + table, body: where);
		}

		public string CountData(string table, string where)
		{
			return Get("data/count/" + table, body: where);
		}

		public string GetData(string table, string identifier)
		{
			return Get("data/" + table + "/" + identifier);
		}

		public void UpdateData(string table, string identifier, string properties)
		{
			Put("data/" + table + "/" + identifier, body: properties);
		}

		public void DeleteData(string table, string identifier)
        {
			Delete("data/" + table + "/" + identifier);
		}

		public string InsertData(string table, string properties)
        {
			return Post("data/" + table, body: properties);
		}
		#endregion
	}
}