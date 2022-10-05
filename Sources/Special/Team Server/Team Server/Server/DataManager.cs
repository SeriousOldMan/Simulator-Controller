using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;
using TeamServer.Model;
using TeamServer.Model.Access;
using TeamServer.Model.Data;

namespace TeamServer.Server
{
	public class DataManager : ManagerBase
    {
        public DataManager(ObjectManager objectManager, Token token) : base(objectManager, token)
        {
        }

        public DataManager(ObjectManager objectManager, Guid token) : base(objectManager, token)
        {
        }

        public DataManager(ObjectManager objectManager, string token) : base(objectManager, token)
        {
        }

        #region Generic
        protected void SetProperties(object obj, Dictionary<string, string> values)
		{
			foreach (KeyValuePair<string, string> kvp in values)
			{
				PropertyInfo propInfo =
					obj.GetType().GetProperty(kvp.Key, BindingFlags.Public | BindingFlags.Instance);

				if (propInfo != null && propInfo.CanWrite)
					propInfo.SetValue(obj, kvp.Value, null);
			}
		}
        #endregion

        #region Validation
        public override Token ValidateToken(Token token)
        {
            token = base.ValidateToken(token);

            if (!token.HasAccess(Token.TokenType.Data))
                throw new Exception("Token does not support data access...");

            return token;
        }

        public void ValidateAccount()
		{
			if (!Token.Account.Administrator)
				if (Token.Account.Contract != Model.Access.Account.ContractType.Expired)
					throw new Exception("Account is no longer valid...");
				else if (!Token.Account.DataAccess)
					throw new Exception("Account does not support data storage...");
		}

		public void ValidateLicense(License license)
		{
			if (license == null)
				throw new Exception("No valid license data...");
		}

		public void ValidateElectronics(Electronics electronics)
		{
			if (electronics == null)
				throw new Exception("No valid electronics data...");
		}

		public void ValidateTyres(Tyres tyres)
		{
			if (tyres == null)
				throw new Exception("No valid tyres data...");
		}

		public void ValidateBrakes(Brakes brakes)
		{
			if (brakes == null)
				throw new Exception("No valid brakes data...");
		}

		public void ValidateTyresPressures(TyresPressures tyresPressures)
		{
			if (tyresPressures == null)
				throw new Exception("No valid tyres pressures data...");
		}

		public void ValidateTyresPressuresDistribution(TyresPressuresDistribution tyresPressuresDistribution)
		{
			if (tyresPressuresDistribution == null)
				throw new Exception("No valid tyres pressures distribution data...");
		}
		#endregion

		#region License
		#region Query
		public IEnumerable<Guid> QueryLicenses(string where)
		{
			return ObjectManager.Connection.QueryAsync<License>(
				@"Select Identifier From Data_Licenses Where " + where).Result.Select(d => d.Identifier);
		}

		public int CountLicenses(string where)
		{
			return ObjectManager.Connection.ExecuteScalarAsync<int>(
				@"Select Count(ID) From Data_Licenses Where " + where).Result;
		}

		public License LookupLicense(Guid identifier)
		{
			License license = FindLicense(identifier);

			ValidateLicense(license);

			return license;
		}

		public License LookupLicense(string identifier)
		{
			return LookupLicense(new Guid(identifier));
		}

		public License FindLicense(Guid identifier)
		{
			return ObjectManager.GetLicenseAsync(identifier).Result;
		}

		public License FindLicense(string identifier)
		{
			return FindLicense(new Guid(identifier));
		}
		#endregion

		#region CRUD
		public License CreateLicense(Dictionary<string, string> values)
		{
			License license = new License() { AccountID = Token.AccountID };

			SetProperties(license, values);

			ValidateLicense(license);

			license.Save();

			return license;
		}

		public void UpdateLicense(License license, Dictionary<string, string> values)
		{
			ValidateLicense(license);

			SetProperties(license, values);

			license.Save();
		}
		public void DeleteLicense(License license)
		{
			if (license != null)
				license.Delete();
		}

		public void DeleteLicense(Guid identifier)
		{
			DeleteLicense(ObjectManager.GetLicenseAsync(identifier).Result);
		}

		public void DeleteLicense(string identifier)
		{
			DeleteLicense(new Guid(identifier));
		}
		#endregion
		#endregion

		#region Electronics
		#region Query
		public IEnumerable<Guid> QueryElectronics(string where)
		{
			return ObjectManager.Connection.QueryAsync<Electronics>(
				@"Select Identifier From Data_Electronics Where " + where).Result.Select(d => d.Identifier);
		}

		public int CountElectronics(string where)
		{
			return ObjectManager.Connection.ExecuteScalarAsync<int>(
				@"Select Count(ID) From Data_Electronics Where " + where).Result;
		}

		public Electronics LookupElectronics(Guid identifier)
		{
			Electronics electronics = FindElectronics(identifier);

			ValidateElectronics(electronics);

			return electronics;
		}

		public Electronics LookupElectronics(string identifier)
		{
			return LookupElectronics(new Guid(identifier));
		}

