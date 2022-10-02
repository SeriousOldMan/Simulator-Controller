using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;
using TeamServer.Model;
using TeamServer.Model.Store;

namespace TeamServer.Server
{
	public class StoreManager : ManagerBase
	{
		public StoreManager(ObjectManager objectManager, Model.Access.StoreToken token) : base(objectManager, token)
		{
		}

		public StoreManager(ObjectManager objectManager, Model.Access.Token token) : base(objectManager, token)
		{
			TeamServer.TokenIssuer.ElevateToken(token);
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
		public void ValidateLicense(License license)
		{
			if (license == null)
				throw new Exception("Not valid license data...");
		}

		public void ValidateElectronics(Electronics electronics)
		{
			if (electronics == null)
				throw new Exception("Not valid electronics data...");
		}

		public void ValidateTyres(Tyres tyres)
		{
			if (tyres == null)
				throw new Exception("Not valid tyres data...");
		}

		public void ValidateTyresPressures(TyresPressures tyresPressures)
		{
			if (tyresPressures == null)
				throw new Exception("Not valid tyres pressures data...");
		}

		public void ValidateTyresPressuresDistribution(TyresPressuresDistribution tyresPressuresDistribution)
		{
			if (tyresPressuresDistribution == null)
				throw new Exception("Not valid tyres pressures distribution data...");
		}
		#endregion

		#region License
		#region Query
		public string QueryLicenses(string where)
		{
			return String.Join(";", ObjectManager.Connection.QueryAsync<License>(
				@"Select Identifier From Store_Licenses Where " + where).Result.Select(d => d.Identifier));
		}

		public int CountLicenses(string where)
		{
			return ObjectManager.Connection.ExecuteScalarAsync<int>(
				@"Select Count(ID) From Store_Licenses Where " + where).Result;
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
		public string QueryElectronics(string where)
		{
			return String.Join(";", ObjectManager.Connection.QueryAsync<Electronics>(
				@"Select Identifier From Store_Electronics Where " + where).Result.Select(d => d.Identifier));
		}

		public int CountElectronics(string where)
		{
			return ObjectManager.Connection.ExecuteScalarAsync<int>(
				@"Select Count(ID) From Store_Electronics Where " + where).Result;
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
		public string QueryTyres(string where)
		{
			return String.Join(";", ObjectManager.Connection.QueryAsync<Tyres>(
				@"Select Identifier From Store_Tyres Where " + where).Result.Select(d => d.Identifier));
		}

		public int CountTyres(string where)
		{
			return ObjectManager.Connection.ExecuteScalarAsync<int>(
				@"Select Count(ID) From Store_Tyres Where " + where).Result;
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

		#region TyresPressures
		#region Query
		public string QueryTyresPressures(string where)
		{
			return String.Join(";", ObjectManager.Connection.QueryAsync<TyresPressures>(
				@"Select Identifier From Store_TyresPressures Where " + where).Result.Select(d => d.Identifier));
		}

		public int CountTyresPressures(string where)
		{
			return ObjectManager.Connection.ExecuteScalarAsync<int>(
				@"Select Count(ID) From Store_TyresPressures Where " + where).Result;
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
		public string QueryTyresPressuresDistribution(string where)
		{
			return String.Join(";", ObjectManager.Connection.QueryAsync<TyresPressuresDistribution>(
				@"Select Identifier From Store_TyresPressuresDistribution Where " + where).Result.Select(d => d.Identifier));
		}

		public int CountTyresPressuresDistribution(string where)
		{
			return ObjectManager.Connection.ExecuteScalarAsync<int>(
				@"Select Count(ID) From Store_TyresPressuresDistribution Where " + where).Result;
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