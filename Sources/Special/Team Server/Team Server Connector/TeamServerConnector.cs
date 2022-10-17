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

		public void Initialize(string url) {
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

		public string Get(string request, Parameters arguments = null, string body = null)
		{
			string result;

			try
			{
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
			catch (Exception e)
			{
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

		public string Connect(string token, string client, string name, string type, string session = "")
		{
			string connection;
				
			if (session != "")
                connection = Get("login/connect/session", new Parameters() { { "token", token },
																			 { "client", client }, { "name", name },
																			 { "type", type }, { "session", session } });
			else
				connection = Get("login/connect/admin", new Parameters() { { "token", token },
																		   { "client", client }, { "name", name },
																		   { "type", type } });

            Token = token;

			return connection;
		}

		public void KeepAlive(string identifier)
		{
            try
            {
                Get("login/" + identifier, new Parameters() { { "keepalive", "true" } });
            }
            catch (Exception)
            {
            }
        }

		public string ValidateToken()
		{
			return Get("login/validatetoken");
        }

        public string ValidateSessionToken()
        {
            return Get("session/validatetoken");
        }

        public string GetAllConnections()
		{
			return Get("login/allconnections");
		}

		public string GetAllSessions()
		{
			return Get("login/allsessions");
		}

		public string GetConnection(string identifier)
		{
			return Get("login/" + identifier);
		}

		public string GetAvailableMinutes() {
			return Get("login/accountavailableminutes");
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

		public string CreateAccount(string name, string eMail, string password, string sessionAccess, string dataAccess,
                                    string minutes, string contract, string renewal) {
			return Post("account", body: BuildBody(new Parameters() { { "Name", name }, { "Password", password },
																	  { "EMail", eMail },
                                                                      { "SessionAccess", sessionAccess }, { "DataAccess", dataAccess },
                                                                      { "Contract", contract }, { "ContractMinutes", renewal },
																	  { "AvailableMinutes", minutes } }));
		}

		public string GetAccount(string identifier) {
			return Get("account/" + identifier);
        }

        public void ChangeAccountEMail(string identifier, string eMail)
        {
            Put("account/" + identifier, body: BuildBody(new Parameters() { { "EMail", eMail } }));
        }

        public void ChangeAccountAccess(string identifier, string sessionAccess, string dataAccess)
        {
            Put("account/" + identifier, body: BuildBody(new Parameters() { { "SessionAccess", sessionAccess }, { "DataAccess", dataAccess } }));
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

		#region Task
		public string GetAllTasks() {
			return Get("task/alltasks");
		}
		public string CreateTask(string type, string operation, string frequency) {
			return Post("task", body: BuildBody(new Parameters() { { "Which", type },
																   { "What", operation },
																   { "When", frequency } }));
		}

		public string GetTask(string identifier) {
			return Get("task/" + identifier);
		}

		public string UpdateTask(string identifier, string operation, string frequency, bool active) {
			return Put("task/" + identifier, body: BuildBody(new Parameters() { { "What", operation },
																				{ "When", frequency },
																				{ "Active", active.ToString() } }));
		}

		public void DeleteTask(string identifier) {
			Delete("task/" + identifier);
		}
		#endregion

		#region Team
		public string GetAllTeams() {
			return Get("team/allteams");
		}

		public string GetTeam(string identifier) {
			return Get("team/" + identifier);
		}

		public string GetTeamDrivers(string identifier) {
			return Get("team/" + identifier + "/drivers");
		}

		public string GetTeamSessions(string identifier) {
			return Get("team/" + identifier + "/sessions");
		}

		public string CreateTeam(string name) {
			return Post("team", body: "Name=" + name);
		}

		public void DeleteTeam(string identifier) {
			Delete("team/" + identifier);
		}

		public void UpdateTeam(string identifier, string properties) {
			Put("team/" + identifier, body: properties);
		}
		#endregion

		#region Driver
		public string GetDriver(string identifier) {
			return Get("driver/" + identifier);
		}

		public string CreateDriver(string team, string forName, string surName, string nickName) {
			return Post("driver",
						arguments: new Parameters() { { "team", team } },
						body: BuildBody(new Parameters() { { "ForName", forName }, { "SurName", surName }, { "NickName", nickName } }));
		}

		public void DeleteDriver(string identifier) {
			Delete("driver/" + identifier);
		}

		public void UpdateDriver(string identifier, string properties) {
			Put("driver/" + identifier, body: properties);
		}
		#endregion

		#region Session
		public string GetSessions() {
			return Get("session/sessions");
		}

		public string CreateSession(string team, string name) {
			return Post("session",
						arguments: new Parameters() { { "team", team } },
						body: BuildBody(new Parameters() { { "Name", name } }));
		}

		public string GetSession(string identifier) {
			return Get("session/" + identifier);
		}

		public string GetSessionValue(string identifier, string name)
		{
			return Get("session/" + identifier + "/value",
					   arguments: new Parameters() { { "name", name } });
		}

		public void SetSessionValue(string identifier, string name, string value) {
			Put("session/" + identifier + "/value",
				arguments: new Parameters() { { "name", name } }, body: value);
		}

		public void DeleteSessionValue(string identifier, string name) {
			Delete("session/" + identifier + "/value", arguments: new Parameters() { { "name", name } });
		}

		public string GetSessionStintValue(string identifier, int stint, string name)
		{
			return Get("session/" + identifier + "/stint/" + stint + "/value",
					   arguments: new Parameters() { { "name", name } });
		}

		public void SetSessionStintValue(string identifier, int stint, string name, string value)
		{
			Put("session/" + identifier + "/stint/" + stint + "/value",
				arguments: new Parameters() { { "name", name } }, body: value);
		}

		public void DeleteSessionStintValue(string identifier, int stint, string name) {
			Delete("session/" + identifier + "/stint/" + stint + "/value",
				   arguments: new Parameters() { { "name", name } });
		}

		public string GetSessionLapValue(string identifier, int lap, string name)
		{
			return Get("session/" + identifier + "/lap/" + lap + "/value",
					   arguments: new Parameters() { { "name", name } });
		}

		public void SetSessionLapValue(string identifier, int lap, string name, string value)
		{
			Put("session/" + identifier + "/lap/" + lap + "/value",
				arguments: new Parameters() { { "name", name } }, body: value);
		}

		public void DeleteSessionLapValue(string identifier, int lap, string name) {
			Delete("session/" + identifier + "/lap/" + lap + "/value", arguments: new Parameters() { { "name", name } });
		}

		public string GetSessionTeam(string identifier) {
			return Get("session/" + identifier + "/team");
		}

		public string GetSessionConnections(string identifier)
		{
			return Get("session/" + identifier + "/connections");
		}

		public string GetSessionStint(string identifier, string stint) {
			return Get("session/" + identifier + "/stint",
					   arguments: new Parameters() { { "stint", stint } });
		}

		public string GetSessionLap(string identifier, string lap) {
			return Get("session/" + identifier + "/lap",
					   arguments: new Parameters() { { "lap", lap } });
		}

		public string GetSessionLastLap(string identifier) {
			return Get("session/" + identifier + "/lap/last");
		}

		public string GetSessionDriver(string identifier) {
			return Get("session/" + identifier + "/driver");
		}

		public string GetSessionCurrentStint(string identifier) {
			return Get("session/" + identifier + "/currentstint");
		}

		public string GetSessionStints(string identifier) {
			return Get("session/" + identifier + "/stints");
		}

		public void UpdateSession(string identifier, string properties) {
			Put("session/" + identifier, body: properties);
		}

		public void DeleteSession(string identifier) {
			Delete("session/" + identifier);
		}

		public void StartSession(string identifier, int duration, string car, string track) {
			Put("session/" + identifier + "/start",
				body: BuildBody(new Parameters() { { "Duration", duration.ToString() },
												   { "Car", car }, { "Track", track } }));
		}

		public void FinishSession(string identifier) {
			Put("session/" + identifier + "/finish");
		}

		public void ClearSession(string identifier)
		{
			Put("session/" + identifier + "/clear");
		}
		#endregion

		#region Stint
		public string StartStint(string session, string driver, int lap) {
			return Post("stint",
						arguments: new Parameters() { { "session", session }, { "driver", driver } },
						body: BuildBody(new Parameters() { { "Lap", lap.ToString() } }));
		}

		public string GetStintLap(string identifier) {
			return Get("stint/" + identifier + "/lap");
		}

		public string GetStintLaps(string identifier) {
			return Get("stint/" + identifier + "/laps");
		}

		public string GetStint(string identifier) {
			return Get("stint/" + identifier);
		}

		public string GetStintSession(string identifier) {
			return Get("stint/" + identifier + "/session");
		}

		public string GetStintDriver(string identifier) {
			return Get("stint/" + identifier + "/driver");
		}

		public string GetStintValue(string identifier, string name) {
			return Get("stint/" + identifier + "/value",
					   arguments: new Parameters() { { "name", name } });
		}

		public void SetStintValue(string identifier, string name, string value) {
			Put("stint/" + identifier + "/value",
				arguments: new Parameters() { { "name", name } }, body: value);
		}

		public void DeleteStintValue(string identifier, string name) {
			Put("stint/" + identifier + "/value", arguments: new Parameters() { { "name", name } });
		}
		#endregion

		#region Lap
		public string CreateLap(string stint, int lapNr) {
			return Post("lap",
						arguments: new Parameters() { { "stint", stint } },
						body: BuildBody(new Parameters() { { "Nr", lapNr.ToString() } }));
		}

		public string GetLap(string identifier) {
			return Get("lap/" + identifier);
		}

		public string GetLapStint(string identifier) {
			return Get("lap/" + identifier + "/stint");
		}

		public string GetLapValue(string identifier, string name) {
			return Get("lap/" + identifier + "/value",
					   arguments: new Parameters() { { "name", name } });
		}

		public void SetLapValue(string identifier, string name, string value) {
			Put("lap/" + identifier + "/value",
				arguments: new Parameters() { { "name", name } }, body: value);
		}

		public void DeleteLapValue(string identifier, string name) {
			Put("lap/" + identifier + "/value", arguments: new Parameters() { { "name", name } });
		}
		#endregion
	}
}