using Microsoft.AspNetCore.Hosting.Server;
using Microsoft.AspNetCore.Mvc;
using System.Text.Json;

namespace WhisperServer.Controllers
{
    public class Settings
    {
        public required string WhisperPath { get; set; }
    }

    [ApiController]
    [Route("[controller]")]
    public class SpeechToTextController : ControllerBase
    {
        static readonly string WhisperPath;

        static SpeechToTextController()
        {
            // Ensure null safety by validating the deserialization result  
            var settingsJson = System.IO.File.ReadAllText(Path.Combine(Environment.CurrentDirectory, "Settings.json"));
            var settings = JsonSerializer.Deserialize<Settings>(settingsJson);

            if (settings == null || string.IsNullOrEmpty(settings.WhisperPath))
            {
                throw new InvalidOperationException("Settings.json is invalid or WhisperPath is not set.");
            }

            WhisperPath = settings.WhisperPath;
        }

        private readonly ILogger<SpeechToTextController> _logger;

        public SpeechToTextController(ILogger<SpeechToTextController> logger)
        {
            _logger = logger;
        }

        [HttpPost("recognize")]
        public string Post([FromQuery(Name = "language")] string language, [FromQuery(Name = "model")] string model, [FromBody] string audio)
        {
            string audioFilePath = "speech.wav";

            try
            {
                byte[] audioBytes = Convert.FromBase64String(audio);

                // Correct the method call to use System.IO.File instead of ControllerBase.File
                System.IO.File.WriteAllBytes(audioFilePath, audioBytes);

                return new Whisper(WhisperPath, language, model).Recognize(audioFilePath);
            }
            catch (AggregateException exception)
            {
                return "Error: " + (exception.InnerException?.Message ?? "Unknown error occurred.");
            }
            catch (Exception exception)
            {
                return "Error: " + exception.Message;
            }
            finally
            {
                // Clean up the audio file if necessary
                if (System.IO.File.Exists(audioFilePath))
                    System.IO.File.Delete(audioFilePath);
            }
        }
    }
}
