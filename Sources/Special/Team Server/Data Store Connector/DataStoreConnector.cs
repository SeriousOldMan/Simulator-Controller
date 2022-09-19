using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Text;

namespace TeamServer {
    public class TeamServerConnector {
		static readonly HttpClient httpClient = new HttpClient();

		public class Parameters : Dictionary<string, string> { }

		string Server = "";

		public string Token { get; set; } = "";
		
		public TeamServerConnector() {
			ServicePointManager.SecurityProtocol |= SecurityProtocolType.Tls12 | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls;
		}

		public void Connect(string url, string token = null) {
			Server = url + ((url[url.Length - 1] == '/') ? "api/" : "/api/");

			if ((token != null) && (token != "")) {
				Token = token;

				ValidateToken();
			}
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

		public string Get(string request, Parameters arguments = null) {
			string result;

			try {
                string uri = BuildRequest(request, arguments);

                result = httpClient.GetStringAsync(uri).Result;
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
			string token = Get("login", new Parameters() { { "Name", name }, { "Password", password }, { "Type", "Store" } });

			Token = token;

			return token;
		}

		public string ValidateToken() {
			return Get("login/validateStoreToken");
		}

		public void ChangePassword(string newPassword) {
			Put("login/password", body: newPassword);
        }

		public void Logout() {
			Token = "";

			Delete("logout");
		}
		#endregion

		#region Administration
		public string GetAllAccounts() {
			return Get("account/allaccounts");
        }

		public string CreateAccount(string name, string eMail, string password, string minutes, string contract, string renewal) {
			return Post("account", body: BuildBody(new Parameters() { { "Name", name }, { "Password", password },
																	  { "EMail", eMail },
																	  { "Contract", contract }, { "ContractMinutes", renewal },
																	  { "AvailableMinutes", minutes } }));
		}

		public string GetAccount(string identifier) {
			return Get("account/" + identifier);
		}

		public void ChangeAccountEMail(string identifier, string eMail) {
			Put("account/" + identifier, body: BuildBody(new Parameters() { { "EMail", eMail } }));
		}

		public void ChangeAccountContract(string identifier, string contract, string renewal) {
			Put("account/" + identifier, body: BuildBody(new Parameters() { { "Contract", contract }, { "ContractMinutes", renewal } }));
		}

		public void ChangeAccountPassword(string identifier, string newPassword) {
			Put("account/" + identifier + "/password", body: newPassword);
		}

		public void SetAccountMinutes(string identifier, int minutes) {
			Put("account/" + identifier + "/minutes", body: minutes.ToString());
		}

		public void DeleteAccount(string identifier) {
			Delete("account/" + identifier);
		}
		#endregion

		#region Data
		public string Query(string table, string projection, string where)
        {

        }

		public void Delete(string table, string identifier)
        {

        }

		public void Insert(string table, string data)
        {

        }
		#endregion
	}
}