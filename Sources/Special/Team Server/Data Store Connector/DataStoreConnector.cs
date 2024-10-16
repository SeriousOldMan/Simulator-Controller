﻿using System;
using System.Collections.Generic;
using System.Data.SqlTypes;
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

		string ServerURL = "";

		public string Token { get; set; } = "";
		
		public DataConnector() {
			ServicePointManager.SecurityProtocol |= SecurityProtocolType.Tls12 | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls;
		}

		public void Initialize(string url, string token = null) {
			ServerURL = url + ((url[url.Length - 1] == '/') ? "api/" : "/api/");

			if (token != null)
				Token = token;
			else
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

			return ServerURL + request + arguments;
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

		public string RenewDataToken()
		{
			try
			{
				Delete("login/token/" + GetDataToken(), new Parameters() { { "token", Token } });
			}
			catch { }

			return GetDataToken();
		}

		public string Connect(string token, string client, string name)
		{
			string connection = Get("login/connect/data", new Parameters() { { "token", token },
																			 { "client", client }, { "name", name },
																			 { "type", "Internal" } });

			Token = token;

			return connection;
        }

        public int KeepAlive(string identifier)
        {
			try
			{
				Get("login/" + identifier, new Parameters() { { "keepalive", "true" } });

				return 1;
			}
			catch (Exception)
			{
				return 0;
			}
        }

        public string ValidateToken()
        {
            return Get("login/validatetoken");
        }

        public string ValidateDataToken()
        {
            return Get("data/validatetoken");
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
		public string GetServerTimestamp()
		{
            return Get("data/timestamp");
        }

		public string QueryData(string table, string where)
		{
			return Put("data/query/" + table.ToLower(), body: where);
		}

		public string CountData(string table, string where)
		{
			return Put("data/count/" + table.ToLower(), body: where);
		}

		public string GetData(string table, string identifier)
		{
			return Get("data/" + table.ToLower() + "/" + identifier);
		}

		public void UpdateData(string table, string identifier, string properties)
		{
			Put("data/" + table.ToLower() + "/" + identifier, body: properties);
		}

		public void DeleteData(string table, string identifier)
        {
			Delete("data/" + table.ToLower() + "/" + identifier);
		}

		public string CreateData(string table, string properties)
        {
			return Post("data/" + table.ToLower(), body: properties);
		}

        public string GetDataValue(string table, string identifier, string name)
        {
            return Get("data/" + table.ToLower() + "/" + identifier + "/value",
                       arguments: new Parameters() { { "name", name } });
        }

        public void SetDataValue(string table, string identifier, string name, string value)
        {
            Put("data/" + table.ToLower() + "/" + identifier + "/value",
                arguments: new Parameters() { { "name", name } }, body: value);
        }

        public void DeleteDataValue(string table, string identifier, string name)
        {
            Delete("data/" + table.ToLower() + "/" + identifier + "/value", arguments: new Parameters() { { "name", name } });
        }
        #endregion
    }
}