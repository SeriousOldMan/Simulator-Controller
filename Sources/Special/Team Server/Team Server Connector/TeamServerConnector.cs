using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;

namespace TeamServerConnector {
    public class Parameters : Dictionary<string, string> { }
	public class TeamServerConnector {
		static readonly HttpClient httpClient = new HttpClient();

		string Server = "";
		string Token = "";

		TeamServerConnector(string url, string token = "") {
			Server += (url[url.Length - 1] == '/') ? "teamserver/" : "/teamserver/";

			Token = token;
		}

		#region Requests
		public void ValidateResult(string result) {
			if (result.StartsWith("Error:"))
				throw new Exception(result.Replace("Error:", "").Trim());
		}

		public string BuildBody(Parameters parameters) {
			string keyValues = "";

			if (parameters.Count > 0)
				foreach (KeyValuePair<string, string> kv in parameters) {
					if (keyValues.Length > 0)
						keyValues += Environment.NewLine;

					keyValues += kv.Key + "=" + kv.Value;
				}

			return keyValues;
		}

		public string BuildRequest(string request, Parameters parameters = null) {
			string arguments = (Token.Length > 0) ? "token=" + Token : "";

			if ((parameters != null) && (parameters.Count > 0)) {
				foreach (KeyValuePair<string, string> kv in parameters) {
					if (arguments.Length > 0)
						arguments += "&";

					arguments += kv.Key + "=" + kv.Value;
				}

				arguments = "?" + arguments;
			}

			return Server + request + arguments;
		}

		public string Get(string request, Parameters arguments = null) {
			string result;

			try {
				result = httpClient.GetStringAsync(BuildRequest(request, arguments)).Result;
			}
			catch (Exception e) {
				result = e.Message;
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
				result = e.Message;
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
				result = e.Message;
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
				result = e.Message;
			}

			ValidateResult(result);
		}
		#endregion

		#region Access
		public string Login(string name, string password) {
			string result = Get("login", new Parameters() { { "Name", name }, { "Password", password } });

			return result;
		}

		public void Logout(string token) {
			Token = "";

			Get("logout");
		}
		#endregion

		#region Team
		public List<string> GetAllTeams() {
			return new List<string>(Get("team/allteams").Split(";"));
		}

		public string GetTeam(string identifier) {
			return Get("team/" + identifier);
		}

		public List<string> GetTeamDrivers(string identifier) {
			return new List<string>(Get("team/" + identifier + "/drivers").Split(";"));
		}

		public List<string> GetTeamSessions(string identifier) {
			return new List<string>(Get("team/" + identifier + "/sessions").Split(";"));
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
		public List<string> GetAllSessions() {
			return new List<string>(Get("session/allsessions").Split(";"));
		}

		public string GetSession(string identifier) {
			return Get("session/" + identifier);
		}

		public string GetSessionTeam(string identifier) {
			return Get("session/" + identifier + "/team");
		}

		public string GetSessionStint(string identifier) {
			return Get("session/" + identifier + "/stint");
		}

		public List<string> GetSessionStints(string identifier) {
			return new List<string>(Get("session/" + identifier + "/stints").Split(";"));
		}

		public string CreateSession(string team, string name, int duration, string car, string track, string raceNr) {
			return Post("session",
						arguments: new Parameters() { { "team", team } },
						body: BuildBody(new Parameters() { { "Name", name }, { "Duration", duration.ToString() },
														   { "Car", car }, { "Track", track }, { "RaceNr", raceNr  }  }));
		}

		public void DeleteSession(string identifier) {
			Delete("session/" + identifier);
		}

		public void UpdateSession(string identifier, string properties) {
			Put("session/" + identifier, body: properties);
		}

		public void StartSession(string identifier) {
			Put("session/" + identifier + "/start");
		}

		public void FinishSession(string identifier) {
			Put("session/" + identifier + "/finish");
		}
		#endregion

		#region Stint
		public string GetStint(string identifier) {
			return Get("stint/" + identifier);
		}

		public string GetStintDriver(string identifier) {
			return Get("stint/" + identifier + "/driver");
		}

		public string GetStintPitstopData(string identifier) {
			return Get("stint/" + identifier + "/pitstopdata");
		}

		public string SetStintPitstopData(string identifier, string pitstopData) {
			return Put("stint/" + identifier + "/pitstopdata", body: pitstopData);
		}

		public string GetStintLap(string identifier) {
			return Get("stint/" + identifier + "/lap");
		}

		public List<string> GetStintLaps(string identifier) {
			return new List<string>(Get("stint/" + identifier + "/laps").Split(";"));
		}

		public string CreateStint(string session, string driver, int lap) {
			return Post("stint",
						arguments: new Parameters() { { "session", session }, { "driver", driver } },
						body: BuildBody(new Parameters() { { "Lap", lap.ToString() }  }));
		}

		public void DeleteStint(string identifier) {
			Delete("stint/" + identifier);
		}

		public void UpdateStint(string identifier, string properties) {
			Put("stint/" + identifier, body: properties);
		}
		#endregion

		#region Lap
		public string GetLap(string identifier) {
			return Get("lap/" + identifier);
		}

		public string GetLapTelemetryData(string identifier) {
			return Get("lap/" + identifier + "/telemetrydata");
		}

		public string SetLapTelemetryData(string identifier, string telemetryData) {
			return Put("lap/" + identifier + "/telemetrydata", body: telemetryData);
		}

		public string GetLapPositionData(string identifier) {
			return Get("lap/" + identifier + "/positiondata");
		}

		public string SetLapPositionData(string identifier, string positionData) {
			return Put("lap/" + identifier + "/positiondata", body: positionData);
		}

		public string CreateLap(string stint, int lapNr) {
			return Post("lap",
						arguments: new Parameters() { { "stint", stint } },
						body: BuildBody(new Parameters() { { "Nr", lapNr.ToString() } }));
		}

		public void DeleteLap(string identifier) {
			Delete("lap/" + identifier);
		}
		#endregion
	}
}