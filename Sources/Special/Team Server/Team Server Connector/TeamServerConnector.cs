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

		public string Connect(string url, string token = null) {
			Server = url + ((url[url.Length - 1] == '/') ? "api/" : "/api/");

			if ((token != null) && (token != "")) {
				Token = token;

				string remainingMinutes = GetTokenLifeTime();

				return remainingMinutes;
			}
			else
				return "Ok";
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
			string token = Get("login", new Parameters() { { "Name", name }, { "Password", password } });

			Token = token;

			return token;
		}

		public string GetMinutesLeft() {
			return Get("login/accountminutesleft");
		}

		public string GetTokenLifeTime() {
			return Get("login/tokenminutesleft");
		}

		public void Logout() {
			Token = "";

			Get("logout");
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
		public string GetAllSessions() {
			return Get("session/allsessions");
		}

		public string CreateSession(string team, string name) {
			return Post("session",
						arguments: new Parameters() { { "team", team } },
						body: BuildBody(new Parameters() { { "Name", name } }));
		}

		public string GetSession(string identifier) {
			return Get("session/" + identifier);
		}

		public string GetSessionValue(string identifier, string name) {
			return Get("session/" + identifier + "/value",
					   arguments: new Parameters() { { "name", name } });
		}

		public void SetSessionValue(string identifier, string name, string value) {
			Put("session/" + identifier + "/value",
				arguments: new Parameters() { { "name", name } }, body: value);
		}

		public string GetSessionTeam(string identifier) {
			return Get("session/" + identifier + "/team");
		}

		public string GetSessionLap(string identifier, string lap) {
			return Get("session/" + identifier + "/lap",
					   arguments: new Parameters() { { "lap", lap } });
		}

		public string GetSessionDriver(string identifier) {
			return Get("session/" + identifier + "/driver");
		}

		public string GetSessionStint(string identifier) {
			return Get("session/" + identifier + "/stint");
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

		public string GetStintDriver(string identifier) {
			return Get("stint/" + identifier + "/driver");
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

		public string GetLapTelemetryData(string identifier) {
			return Get("lap/" + identifier + "/telemetrydata");
		}

		public string SetLapTelemetryData(string identifier, string telemetryData) {
			return Put("lap/" + identifier + "/telemetrydata", body: telemetryData);
		}

		public string GetLapPositionsData(string identifier) {
			return Get("lap/" + identifier + "/positionsData");
		}

		public string SetLapPositionsData(string identifier, string positionsData) {
			return Put("lap/" + identifier + "/positionsData", body: positionsData);
		}
		#endregion
	}
}