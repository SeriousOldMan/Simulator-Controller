using System.Linq;
using Microsoft.Speech.Recognition;

namespace HotVoice
{
    public partial class HotVoice
    {
        public HotGrammar NewGrammar()
        {
            var hg =new HotGrammar();
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

    public class HotGrammar
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
        /// Adds one or more HotGrammars to this HotGrammar
        /// COM does not support Variable argument lists, so for now this method only support up to 10 parameters
        /// </summary>
        public void AppendGrammars(HotGrammar g1, HotGrammar g2 = null, HotGrammar g3 = null, HotGrammar g4 = null, HotGrammar g5 = null,
            HotGrammar g6 = null, HotGrammar g7 = null, HotGrammar g8 = null, HotGrammar g9 = null, HotGrammar g10 = null)
        {
            var hotGrammars = new[]{g1, g2, g3, g4, g5, g6, g7, g8, g9, g10};
            var max = -1;
            for (var i = 0; i < 10; i++)
            {
                if (hotGrammars[i] == null)
                {
                    break;
                }
                max = i;
            }

            max++;

            var grammarBuilderArray = new GrammarBuilder[max];

            for (var i = 0; i < max; i++)
            {
                grammarBuilderArray[i] = hotGrammars[i].GrammarBuilder;
            }

            GrammarBuilder.Append(new Choices(grammarBuilderArray));
        }
    }
}
