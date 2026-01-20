using System;
using System.IO;
using System.Windows;
using System.Windows.Controls;
using Microsoft.Win32;

namespace SimulatorController.SimHub.Plugin
{
    /// <summary>
    /// Settings UI control for the Simulator Controller plugin
    /// </summary>
    public partial class SettingsControl : UserControl
    {
        private readonly SimulatorControllerPlugin _plugin;

        public SettingsControl(SimulatorControllerPlugin plugin)
        {
            _plugin = plugin;
            InitializeComponent();
            DataContext = _plugin.Settings;
        }

        private void InitializeComponent()
        {
            // Root grid
            Grid rootGrid = new Grid
            {
                Margin = new Thickness(10)
            };

            // Define rows
            rootGrid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
            rootGrid.RowDefinitions.Add(new RowDefinition { Height = new GridLength(10) });
            rootGrid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
            rootGrid.RowDefinitions.Add(new RowDefinition { Height = new GridLength(10) });
            rootGrid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
            rootGrid.RowDefinitions.Add(new RowDefinition { Height = new GridLength(10) });
            rootGrid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
            rootGrid.RowDefinitions.Add(new RowDefinition { Height = new GridLength(20) });
            rootGrid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
            rootGrid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });

            // Header
            TextBlock header = new TextBlock
            {
                Text = "Simulator Controller Integration Settings",
                FontSize = 16,
                FontWeight = FontWeights.Bold,
                Margin = new Thickness(0, 0, 0, 10)
            };
            Grid.SetRow(header, 0);
            rootGrid.Children.Add(header);

            // JSON File Path section
            StackPanel filePathSection = new StackPanel();
            Grid.SetRow(filePathSection, 2);

            TextBlock filePathLabel = new TextBlock
            {
                Text = "Session State JSON File Path:",
                FontWeight = FontWeights.SemiBold,
                Margin = new Thickness(0, 0, 0, 5)
            };
            filePathSection.Children.Add(filePathLabel);

