using System.Linq;
using Microsoft.Speech.Recognition;

namespace Speech
{
    public partial class SpeechRecognizer
    {
        public Grammar NewGrammar()
        {
            var hg = new Grammar();
            hg.GrammarBuilder.Culture = _recognizer.RecognizerInfo.Culture;
            return hg;
        }

        /// <summary>
        /// Creates a Choices object from a string of comma-separated text
        /// </summary>
        /// <param name="choiceListStr"></param>
        /// <returns></returns>
        public Choices NewChoices(string choiceListStr)
        {
            return new Choices(StringToArray(choiceListStr));
        }

        // I don't know how to pass an array of strings from AHK to C#, so for now, just use comma-separated strings
        public static string[] StringToArray(string choiceString) => choiceString.Split(',').Select(p => p.Trim()).ToArray();
    }

    public class Grammar
    {
        //public string Name { get; }
        public GrammarBuilder GrammarBuilder { get; } = new GrammarBuilder();

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
        public void AppendChoices(Choices choices)
        {
            GrammarBuilder.Append(choices);
        }

        /// <summary>
        /// Adds one or more Grammars to this Grammar
        /// COM does not support Variable argument lists, so for now this method only support up to 10 parameters
        /// </summary>
        public void AppendGrammars(Grammar g1, Grammar g2 = null, Grammar g3 = null, Grammar g4 = null, Grammar g5 = null,
            Grammar g6 = null, Grammar g7 = null, Grammar g8 = null, Grammar g9 = null, Grammar g10 = null)
        {
            var grammars = new[]{g1, g2, g3, g4, g5, g6, g7, g8, g9, g10};
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

            var grammarBuilderArray = new GrammarBuilder[max];

            for (var i = 0; i < max; i++)
            {
                grammarBuilderArray[i] = grammars[i].GrammarBuilder;
            }

            GrammarBuilder.Append(new Choices(grammarBuilderArray));
        }
    }
}
