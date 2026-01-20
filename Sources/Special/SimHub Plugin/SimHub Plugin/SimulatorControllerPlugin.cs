using System;
using System.Collections.Generic;
using System.IO;
using System.Threading;
using System.Windows.Controls;
using System.Windows.Media;
using GameReaderCommon;
using SimHub.Plugins;
using Newtonsoft.Json;

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
        private const int MaxArrayElements = 4;
        private const int MaxPropertyDepth = 3;
        private static readonly string[] WheelPositions = { "FrontLeft", "FrontRight", "RearLeft", "RearRight" };
        
        private PluginSettings _settings = null!;
        private FileSystemWatcher? _fileWatcher;
        private Timer? _pollingTimer;
        private DateTime _lastFileWriteTime;
        private SessionState _currentState = new SessionState();
        private readonly object _stateLock = new object();
        private bool _isInitialized = false;
        private readonly object _initLock = new object();
        private Timer? _initTimer;
        
        // Cache reflection results for performance (avoid repeated reflection at 60Hz)
        private static readonly Dictionary<Type, System.Reflection.PropertyInfo[]> _propertyCache = new Dictionary<Type, System.Reflection.PropertyInfo[]>();
        private static readonly object _cacheLock = new object();
        
        public PluginManager PluginManager { get; set; }
        
        // Required by SimHub for plugin identification
        public string PluginId => "SimulatorController.SimHub.Plugin";
        
        // No icon needed
        public ImageSource PictureIcon => null!;
        
        public string LeftMenuTitle => "Simulator Controller";

        /// <summary>
        /// Called when SimHub initializes the plugin
        /// CRITICAL: Does NOTHING to prevent any blocking. Initialization happens on a timer.
        /// </summary>
        public void Init(PluginManager pluginManager)
        {
            // Store plugin manager only - do absolutely nothing else
            this.PluginManager = pluginManager;
            global::SimHub.Logging.Current.Info("Simulator Controller Plugin: Init called (deferred initialization)");
            
            // Start initialization after 500ms delay (ensures SimHub is fully loaded)
            _initTimer = new Timer(InitializePlugin, null, 500, Timeout.Infinite);
        }
        
        /// <summary>
        /// Performs actual initialization on background thread
        /// </summary>
        private void InitializePlugin(object? state)
        {
            lock (_initLock)
            {
                if (_isInitialized)
                    return;
                    
                try
                {
                    // Load settings
                    _settings = this.ReadCommonSettings("GeneralSettings", () => new PluginSettings());
                    
                    // Initialize default file path if not set
                    if (string.IsNullOrWhiteSpace(_settings.JsonFilePath))
                    {
                        string documentsPath = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);
                        _settings.JsonFilePath = Path.Combine(documentsPath, "Simulator Controller", "Temp", "Session State.json");
                        this.SaveCommonSettings("GeneralSettings", _settings);
                    }
                    
                    // Start monitoring
                    StartMonitoring();
                    
                    _isInitialized = true;
                    global::SimHub.Logging.Current.Info($"Simulator Controller Plugin: Initialized and monitoring: {_settings.JsonFilePath}");
                }
                catch (Exception ex)
                {
                    global::SimHub.Logging.Current.Error($"Simulator Controller Plugin: Initialization failed: {ex.Message}");
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
            global::SimHub.Logging.Current.Info("Simulator Controller Plugin: Shutting down...");
            StopMonitoring();
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
                
                // Parse JSON with null handling
                SessionState? newState = JsonConvert.DeserializeObject<SessionState>(jsonContent, new JsonSerializerSettings
                {
                    NullValueHandling = NullValueHandling.Include,
                    MissingMemberHandling = MissingMemberHandling.Ignore,
                    Error = (sender, args) =>
                    {
                        args.ErrorContext.Handled = true; // Ignore parsing errors silently
                    }
                });
                
                // Update state (properties are exposed in DataUpdate)
                lock (_stateLock)
                {
                    _currentState = newState ?? new SessionState();
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



        /// <summary>
        /// Safely get value from array with null handling
        /// </summary>
        private T GetArrayValue<T>(T[]? array, int index, T defaultValue)
        {
            return array != null && (uint)index < (uint)array.Length && array[index] != null
                ? array[index]
                : defaultValue;
        }

        #region Settings UI

        public Control GetWPFSettingsControl(PluginManager pluginManager)
        {
            try
            {
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
            // Called when settings UI is shown
        }

        public void OnSettingsClosed()
        {
            try
            {
                // Save settings and restart monitoring
                this.SaveCommonSettings("GeneralSettings", _settings);
                StartMonitoring();
            }
            catch (Exception ex)
            {
                global::SimHub.Logging.Current.Error($"Simulator Controller Plugin: Error saving settings: {ex.Message}");
            }
        }

        internal PluginSettings Settings => _settings;

        /// <summary>
        /// Update SimHub properties during DataUpdate tick using AddProperty API
        /// This dynamically exposes ALL properties from the current state
        /// </summary>
        private void UpdateSimHubPropertiesOnDataUpdate(PluginManager pluginManager, ref GameData data)
        {
            if (_currentState == null)
                return;

            void AddProp(string name, object? value)
            {
                try
                {
                    pluginManager.AddProperty($"{name}", this.GetType(), value ?? string.Empty);
                }
                catch (Exception ex)
                {
                    if (_settings?.EnableDebugLogging == true)
                        global::SimHub.Logging.Current.Error($"Simulator Controller Plugin: Failed to add property {name}: {ex.Message}");
                }
            }

            var stateType = _currentState.GetType();
            foreach (var prop in stateType.GetProperties())
            {
                try
                {
                    var value = prop.GetValue(_currentState);
                    if (value == null)
                        continue;

                    var propType = value.GetType();
                    
                    if (propType.IsPrimitive || propType == typeof(string) || propType == typeof(decimal) || propType == typeof(double) || propType == typeof(float))
                    {
                        AddProp(prop.Name, value);
                    }
                    else
                    {
                        ExposeNestedProperties(pluginManager, prop.Name, value, AddProp, 1);
                    }
                }
                catch (Exception ex)
                {
                    if (_settings?.EnableDebugLogging == true)
                        global::SimHub.Logging.Current.Error($"Simulator Controller Plugin: Failed to expose property {prop.Name}: {ex.Message}");
                }
            }
        }

        /// <summary>
        /// Recursively expose nested object properties (with reflection caching and depth limiting)
        /// </summary>
        private void ExposeNestedProperties(PluginManager pluginManager, string parentPath, object obj, Action<string, object?> addProp, int depth)
        {
            if (obj == null || depth > MaxPropertyDepth)
                return;

            var objType = obj.GetType();
            
            if (objType.IsArray)
            {
                var array = (Array)obj;
                int arrayLength = Math.Min(array.Length, MaxArrayElements);
                for (int i = 0; i < arrayLength; i++)
                {
                    var element = array.GetValue(i);
                    addProp($"{parentPath}.{WheelPositions[i]}", element);
                }
                return;
            }

            System.Reflection.PropertyInfo[] properties;
            lock (_cacheLock)
            {
                if (!_propertyCache.TryGetValue(objType, out properties))
                {
                    properties = objType.GetProperties();
                    _propertyCache[objType] = properties;
                }
            }

            foreach (var prop in properties)
            {
                try
                {
                    var value = prop.GetValue(obj);
                    if (value == null)
                        continue;

                    var propType = value.GetType();
                    string fullPath = $"{parentPath}.{prop.Name}";

                    if (propType.IsPrimitive || propType == typeof(string) || propType == typeof(decimal) || propType == typeof(double) || propType == typeof(float) || propType == typeof(bool))
                    {
                        addProp(fullPath, value);
                    }
                    else if (propType.IsArray)
                    {
                        var array = (Array)value;
                        int arrayLength = Math.Min(array.Length, MaxArrayElements);
                        for (int i = 0; i < arrayLength; i++)
                        {
                            var element = array.GetValue(i);
                            addProp($"{fullPath}.{WheelPositions[i]}", element);
                        }
                    }
                    else
                    {
                        ExposeNestedProperties(pluginManager, fullPath, value, addProp, depth + 1);
                    }
                }
                catch (Exception ex)
                {
                    if (_settings?.EnableDebugLogging == true)
                        global::SimHub.Logging.Current.Error($"Simulator Controller Plugin: Failed to expose nested property {prop.Name}: {ex.Message}");
                }
            }
        }

        #endregion
    }
}