		public Electronics FindElectronics(Guid identifier)
		{
			return ObjectManager.GetElectronicsAsync(identifier).Result;
		}

		public Electronics FindElectronics(string identifier)
		{
			return FindElectronics(new Guid(identifier));
		}
		#endregion

		#region CRUD
		public Electronics CreateElectronics(Dictionary<string, string> values)
		{
			Electronics electronics = new Electronics() { AccountID = Token.AccountID };

			SetProperties(electronics, values);
			
			ValidateElectronics(electronics);

			electronics.Save();

			return electronics;
		}

		public void UpdateElectronics(Electronics electronics, Dictionary<string, string> values)
		{
			ValidateElectronics(electronics);

			SetProperties(electronics, values);

			electronics.Save();
		}

		public void DeleteElectronics(Electronics electronics)
		{
			if (electronics != null)
				electronics.Delete();
		}

		public void DeleteElectronics(Guid identifier)
		{
			DeleteElectronics(ObjectManager.GetElectronicsAsync(identifier).Result);
		}

		public void DeleteElectronics(string identifier)
		{
			DeleteElectronics(new Guid(identifier));
		}
		#endregion
		#endregion

		#region Tyres
		#region Query
		public IEnumerable<Guid> QueryTyres(string where)
		{
			return ObjectManager.Connection.QueryAsync<Tyres>(
				@"Select Identifier From Data_Tyres Where " + where).Result.Select(d => d.Identifier);
		}

		public int CountTyres(string where)
		{
			return ObjectManager.Connection.ExecuteScalarAsync<int>(
				@"Select Count(ID) From Data_Tyres Where " + where).Result;
		}

		public Tyres LookupTyres(Guid identifier)
		{
			Tyres tyres = FindTyres(identifier);

			ValidateTyres(tyres);

			return tyres;
		}

		public Tyres LookupTyres(string identifier)
		{
			return LookupTyres(new Guid(identifier));
		}

		public Tyres FindTyres(Guid identifier)
		{
			return ObjectManager.GetTyresAsync(identifier).Result;
		}

		public Tyres FindTyres(string identifier)
		{
			return FindTyres(new Guid(identifier));
		}
		#endregion

		#region CRUD
		public Tyres CreateTyres(Dictionary<string, string> values)
		{
			Tyres tyres = new Tyres() { AccountID = Token.AccountID };

			SetProperties(tyres, values);

			ValidateTyres(tyres);

			tyres.Save();

			return tyres;
		}

		public void UpdateTyres(Tyres tyres, Dictionary<string, string> values)
		{
			ValidateTyres(tyres);

			SetProperties(tyres, values);

			tyres.Save();
		}

		public void DeleteTyres(Tyres tyres)
		{
			if (tyres != null)
				tyres.Delete();
		}

		public void DeleteTyres(Guid identifier)
		{
			DeleteTyres(ObjectManager.GetTyresAsync(identifier).Result);
		}

		public void DeleteTyres(string identifier)
		{
			DeleteTyres(new Guid(identifier));
		}
		#endregion
		#endregion

		#region Brakes
		#region Query
		public IEnumerable<Guid> QueryBrakes(string where)
		{
			return ObjectManager.Connection.QueryAsync<Brakes>(
				@"Select Identifier From Data_Brakes Where " + where).Result.Select(d => d.Identifier);
		}

		public int CountBrakes(string where)
		{
			return ObjectManager.Connection.ExecuteScalarAsync<int>(
				@"Select Count(ID) From Data_Brakes Where " + where).Result;
		}

		public Brakes LookupBrakes(Guid identifier)
		{
			Brakes brakes = FindBrakes(identifier);

			ValidateBrakes(brakes);

			return brakes;
		}

		public Brakes LookupBrakes(string identifier)
		{
			return LookupBrakes(new Guid(identifier));
		}

		public Brakes FindBrakes(Guid identifier)
		{
			return ObjectManager.GetBrakesAsync(identifier).Result;
		}

		public Brakes FindBrakes(string identifier)
		{
			return FindBrakes(new Guid(identifier));
		}
		#endregion

		#region CRUD
		public Brakes CreateBrakes(Dictionary<string, string> values)
		{
			Brakes brakes = new Brakes() { AccountID = Token.AccountID };

			SetProperties(brakes, values);

			ValidateBrakes(brakes);

			brakes.Save();

			return brakes;
		}

		public void UpdateBrakes(Brakes brakes, Dictionary<string, string> values)
		{
			ValidateBrakes(brakes);

			SetProperties(brakes, values);

			brakes.Save();
		}

		public void DeleteBrakes(Brakes brakes)
		{
			if (brakes != null)
				brakes.Delete();
		}

		public void DeleteBrakes(Guid identifier)
		{
			DeleteBrakes(ObjectManager.GetBrakesAsync(identifier).Result);
		}

		public void DeleteBrakes(string identifier)
		{
			DeleteBrakes(new Guid(identifier));
		}
		#endregion
		#endregion

