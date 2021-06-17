using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace ACCUDPReader
{
    /// <summary>
    /// Just a cheap implementation of Viewmodels with auto-update capabilities - the laziest way to get this testclient doing it's job
    /// </summary>
    public abstract class KSObservableObject : INotifyPropertyChanged
    {
        #region Notification handling

        private Dictionary<string, object> _propertyDict = new Dictionary<string, object>();

        public event PropertyChangedEventHandler PropertyChanged;

        protected bool Set<T>(T value, [CallerMemberName] string propertyName = null)
        {
            bool hasChanged = false;
            if (!_propertyDict.ContainsKey(propertyName))
            {
                _propertyDict.Add(propertyName, value);
                hasChanged = true;
            }
            else
            {
                hasChanged = !object.Equals(_propertyDict[propertyName], value);
                _propertyDict[propertyName] = value;
            }

            if (hasChanged)
            {
                NotifyUpdate(propertyName);
            }

            return hasChanged;
        }

        protected void NotifyUpdate(string propertyName)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }

        protected T Get<T>([CallerMemberName] string propertyName = null)
        {
            if (!_propertyDict.ContainsKey(propertyName))
                return default(T);
            return (T)_propertyDict[propertyName];
        }
        #endregion
    }

}
