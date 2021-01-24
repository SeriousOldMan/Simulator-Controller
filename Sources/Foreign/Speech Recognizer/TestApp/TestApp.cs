using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Speech.Recognition;

namespace TestApp
{
    class TestApp
    {
        static void Main(string[] args)
        {
            var hvTester = new HvTester();
        }
    }

    public class HvTester
    {
        private readonly HotVoice.HotVoice _hv = new HotVoice.HotVoice();

        public HvTester()
        {
            int id;

            // ======================= English ========================
            id = GetLanguageId("en");
            _hv.Initialize(id);
            Console.WriteLine("Initialized English tester");

            // ----------------------- Volume Demo --------------------
            var volumeGrammar = _hv.NewGrammar();
            volumeGrammar.AppendString("Volume");

            var percentPhrase = _hv.NewGrammar();
            var percentChoices = _hv.GetChoices("Percent");
            percentPhrase.AppendChoices(percentChoices);
            percentPhrase.AppendString("percent");

            var fractionPhrase = _hv.NewGrammar();
            var fractionChoices = _hv.NewChoices("quarter, half, three-quarters, full");
            fractionPhrase.AppendChoices(fractionChoices);

            volumeGrammar.AppendGrammars(percentPhrase, fractionPhrase);

            _hv.LoadGrammar(volumeGrammar, "Volume", new Action<string, string[]>((name, values) =>
            {
                Console.WriteLine($"{name}: {string.Join(" ", values)}");
            }));

            // ---------------------- Call Contact Demo ----------------
            var contactGrammar = _hv.NewGrammar();
            contactGrammar.AppendString("Call");

            var femaleChoices = _hv.NewChoices("Anne, Mary");
            var femalePhrase = _hv.NewGrammar();
            femalePhrase.AppendChoices(femaleChoices);
            femalePhrase.AppendString("on her");

            var maleChoices = _hv.NewChoices("James, Sam");
            var malePhrase = _hv.NewGrammar();
            malePhrase.AppendChoices(maleChoices);
            malePhrase.AppendString("on his");

            contactGrammar.AppendGrammars(malePhrase, femalePhrase);

            var phoneChoices = _hv.NewChoices("cell, home, work");
            contactGrammar.AppendChoices(phoneChoices);

            contactGrammar.AppendString("phone");

            _hv.LoadGrammar(contactGrammar, "CallContact", new Action<string, string[]>((name, values) =>
            {
                Console.WriteLine($"{name}: {string.Join(" ", values)}");
            }));

            //hv.SubscribeVolume(new Action<int>((value) => {
            //    Console.WriteLine("Volume: " + value);
            //}));

            _hv.StartRecognizer();

            Console.WriteLine("Press ENTER to load French");
            Console.ReadLine();

            // ======================= French ========================
            id = GetLanguageId("fr");
            _hv.Initialize(id);
            Console.WriteLine("Initialized French tester");

            var frenchGrammar = _hv.NewGrammar();
            frenchGrammar.AppendString("Bonjour");

            _hv.LoadGrammar(frenchGrammar, "Bonjour", new Action<string, string[]>((name, values) =>
            {
                Console.WriteLine($"{name}: {string.Join(" ", values)}");
            }));
            _hv.StartRecognizer();

            Console.WriteLine("Press ENTER to Exit");
            Console.ReadLine();
        }

        private int GetLanguageId(string language)
        {
            var infos = _hv.GetRecognizerInfos();
            for (var i = 0; i < infos.Count; i++)
            {
                if (infos[i].Culture.TwoLetterISOLanguageName == language)
                {
                    return i;
                }
            }
            throw new Exception($"Could not find language {language}");
        }
    }
}
