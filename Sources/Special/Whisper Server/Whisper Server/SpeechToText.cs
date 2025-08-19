using System.Diagnostics;
using System.Text.Json;

namespace WhisperServer
{
    public class Whisper
    {
        public string WhisperPath { get; private set; }
        public string Language { get; private set; }
        public string Model { get; private set; }

        public Whisper(string whisperPath, string language, string model)
        {
            WhisperPath = whisperPath;
            Language = language;
            Model = model;
        }

        public string Recognize(string audioFilePath, string computeType)
        {
            string name = Path.GetFileNameWithoutExtension(audioFilePath);
            string outputFilePath = Path.Combine(WhisperPath, name + ".json");

            Process process = new Process();

            process.StartInfo.FileName = Path.Combine(WhisperPath, "faster-whisper-xxl.exe");
            process.StartInfo.Arguments = "\"" + audioFilePath + "\" -o \"" + WhisperPath +
                                          "\" --language " + Language.ToLower() +
                                          " -f json -m " + Model.ToLower() + " --beep_off" +
                                          ((computeType != "-") ? (" --compute_type " + computeType) : "");
            process.StartInfo.UseShellExecute = false;
            process.StartInfo.RedirectStandardOutput = false;
            process.StartInfo.RedirectStandardError = false;

            try
            {
                process.Start();
                process.WaitForExit();

                if (File.Exists(outputFilePath))
                {
                    var result = JsonDocument.Parse(File.ReadAllText(outputFilePath));

                    if (result.RootElement.TryGetProperty("text", out JsonElement textElement))
                        return textElement.GetString() ?? "";
                    else
                        return "Error: Invalid response from Whisper.";
                }
                else
                    return "Error: Recognition failed.";
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
            finally
            {
                if (process != null)
                    process.Dispose();

                if (File.Exists(outputFilePath))
                   File.Delete(outputFilePath);
            }
        }
    }
}