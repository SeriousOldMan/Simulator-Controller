using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading;
using System.Windows.Controls;
using System.Windows.Media;
using GameReaderCommon;
using SimHub.Plugins;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace SimulatorController.SimHub.Plugin
{
    /// <summary>
    /// SimHub plugin that reads Simulator Controller's session state JSON and exposes telemetry data as SimHub properties.
    /// This plugin is designed with robust null handling to prevent crashes from missing or incomplete data.
    /// </summary>
    [PluginDescription("Integrates Simulator Controller telemetry data into SimHub")]
    [PluginAuthor("Simulator Controller Team")]
    [PluginName("Simulator Controller Integration")]
    public class SimulatorControllerPlugin : IPlugin, IDataPlugin, IWPFSettingsV2
    {
        private const string PropertyPrefix = "SC";
        private const int DefaultPollingInterval = 1000;
        private const int MaxPropertyDepth = 10;
        private static readonly string[] WheelPositions = { "FrontLeft", "FrontRight", "RearLeft", "RearRight" };
        
        private PluginSettings _settings = null!;
        private FileSystemWatcher? _fileWatcher;
        private Timer? _pollingTimer;
        private DateTime _lastFileWriteTime;
        private JObject? _currentState;
        private readonly object _stateLock = new object();
        private bool _isInitialized = false;
        private readonly object _initLock = new object();
        private Timer? _initTimer;
        
        public PluginManager PluginManager { get; set; }
        
        // Required by SimHub for plugin identification
        public string PluginId => "SimulatorController.SimHub.Plugin";
        
        // No icon needed
        public ImageSource PictureIcon => null!;
        
        public string LeftMenuTitle => "Simulator Controller";

        /// <summary>
        /// Called when SimHub initializes the plugin
        /// </summary>
        public void Init(PluginManager pluginManager)
        {
            this.PluginManager = pluginManager;
            global::SimHub.Logging.Current.Info("Simulator Controller Plugin: Init called");
            
            // Load settings immediately (required for UI binding)
            // Do NOT modify settings here - let them persist exactly as saved
            _settings = this.ReadCommonSettings("GeneralSettings", () => new PluginSettings());
            
            global::SimHub.Logging.Current.Info($"Simulator Controller Plugin: Settings loaded - Path: {_settings?.JsonFilePath ?? "null"}");
            
            // Start monitoring on a background thread to avoid blocking SimHub startup
            _initTimer = new Timer(StartMonitoringDelayed, null, 500, Timeout.Infinite);
        }
        
        /// <summary>
        /// Start monitoring on background thread (non-blocking)
        /// </summary>
        private void StartMonitoringDelayed(object? state)
        {
            lock (_initLock)
            {
                if (_isInitialized)
                    return;
                    
                try
                {
                    StartMonitoring();
                    _isInitialized = true;
                    global::SimHub.Logging.Current.Info($"Simulator Controller Plugin: Monitoring started for: {_settings?.JsonFilePath ?? "unknown"}");
                }
                catch (Exception ex)
                {
                    global::SimHub.Logging.Current.Error($"Simulator Controller Plugin: Failed to start monitoring: {ex.Message}");
                }
                finally
                {
                    // Dispose init timer
                    _initTimer?.Dispose();
                    _initTimer = null;
                }
            }
        }

        /// <summary>
        /// Called by SimHub on each data update tick
        /// </summary>
        public void DataUpdate(PluginManager pluginManager, ref GameData data)
        {
            // Update properties on every tick from current state
            if (_currentState != null)
            {
                UpdateSimHubPropertiesOnDataUpdate(pluginManager, ref data);
            }
        }

        /// <summary>
        /// Called when SimHub closes
        /// </summary>
        public void End(PluginManager pluginManager)
        {
            try
            {
                global::SimHub.Logging.Current.Info("Simulator Controller Plugin: Shutting down...");
                
                // CRITICAL: Save settings when SimHub closes completely
                if (_settings != null)
                {
                    global::SimHub.Logging.Current.Info($"Simulator Controller Plugin: Saving settings on shutdown - Path: '{_settings.JsonFilePath}', Interval: {_settings.PollingInterval}ms");
                    this.SaveCommonSettings("GeneralSettings", _settings);
                    
                    // Verify the save worked
                    var verifySettings = this.ReadCommonSettings("GeneralSettings", () => new PluginSettings());
                    if (verifySettings != null && !string.IsNullOrEmpty(verifySettings.JsonFilePath))
                    {
                        global::SimHub.Logging.Current.Info($"Simulator Controller Plugin: Settings verified saved on shutdown - Path: '{verifySettings.JsonFilePath}'");
                    }
                    else
                    {
                        global::SimHub.Logging.Current.Error("Simulator Controller Plugin: Settings verification failed on shutdown!");
                    }
                }
                
                StopMonitoring();
            }
            catch (Exception ex)
            {
                global::SimHub.Logging.Current.Error($"Simulator Controller Plugin: Error during shutdown: {ex.Message}");
            }
        }

        /// <summary>
        /// Start monitoring the JSON file for changes
        /// </summary>
        private void StartMonitoring()
        {
            StopMonitoring();
            
            try
            {
                string filePath = _settings.JsonFilePath;
                
                if (string.IsNullOrWhiteSpace(filePath))
                {
                    if (_settings.EnableDebugLogging)
                        global::SimHub.Logging.Current.Warn("Simulator Controller Plugin: No file path configured");
                    return;
                }
                
                string directory = Path.GetDirectoryName(filePath);
                string filename = Path.GetFileName(filePath);
                
                // Create directory if it doesn't exist
                if (!string.IsNullOrEmpty(directory) && !Directory.Exists(directory))
                {
                    Directory.CreateDirectory(directory);
                }
                
                // Initial read (only if file exists to prevent startup delay)
                if (File.Exists(filePath))
                {
                    ReadAndUpdateState();
                }
                
                // Setup FileSystemWatcher for efficient file change detection
                if (!string.IsNullOrEmpty(directory) && Directory.Exists(directory))
                {
                    _fileWatcher = new FileSystemWatcher(directory, filename)
                    {
                        NotifyFilter = NotifyFilters.LastWrite | NotifyFilters.Size,
                        EnableRaisingEvents = true
                    };
                    
                    _fileWatcher.Changed += OnFileChanged;
                    _fileWatcher.Error += OnFileWatcherError;
                    
                    if (_settings.EnableDebugLogging)
                        global::SimHub.Logging.Current.Info($"Simulator Controller Plugin: FileSystemWatcher started for {filePath}");
                }
                
                // Fallback polling timer (in case FileSystemWatcher misses updates)
                int interval = _settings.PollingInterval > 0 ? _settings.PollingInterval : DefaultPollingInterval;
                _pollingTimer = new Timer(OnPollingTimerTick, null, interval, interval);
                
                if (_settings.EnableDebugLogging)
                    global::SimHub.Logging.Current.Info($"Simulator Controller Plugin: Polling timer started ({interval}ms)");
            }
            catch (Exception ex)
            {
                global::SimHub.Logging.Current.Error($"Simulator Controller Plugin: Error starting monitoring: {ex.Message}");
            }
        }

        /// <summary>
        /// Stop monitoring the JSON file
        /// </summary>
        private void StopMonitoring()
        {
            if (_fileWatcher != null)
            {
                _fileWatcher.EnableRaisingEvents = false;
                _fileWatcher.Changed -= OnFileChanged;
                _fileWatcher.Error -= OnFileWatcherError;
                _fileWatcher.Dispose();
                _fileWatcher = null;
            }
            
            if (_pollingTimer != null)
            {
                _pollingTimer.Dispose();
                _pollingTimer = null;
            }
        }

        /// <summary>
        /// Handle file change events from FileSystemWatcher
        /// </summary>
        private void OnFileChanged(object sender, FileSystemEventArgs e)
        {
            ReadAndUpdateState();
        }

        /// <summary>
        /// Handle FileSystemWatcher errors
        /// </summary>
        private void OnFileWatcherError(object sender, ErrorEventArgs e)
        {
            Exception ex = e.GetException();
            global::SimHub.Logging.Current.Error($"Simulator Controller Plugin: FileSystemWatcher error: {ex?.Message ?? "Unknown error"}");
            
            // Try to restart monitoring
            StartMonitoring();
        }

        /// <summary>
        /// Polling timer callback (fallback mechanism)
        /// </summary>
        private void OnPollingTimerTick(object state)
        {
            try
            {
                string filePath = _settings.JsonFilePath;
                
                if (File.Exists(filePath))
                {
                    FileInfo fileInfo = new FileInfo(filePath);
                    DateTime lastWrite = fileInfo.LastWriteTimeUtc;
                    
                    // Only read if file has been modified since last read
                    if (lastWrite > _lastFileWriteTime)
                    {
                        ReadAndUpdateState();
                    }
                }
            }
            catch (Exception ex)
            {
                if (_settings.EnableDebugLogging)
                    global::SimHub.Logging.Current.Error($"Simulator Controller Plugin: Polling error: {ex.Message}");
            }
        }

        /// <summary>
        /// Read JSON file and update SimHub properties
        /// CRITICAL: This method handles all null cases gracefully and never blocks
        /// </summary>
        private void ReadAndUpdateState()
        {
            global::SimHub.Logging.Current.Info("Simulator Controller Plugin: ReadAndUpdateState called");
            
            // Skip if settings not initialized
            if (_settings == null)
            {
                global::SimHub.Logging.Current.Warn("Simulator Controller Plugin: Settings is null");
                return;
            }
                
            try
            {
                string filePath = _settings.JsonFilePath;
                
                global::SimHub.Logging.Current.Info($"Simulator Controller Plugin: File path: {filePath}");
                
                if (string.IsNullOrWhiteSpace(filePath) || !File.Exists(filePath))
                {
                    global::SimHub.Logging.Current.Warn($"Simulator Controller Plugin: File doesn't exist: {filePath}");
                    return; // Silently skip if file doesn't exist
                }
                
                // Read file with retry logic (handle file locks) - but with timeout
                string? jsonContent = null;
                const int maxRetries = 2; // Reduced retries
                const int retryDelayMs = 10; // Reduced delay
                
                for (int attempt = 0; attempt < maxRetries; attempt++)
                {
                    try
                    {
                        // Use async-friendly file reading with short timeout
                        using FileStream stream = new FileStream(filePath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite, 4096, FileOptions.Asynchronous);
                        using StreamReader reader = new StreamReader(stream);
                        jsonContent = reader.ReadToEnd();
                        _lastFileWriteTime = File.GetLastWriteTimeUtc(filePath);
                        break;
                    }
                    catch (IOException) when (attempt < maxRetries - 1)
                    {
                        Thread.Sleep(retryDelayMs);
                    }
                    catch (UnauthorizedAccessException)
                    {
                        return; // Skip if no permissions
                    }
                }
                
                if (string.IsNullOrWhiteSpace(jsonContent))
                {
                    return; // Silently skip empty files
                }
                
                // Parse JSON dynamically with JObject to handle ANY structure
                JObject? newState = null;
                try
                {
                    newState = JObject.Parse(jsonContent);
                }
                catch (JsonException)
                {
                    // If JSON is invalid, just skip silently
                    return;
                }
                
                // Update state (properties are exposed in DataUpdate)
                lock (_stateLock)
                {
                    _currentState = newState;
                }
                
                global::SimHub.Logging.Current.Info("Simulator Controller Plugin: State updated successfully");
            }
            catch (Exception ex)
            {
                // Never throw - just log and continue
                if (_settings?.EnableDebugLogging == true)
                    global::SimHub.Logging.Current.Error($"Simulator Controller Plugin: Error reading state: {ex.Message}");
            }
        }

        #region Settings UI

        public Control GetWPFSettingsControl(PluginManager pluginManager)
        {
            try
            {
                // Ensure settings are loaded (in case Init hasn't run yet)
                if (_settings == null)
                {
                    _settings = this.ReadCommonSettings("GeneralSettings", () => new PluginSettings());
                }
                
                // Initialize default path ONLY if truly empty (first time use)
                if (string.IsNullOrWhiteSpace(_settings.JsonFilePath))
                {
                    string documentsPath = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);
                    _settings.JsonFilePath = Path.Combine(documentsPath, "Simulator Controller", "Temp", "Session State.json");
                    
                    // Save the default immediately
                    this.SaveCommonSettings("GeneralSettings", _settings);
                    global::SimHub.Logging.Current.Info($"Simulator Controller Plugin: Default path initialized and saved: {_settings.JsonFilePath}");
                }
                
                return new SettingsControl(this);
            }
            catch (Exception ex)
            {
                global::SimHub.Logging.Current.Error($"Simulator Controller Plugin: Failed to create settings control: {ex.Message}");
                // Return empty control on error
                return new System.Windows.Controls.UserControl 
                { 
                    Content = new System.Windows.Controls.TextBlock { Text = "Error loading settings UI" }
                };
            }
        }

        public void OnShowSettings()
        {
            // Reload settings when UI is shown to get latest values
            if (_settings != null)
            {
                try
                {
                    var freshSettings = this.ReadCommonSettings("GeneralSettings", () => new PluginSettings());
                    if (freshSettings != null)
                    {
                        // Update properties to trigger PropertyChanged events
                        _settings.JsonFilePath = freshSettings.JsonFilePath ?? _settings.JsonFilePath;
                        _settings.PollingInterval = freshSettings.PollingInterval;
                        _settings.EnableDebugLogging = freshSettings.EnableDebugLogging;
                        
                        global::SimHub.Logging.Current.Info($"Simulator Controller Plugin: Settings reloaded - Path: {_settings.JsonFilePath}");
                    }
                }
                catch (Exception ex)
                {
                    global::SimHub.Logging.Current.Error($"Simulator Controller Plugin: Error reloading settings: {ex.Message}");
                }
            }
        }

        public void OnSettingsClosed()
        {
            try
            {
                // Save settings when UI is closed
                if (_settings != null)
                {
                    global::SimHub.Logging.Current.Info($"Simulator Controller Plugin: Saving settings - Path: '{_settings.JsonFilePath}', Interval: {_settings.PollingInterval}ms, Debug: {_settings.EnableDebugLogging}");
                    
                    this.SaveCommonSettings("GeneralSettings", _settings);
                    
                    // Force verify the save worked by reading it back
                    var verifySettings = this.ReadCommonSettings("GeneralSettings", () => new PluginSettings());
                    if (verifySettings != null)
                    {
                        global::SimHub.Logging.Current.Info($"Simulator Controller Plugin: Settings verified saved - Path: '{verifySettings.JsonFilePath}'");
                    }
                    
                    // Restart monitoring with new settings
                    StartMonitoring();
                }
            }
            catch (Exception ex)
            {
                global::SimHub.Logging.Current.Error($"Simulator Controller Plugin: Error saving settings: {ex.Message}");
            }
        }

        internal PluginSettings Settings => _settings;

        /// <summary>
        /// Update SimHub properties during DataUpdate tick using AddProperty API
        /// This dynamically exposes ALL properties from any JSON structure
        /// </summary>
        private void UpdateSimHubPropertiesOnDataUpdate(PluginManager pluginManager, ref GameData data)
        {
            if (_currentState == null)
                return;

            try
            {
                // Recursively expose all properties from the JObject
                ExposeJObjectProperties(pluginManager, string.Empty, _currentState, 0);
            }
            catch (Exception ex)
            {
                if (_settings?.EnableDebugLogging == true)
                    global::SimHub.Logging.Current.Error($"Simulator Controller Plugin: Error updating properties: {ex.Message}");
            }
        }

        /// <summary>
        /// Recursively expose JObject/JArray properties to SimHub (works with ANY JSON structure)
        /// </summary>
        private void ExposeJObjectProperties(PluginManager pluginManager, string parentPath, JToken token, int depth)
        {
            // Prevent infinite recursion
            if (depth > MaxPropertyDepth)
                return;

            try
            {
                switch (token.Type)
                {
                    case JTokenType.Object:
                        var obj = (JObject)token;
                        foreach (var property in obj.Properties())
                        {
                            string fullPath = string.IsNullOrEmpty(parentPath) 
                                ? property.Name 
                                : $"{parentPath}.{property.Name}";
                            
                            ExposeJObjectProperties(pluginManager, fullPath, property.Value, depth + 1);
                        }
                        break;

                    case JTokenType.Array:
                        var array = (JArray)token;
                        
                        // Detect if this is a 4-element array with only primitive values (wheel array)
                        // Non-primitive arrays (objects) should always use numeric indices
                        bool isWheelArray = array.Count == 4 && 
                                          array.All(t => t.Type != JTokenType.Object && t.Type != JTokenType.Array);
                        
                        for (int i = 0; i < array.Count; i++)
                        {
                            string indexer = isWheelArray ? WheelPositions[i] : (i + 1).ToString();
                            string fullPath = $"{parentPath}.{indexer}";
                            
                            var element = array[i];
                            if (element.Type == JTokenType.Object || element.Type == JTokenType.Array)
                            {
                                // Recursively expose nested objects/arrays
                                ExposeJObjectProperties(pluginManager, fullPath, element, depth + 1);
                            }
                            else
                            {
                                // Expose primitive value
                                AddProperty(pluginManager, fullPath, element);
                            }
                        }
                        break;

                    case JTokenType.Integer:
                    case JTokenType.Float:
                    case JTokenType.String:
                    case JTokenType.Boolean:
                    case JTokenType.Date:
                    case JTokenType.TimeSpan:
                        // Expose primitive value
                        AddProperty(pluginManager, parentPath, token);
                        break;

                    case JTokenType.Null:
                    case JTokenType.Undefined:
                        // Expose missing/null values as space
                        AddProperty(pluginManager, parentPath, " ");
                        break;
                }
            }
            catch (Exception ex)
            {
                if (_settings?.EnableDebugLogging == true)
                    global::SimHub.Logging.Current.Error($"Simulator Controller Plugin: Error exposing property {parentPath}: {ex.Message}");
            }
        }

        /// <summary>
        /// Safely add a property to SimHub
        /// </summary>
        private void AddProperty(PluginManager pluginManager, string name, object value)
        {
            try
            {
                // Convert JToken to actual value if needed
                object actualValue;
                if (value is JToken token)
                {
                    actualValue = token.Type switch
                    {
                        JTokenType.Integer => token.Value<long>(),
                        JTokenType.Float => token.Value<double>(),
                        JTokenType.String => token.Value<string>() ?? " ",
                        JTokenType.Boolean => token.Value<bool>(),
                        JTokenType.Date => token.Value<DateTime>(),
                        JTokenType.TimeSpan => token.Value<TimeSpan>(),
                        JTokenType.Null => " ",
                        JTokenType.Undefined => " ",
                        _ => token.ToString()
                    };
                }
                else
                {
                    actualValue = value ?? " ";
                }

                pluginManager.AddProperty(name, this.GetType(), actualValue);
            }
            catch (Exception ex)
            {
                if (_settings?.EnableDebugLogging == true)
                    global::SimHub.Logging.Current.Error($"Simulator Controller Plugin: Failed to add property {name}: {ex.Message}");
            }
        }

        #endregion
    }
}
