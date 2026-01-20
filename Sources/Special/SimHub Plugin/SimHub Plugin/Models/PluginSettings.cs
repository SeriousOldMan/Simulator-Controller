using System;

namespace SimulatorController.SimHub.Plugin
{
    /// <summary>
    /// Plugin configuration settings
    /// </summary>
    public class PluginSettings
    {
        /// <summary>
        /// Path to the Simulator Controller Session State JSON file
        /// </summary>
        public string JsonFilePath { get; set; }

        /// <summary>
        /// Polling interval in milliseconds (fallback mechanism)
        /// </summary>
        public int PollingInterval { get; set; } = 1000;

        /// <summary>
        /// Enable detailed debug logging
        /// </summary>
        public bool EnableDebugLogging { get; set; } = false;
    }
}
