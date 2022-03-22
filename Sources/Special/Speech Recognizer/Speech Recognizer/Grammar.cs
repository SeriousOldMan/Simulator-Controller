using System.Linq;

namespace Speech
{
    public partial class ServerSpeechRecognizer
    {
        public ServerGrammar NewGrammar()
        {
            var hg = new ServerGrammar();

            hg.GrammarBuilder.Culture = _recognizer.RecognizerInfo.Culture;

            return hg;
        }

        /// <summary>
        /// Creates a Choices object from a string of comma-separated text
        /// </summary>
        /// <param name="choiceListStr"></param>
        /// <returns></returns>
        public Microsoft.Speech.Recognition.Choices NewChoices(string choiceListStr)
        {
            return new Microsoft.Speech.Recognition.Choices(StringToArray(choiceListStr));
        }

        // I don't know how to pass an array of strings from AHK to C#, so for now, just use comma-separated strings
        public static string[] StringToArray(string choiceString) => choiceString.Split(',').Select(p => p.Trim()).ToArray();
    }

    public class ServerGrammar
    {
        //public string Name { get; }
        public Microsoft.Speech.Recognition.GrammarBuilder GrammarBuilder { get; } = new Microsoft.Speech.Recognition.GrammarBuilder();

        /// <summary>
        /// Gets a textual representation of the Phrases used in the Grammar
        /// </summary>
        /// <returns>The textual representation of the Phrases used in the Grammar</returns>
        public string GetPhrases()
        {
            return GrammarBuilder.DebugShowPhrases;
        }

        /// <summary>
        /// Adds a word or words to the Grammar
        /// </summary>
        /// <param name="text"></param>
        public void AppendString(string text)
        {
            GrammarBuilder.Append(text);
        }

        /// <summary>
        /// Adds a set of alternate words to the Grammar
        /// </summary>
        /// <param name="choices"></param>
        public void AppendChoices(Microsoft.Speech.Recognition.Choices choices)
        {
            GrammarBuilder.Append(choices);
        }

        /// <summary>
        /// Adds one or more Grammars to this Grammar
        /// COM does not support Variable argument lists, so for now this method only support up to 10 parameters
        /// </summary>
        public void AppendGrammars(ServerGrammar g1, ServerGrammar g2 = null, ServerGrammar g3 = null, ServerGrammar g4 = null, ServerGrammar g5 = null,
            ServerGrammar g6 = null, ServerGrammar g7 = null, ServerGrammar g8 = null, ServerGrammar g9 = null, ServerGrammar g10 = null)
        {
            var grammars = new[] { g1, g2, g3, g4, g5, g6, g7, g8, g9, g10 };
            var max = -1;
            for (var i = 0; i < 10; i++)
            {
                if (grammars[i] == null)
                {
                    break;
                }
                max = i;
            }

            max++;

            var grammarBuilderArray = new Microsoft.Speech.Recognition.GrammarBuilder[max];

            for (var i = 0; i < max; i++)
            {
                grammarBuilderArray[i] = grammars[i].GrammarBuilder;
            }

            GrammarBuilder.Append(new Microsoft.Speech.Recognition.Choices(grammarBuilderArray));
        }
    }

    public partial class DesktopSpeechRecognizer
    {
        public DesktopGrammar NewGrammar()
        {
            var hg = new DesktopGrammar();

            hg.GrammarBuilder.Culture = _recognizer.RecognizerInfo.Culture;

            return hg;
        }

        /// <summary>
        /// Creates a Choices object from a string of comma-separated text
        /// </summary>
        /// <param name="choiceListStr"></param>
        /// <returns></returns>
        public System.Speech.Recognition.Choices NewChoices(string choiceListStr)
        {
            return new System.Speech.Recognition.Choices(StringToArray(choiceListStr));
        }

        // I don't know how to pass an array of strings from AHK to C#, so for now, just use comma-separated strings
        public static string[] StringToArray(string choiceString) => choiceString.Split(',').Select(p => p.Trim()).ToArray();
    }

    public class DesktopGrammar
    {
        //public string Name { get; }
        public System.Speech.Recognition.GrammarBuilder GrammarBuilder { get; } = new System.Speech.Recognition.GrammarBuilder();

        /// <summary>
        /// Gets a textual representation of the Phrases used in the Grammar
        /// </summary>
        /// <returns>The textual representation of the Phrases used in the Grammar</returns>
        public string GetPhrases()
        {
            return GrammarBuilder.DebugShowPhrases;
        }

        /// <summary>
        /// Adds a word or words to the Grammar
        /// </summary>
        /// <param name="text"></param>
        public void AppendString(string text)
        {
            GrammarBuilder.Append(text);
        }

        /// <summary>
        /// Adds a set of alternate words to the Grammar
        /// </summary>
        /// <param name="choices"></param>
        public void AppendChoices(System.Speech.Recognition.Choices choices)
        {
            GrammarBuilder.Append(choices);
        }

        /// <summary>
        /// Adds one or more Grammars to this Grammar
        /// COM does not support Variable argument lists, so for now this method only support up to 10 parameters
        /// </summary>
        public void AppendGrammars(DesktopGrammar g1, DesktopGrammar g2 = null, DesktopGrammar g3 = null, DesktopGrammar g4 = null, DesktopGrammar g5 = null,
            DesktopGrammar g6 = null, DesktopGrammar g7 = null, DesktopGrammar g8 = null, DesktopGrammar g9 = null, DesktopGrammar g10 = null)
        {
            var grammars = new[] { g1, g2, g3, g4, g5, g6, g7, g8, g9, g10 };
            var max = -1;
            for (var i = 0; i < 10; i++)
            {
                if (grammars[i] == null)
                {
                    break;
                }
                max = i;
            }

            max++;

            var grammarBuilderArray = new System.Speech.Recognition.GrammarBuilder[max];

            for (var i = 0; i < max; i++)
            {
                grammarBuilderArray[i] = grammars[i].GrammarBuilder;
            }

            GrammarBuilder.Append(new System.Speech.Recognition.Choices(grammarBuilderArray));
        }
    }
}
