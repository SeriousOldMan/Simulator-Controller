using System;
using System.Collections.Generic;
using System.Linq;

namespace Speech
{
    public class SorensenDiceCoefficient
    {
        private string Clear(string value)
        {
            var build = new System.Text.StringBuilder();

            foreach (var item in value)
                if (item != ' ')
                    build.Append(char.ToLower(item));

            return build.ToString();
        }

        public decimal CompareTwoStrings(string a, string b)
        {
            if (!AreStringsValid(a, b))
                return 0.0M;

            a = Clear(a);
            b = Clear(b);

            var firstBigrams = new Dictionary<string, int>();
            var secondBigrams = new Dictionary<string, int>();
            var intersectionSize = 0;

            for (var i = 0; i < a.Length - 1; i++)
            {
                var bigram = a.Substring(i, 2);

                var count = firstBigrams.ContainsKey(bigram) ? firstBigrams[bigram] + 1 : 1;
                
                firstBigrams[bigram] = count;
            }

            for (var j = 0; j < b.Length - 1; j++)
            {
                var bigram = b.Substring(j, 2);
                var count = firstBigrams.ContainsKey(bigram) ? firstBigrams[bigram] : 0;

                if (count > 0)
                {
                    firstBigrams[bigram] = count - 1;

                    intersectionSize += 1;
                }
            }

            return (decimal)Math.Round((2.0 * intersectionSize) / (a.Length + b.Length - 2), 2);
        }
        
        public bool AreStringsValid(params string[] p)
        {
            if (p.Length % 2 != 0)
                return false;

            foreach (var _ in p)
            {
                if (string.IsNullOrEmpty(_))
                    return false;
                
                if (_.Length < 2)
                    return false;
            }

            return true;
        }
        
        public string FindBestMatch(string baseStr, params string[] inputs)
        {
            decimal currentCoefficient = 0;
            string value = null;

            foreach (var i in inputs)
            {
                var c = CompareTwoStrings(baseStr, i);

                if (c > currentCoefficient)
                {
                    currentCoefficient = c;
                    value = i;
                }

            }

            return value;
        }
    }

    public class Matcher
    {
        private string[] _words;

        public Matcher(params string[] words)
        {
            _words = words;
        }
        
        public decimal GetCoefficient()
        {
            return new SorensenDiceCoefficient().CompareTwoStrings(_words[0], _words[1]);
        }

        public string GetBestMatch()
        {
            return new SorensenDiceCoefficient().FindBestMatch(_words[0], _words.Skip(1).ToArray());
        }
    }
}