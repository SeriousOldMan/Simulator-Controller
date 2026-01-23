using System;
using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace SimulatorController.SimHub.Plugin
{
    /// <summary>
    /// Plugin configuration settings with INotifyPropertyChanged for proper data binding and persistence
    /// </summary>
    public class PluginSettings : INotifyPropertyChanged
    {
        private string _jsonFilePath = string.Empty;
        private int _pollingInterval = 1000;
        private bool _enableDebugLogging = false;

        public event PropertyChangedEventHandler? PropertyChanged;

        /// <summary>
        /// Path to the Simulator Controller Session State JSON file
        /// </summary>
        public string JsonFilePath
        {
            get => _jsonFilePath;
            set
            {
                if (_jsonFilePath != value)
                {
                    _jsonFilePath = value;
                    OnPropertyChanged();
                }
            }
        }

        /// <summary>
        /// Polling interval in milliseconds (fallback mechanism)
        /// </summary>
        public int PollingInterval
        {
            get => _pollingInterval;
            set
            {
                if (_pollingInterval != value)
                {
                    _pollingInterval = value;
                    OnPropertyChanged();
                }
            }
        }

        /// <summary>
        /// Enable detailed debug logging
        /// </summary>
        public bool EnableDebugLogging
        {
            get => _enableDebugLogging;
            set
            {
                if (_enableDebugLogging != value)
                {
                    _enableDebugLogging = value;
                    OnPropertyChanged();
                }
            }
        }

        protected void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }
}