		#region TyresPressures
		#region Query
		public IEnumerable<Guid>  QueryTyresPressures(string where)
		{
			return ObjectManager.Connection.QueryAsync<TyresPressures>(
				@"Select Identifier From Data_TyresPressures Where " + where).Result.Select(d => d.Identifier);
		}

		public int CountTyresPressures(string where)
		{
			return ObjectManager.Connection.ExecuteScalarAsync<int>(
				@"Select Count(ID) From Data_TyresPressures Where " + where).Result;
		}

		public TyresPressures LookupTyresPressures(Guid identifier)
		{
			TyresPressures tyresPressures = FindTyresPressures(identifier);

			ValidateTyresPressures(tyresPressures);

			return tyresPressures;
		}

		public TyresPressures LookupTyresPressures(string identifier)
		{
			return LookupTyresPressures(new Guid(identifier));
		}

		public TyresPressures FindTyresPressures(Guid identifier)
		{
			return ObjectManager.GetTyresPressuresAsync(identifier).Result;
		}

		public TyresPressures FindTyresPressures(string identifier)
		{
			return FindTyresPressures(new Guid(identifier));
		}
		#endregion

		#region CRUD
		public TyresPressures CreateTyresPressures(Dictionary<string, string> values)
		{
			TyresPressures tyresPressures = new TyresPressures() { AccountID = Token.AccountID };

			SetProperties(tyresPressures, values);

			ValidateTyresPressures(tyresPressures);

			tyresPressures.Save();

			return tyresPressures;
		}

		public void UpdateTyresPressures(TyresPressures tyresPressures, Dictionary<string, string> values)
		{
			ValidateTyresPressures(tyresPressures);

			SetProperties(tyresPressures, values);

			tyresPressures.Save();
		}

		public void DeleteTyresPressures(TyresPressures tyresPressures)
		{
			if (tyresPressures != null)
				tyresPressures.Delete();
		}

		public void DeleteTyresPressures(Guid identifier)
		{
			DeleteTyresPressures(ObjectManager.GetTyresPressuresAsync(identifier).Result);
		}

		public void DeleteTyresPressures(string identifier)
		{
			DeleteTyresPressures(new Guid(identifier));
		}
		#endregion
		#endregion

		#region TyresPressuresDistribution
		#region Query
		public IEnumerable<Guid> QueryTyresPressuresDistribution(string where)
		{
			return ObjectManager.Connection.QueryAsync<TyresPressuresDistribution>(
				@"Select Identifier From Data_TyresPressuresDistribution Where " + where).Result.Select(d => d.Identifier);
		}

		public int CountTyresPressuresDistribution(string where)
		{
			return ObjectManager.Connection.ExecuteScalarAsync<int>(
				@"Select Count(ID) From Data_TyresPressuresDistribution Where " + where).Result;
		}

		public TyresPressuresDistribution LookupTyresPressuresDistribution(Guid identifier)
		{
			TyresPressuresDistribution tyresPressuresDistribution = FindTyresPressuresDistribution(identifier);

			ValidateTyresPressuresDistribution(tyresPressuresDistribution);

			return tyresPressuresDistribution;
		}

		public TyresPressuresDistribution LookupTyresPressuresDistribution(string identifier)
		{
			return LookupTyresPressuresDistribution(new Guid(identifier));
		}

		public TyresPressuresDistribution FindTyresPressuresDistribution(Guid identifier)
		{
			return ObjectManager.GetTyresPressuresDistributionAsync(identifier).Result;
		}

		public TyresPressuresDistribution FindTyresPressuresDistribution(string identifier)
		{
			return FindTyresPressuresDistribution(new Guid(identifier));
		}
		#endregion

		#region CRUD
		public TyresPressuresDistribution CreateTyresPressuresDistribution(Dictionary<string, string> values)
		{
			TyresPressuresDistribution tyresPressuresDistribution = new TyresPressuresDistribution() { AccountID = Token.AccountID };

			SetProperties(tyresPressuresDistribution, values);

			ValidateTyresPressuresDistribution(tyresPressuresDistribution);

			tyresPressuresDistribution.Save();

			return tyresPressuresDistribution;
		}

		public void UpdateTyresPressuresDistribution(TyresPressuresDistribution tyresPressuresDistribution, Dictionary<string, string> values)
		{
			ValidateTyresPressuresDistribution(tyresPressuresDistribution);

			SetProperties(tyresPressuresDistribution, values);

			tyresPressuresDistribution.Save();
		}

		public void DeleteTyresPressuresDistribution(TyresPressuresDistribution tyresPressuresDistribution)
		{
			if (tyresPressuresDistribution != null)
				tyresPressuresDistribution.Delete();
		}

		public void DeleteTyresPressuresDistribution(Guid identifier)
		{
			DeleteTyresPressuresDistribution(ObjectManager.GetTyresPressuresDistributionAsync(identifier).Result);
		}

		public void DeleteTyresPressuresDistribution(string identifier)
		{
			DeleteTyresPressuresDistribution(new Guid(identifier));
		}
		#endregion
		#endregion
	}
}