            Grid filePathGrid = new Grid();
            filePathGrid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
            filePathGrid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(10) });
            filePathGrid.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });

            TextBox filePathTextBox = new TextBox
            {
                Name = "FilePathTextBox",
                Height = 25,
                VerticalContentAlignment = VerticalAlignment.Center
            };
            filePathTextBox.SetBinding(TextBox.TextProperty, new System.Windows.Data.Binding("JsonFilePath")
            {
                Mode = System.Windows.Data.BindingMode.TwoWay,
                UpdateSourceTrigger = System.Windows.Data.UpdateSourceTrigger.PropertyChanged
            });
            Grid.SetColumn(filePathTextBox, 0);
            filePathGrid.Children.Add(filePathTextBox);

            Button browseButton = new Button
            {
                Content = "Browse...",
                Width = 80,
                Height = 25
            };
            browseButton.Click += BrowseButton_Click;
            Grid.SetColumn(browseButton, 2);
            filePathGrid.Children.Add(browseButton);

            filePathSection.Children.Add(filePathGrid);

            TextBlock filePathHint = new TextBlock
            {
                Text = "Default: Documents\\Simulator Controller\\Temp\\Session State.json",
                FontSize = 10,
                FontStyle = FontStyles.Italic,
                Foreground = System.Windows.Media.Brushes.Gray,
                Margin = new Thickness(0, 5, 0, 0)
            };
            filePathSection.Children.Add(filePathHint);

            rootGrid.Children.Add(filePathSection);

            // Polling Interval section
            StackPanel pollingSection = new StackPanel();
            Grid.SetRow(pollingSection, 4);

            TextBlock pollingLabel = new TextBlock
            {
                Text = "Polling Interval (milliseconds):",
                FontWeight = FontWeights.SemiBold,
                Margin = new Thickness(0, 0, 0, 5)
            };
            pollingSection.Children.Add(pollingLabel);

            TextBox pollingTextBox = new TextBox
            {
                Name = "PollingTextBox",
                Width = 100,
                Height = 25,
                HorizontalAlignment = HorizontalAlignment.Left,
                VerticalContentAlignment = VerticalAlignment.Center
            };
            pollingTextBox.SetBinding(TextBox.TextProperty, new System.Windows.Data.Binding("PollingInterval")
            {
                Mode = System.Windows.Data.BindingMode.TwoWay,
                UpdateSourceTrigger = System.Windows.Data.UpdateSourceTrigger.PropertyChanged
            });
            pollingSection.Children.Add(pollingTextBox);

            TextBlock pollingHint = new TextBlock
            {
                Text = "How often to check for file changes (default: 1000ms). Lower values increase CPU usage.",
                FontSize = 10,
                FontStyle = FontStyles.Italic,
                Foreground = System.Windows.Media.Brushes.Gray,
                Margin = new Thickness(0, 5, 0, 0),
                TextWrapping = TextWrapping.Wrap
            };
            pollingSection.Children.Add(pollingHint);

            rootGrid.Children.Add(pollingSection);

            // Debug Logging section
            StackPanel debugSection = new StackPanel();
            Grid.SetRow(debugSection, 6);

            CheckBox debugCheckBox = new CheckBox
            {
                Content = "Enable Debug Logging",
                FontWeight = FontWeights.SemiBold
            };
            debugCheckBox.SetBinding(CheckBox.IsCheckedProperty, new System.Windows.Data.Binding("EnableDebugLogging")
            {
                Mode = System.Windows.Data.BindingMode.TwoWay
            });
            debugSection.Children.Add(debugCheckBox);

            TextBlock debugHint = new TextBlock
            {
                Text = "Logs detailed information about file reads and property updates to SimHub logs.",
                FontSize = 10,
                FontStyle = FontStyles.Italic,
                Foreground = System.Windows.Media.Brushes.Gray,
                Margin = new Thickness(20, 5, 0, 0),
                TextWrapping = TextWrapping.Wrap
            };
            debugSection.Children.Add(debugHint);

            rootGrid.Children.Add(debugSection);

            // Status section
            Border statusBorder = new Border
            {
                Background = System.Windows.Media.Brushes.LightYellow,
                BorderBrush = System.Windows.Media.Brushes.Orange,
                BorderThickness = new Thickness(1),
                Padding = new Thickness(10),
                CornerRadius = new CornerRadius(5)
            };
            Grid.SetRow(statusBorder, 8);

            StackPanel statusPanel = new StackPanel();

            TextBlock statusTitle = new TextBlock
            {
                Text = "ℹ Property Prefix: SC",
                FontWeight = FontWeights.Bold,
                Margin = new Thickness(0, 0, 0, 5)
            };
            statusPanel.Children.Add(statusTitle);

            TextBlock statusText = new TextBlock
            {
                Text = "All Simulator Controller data is exposed with the 'SC.' prefix.\n" +
                       "Example properties: SC.Fuel.RemainingFuel, SC.Tyres.Temperature.FrontLeft, SC.Session.Car\n\n" +
                       "Settings are saved automatically when this panel is closed.",
                TextWrapping = TextWrapping.Wrap,
                FontSize = 11
            };
            statusPanel.Children.Add(statusText);

            statusBorder.Child = statusPanel;
            rootGrid.Children.Add(statusBorder);

            // Test connection button
            Button testButton = new Button
            {
                Content = "Test File Connection",
                Width = 150,
                Height = 30,
                HorizontalAlignment = HorizontalAlignment.Left,
                Margin = new Thickness(0, 10, 0, 0)
            };
            testButton.Click += TestButton_Click;
            Grid.SetRow(testButton, 9);
            rootGrid.Children.Add(testButton);

            // Set root content
            Content = rootGrid;
        }

        private void BrowseButton_Click(object sender, RoutedEventArgs e)
        {
            OpenFileDialog dialog = new OpenFileDialog
            {
                Filter = "JSON Files (*.json)|*.json|All Files (*.*)|*.*",
                Title = "Select Session State JSON File"
            };

            // Set initial directory to default location
            string documentsPath = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);
            string defaultPath = Path.Combine(documentsPath, "Simulator Controller", "Temp");
            if (Directory.Exists(defaultPath))
            {
                dialog.InitialDirectory = defaultPath;
            }

            if (dialog.ShowDialog() == true)
            {
                _plugin.Settings.JsonFilePath = dialog.FileName;
            }
        }

        private void TestButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                string filePath = _plugin.Settings.JsonFilePath;

                if (string.IsNullOrWhiteSpace(filePath))
                {
                    MessageBox.Show("Please specify a JSON file path first.", 
                        "No File Path", MessageBoxButton.OK, MessageBoxImage.Warning);
                    return;
                }

                if (!File.Exists(filePath))
                {
                    MessageBox.Show($"File not found:\n{filePath}\n\nMake sure Simulator Controller is running and the Integration plugin is active.", 
                        "File Not Found", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }

                FileInfo fileInfo = new FileInfo(filePath);
                DateTime lastModified = fileInfo.LastWriteTime;
                long fileSize = fileInfo.Length;

                string message = $"✓ Connection successful!\n\n" +
                               $"File: {Path.GetFileName(filePath)}\n" +
                               $"Location: {Path.GetDirectoryName(filePath)}\n" +
                               $"Size: {fileSize:N0} bytes\n" +
                               $"Last Modified: {lastModified:yyyy-MM-dd HH:mm:ss}\n\n" +
                               $"The plugin will automatically read updates from this file.";

                MessageBox.Show(message, "Test Successful", MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error testing file connection:\n\n{ex.Message}", 
                    "Test Failed", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
    }
}
