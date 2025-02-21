/*
Copyright (c) 2023, iRacing.com Motorsport Simulations, LLC.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of iRacing.com Motorsport Simulations nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

//using NCalc.Domain;
using System;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Text.Json.Nodes;
using System.Collections.Generic;
using System.Text.RegularExpressions;
//using System.Windows.Forms;

namespace iRacing.IRSDK
{
	public class YAMLObj
	{
		public YAMLObj() { }

		// convenience accessors, take in a path to a node in the tree
		// converting the data and returning a default value if not found

		//****Note, this differes from the C++ code, the brackets are before the colen
		//path is in the form of "DriverInfo:Drivers:CarIdx{%d}:UserName:"

		public string getPathAsString(string path)
		{
			try
			{
				string s = (string)getNode(path);
				if (!string.IsNullOrEmpty(s))
					return s;
			}
			catch(Exception e) 
			{ 
				Debug.Write("getPathAsString: " + e.ToString());
			}

			return "";
		}

		//****FixMe, I doubt this handles +2.5, -1.2 or 1.54E-34
		//****FixMe, find a way to save the units and pass them back as well
		public float getPathAsFloat(string path, float defVal = 0)
		{
			try
			{
				string s = (string)getNode(path);
				if (!string.IsNullOrEmpty(s))
				{
					//****Note, you would think float.Parse(str) would parse up to the
					// first non numeric character, but instead it throws a fit if it
					// there are any non numberic characters in the string (trailing units)
					// So we use this convoluted regex
					//****FixMe, the unit is lost with this regex, there is probably
					// a better way to go about this so the unit is preserved
					var numArray = Regex.Split(s, @"[^\d.,]+");
					return float.Parse(numArray[0]);
				}
			}
			catch(Exception e) 
			{ 
				Debug.Write("getPathAsFloat: " + e.ToString());
			}

			return defVal;
		}

		//****FixMe, I doubt this handles +2 or -1
		//****FixMe, find a way to save the units and pass them back as well
		public int getPathAsInt(string path, int defVal = 0)
		{
			try
			{
				string s = (string)getNode(path);
				if (!string.IsNullOrEmpty(s))
				{
					//****Note, you would think int.Parse(str) would parse up to the
					// first non numeric character, but instead it throws a fit if it
					// there are any non numberic characters in the string (trailing units)
					// So we use this convoluted regex
					//****FixMe, the unit is lost with this regex, there is probably
					// a better way to go about this so the unit is preserved
					var numArray = Regex.Split(s, @"[^\d]+");
					int i = int.Parse(numArray[0]);
					return i;
				}
			}
			catch(Exception e) 
			{ 
				Debug.Write("getPathAsInt: " + e.ToString());
			}

			return defVal;
		}

		public void parseYaml(string yamlStr) { parseYamlHelper(yamlStr); }

		//---

		public void parseYamlHelper(string yamlStr)
		{
			//Debug.WriteLine("parseYamlHelper\n" + yamlStr);

			m_rootNode = new JsonObject();
			Stack<ObjElement> objStack = new Stack<ObjElement>();

			// insert our first entry into the stack
			objStack.Push(new ObjElement(m_rootNode, 0, "", -1));

			int keyIndent = 0;
			int arrayIndent = -1;
			int keyStart = 0;
			int keyEnd = 0;
			int valStart = 0;
			int valEnd = 0;

			PState state = PState.ParseIndent;

			for (int i = 0; i < yamlStr.Length; i++)
			{
				char c = yamlStr[i];

				if (c == '\n')
				{
					// we found a line, so stuff it into our object
					// keyEnd defaults to 0 and is only set if ':' char found
					if (keyStart < keyEnd)
					{
						string keyStr = yamlStr.Substring(keyStart, keyEnd - keyStart);

						// values can be quoted, go ahead and strip off the quotes
						string valStr = "";
						if (valStart < valEnd)
						{
							// strip out leading/trailing quotes
							if (yamlStr[valStart] == '"' || yamlStr[valStart] == '\'')
								valStart++;

							if (yamlStr[valEnd - 1] == '"' || yamlStr[valEnd - 1] == '\'')
								valEnd--;

							if (valStart < valEnd)
								valStr = yamlStr.Substring(valStart, valEnd - valStart);
						}

						addNodeToObj(objStack, keyIndent, arrayIndent, keyStr, valStr);
					}
					else
					{
						objStack.Clear();
						objStack.Push(new ObjElement(m_rootNode, 0, "", -1));

						//Debug.WriteLine("blank line");
						// empty line or '...' or '---' marker, reset stack
					}

					// reset counters for next line
					keyIndent = 0;
					arrayIndent = -1;
					keyStart = 0; keyEnd = 0;
					valStart = 0; valEnd = 0;

					state = PState.ParseIndent;
				}
				else // continue parsing a line
				{
					if (state == PState.ParseIndent)
					{
						if (c == ' ')
							keyIndent++;
						else if (c == '\t') // special case, tabs are not part of the spec
							keyIndent += 4;
						else if (c == '-')
						{
							arrayIndent = keyIndent;
							keyIndent++;
						}
						else // not white space
						{
							keyStart = i;
							state = PState.ParseKey;
						}
					}
					else if (state == PState.ParseKey)
					{
						if (c == ':')
						{
							keyEnd = i;
							valStart = i + 1;
							state = PState.ParseWhitespace;
						}
					}
					else if (state == PState.ParseWhitespace)
					{
						if (c == ' ')
							valStart = i + 1;
						else
						{
							valEnd = i + 1;
							state = PState.ParseValue;
						}
					}
					else if (state == PState.ParseValue)
					{
						if (c != ' ')
							valEnd = i + 1;
					}
					else
						Debug.WriteLine("error: unknown state variable");
				}
			}
		}

		protected static void addNodeToObj(Stack<ObjElement> objStack, int keyIndent, int arrayIndent, string keyStr, string valStr)
		{
			//Debug.WriteLine("addNodeToObject(" + keyIndent + "," + arrayIndent + "," + keyStr + "," + valStr + ")");

			ObjElement tObj = objStack.Peek();

			// adding a new array?
			if (arrayIndent >= 0)
			{
				// travers up the stack, if needed
				while (objStack.Count > 1 &&
						(arrayIndent < tObj.arrayIndent || arrayIndent < tObj.keyIndent))
				{
					objStack.Pop();
					tObj = objStack.Peek();
				}

				// add entry to end of exiting array
				if (arrayIndent == tObj.arrayIndent)
				{
					// create new child
					var elm = new JsonObject();
					elm.Add(keyStr, valStr);

					// append child to array
					tObj.pObj[tObj.lastKeyStr].AsArray().Add(elm);

					tObj = new ObjElement(elm, keyIndent, keyStr, -1);
					objStack.Push(tObj);
				}
				// create a new array with a new entry in it
				else if (arrayIndent == tObj.keyIndent && tObj.arrayIndent == -1)
				{
					// create new child
					var elm = new JsonObject();
					elm.Add(keyStr, valStr);

					// create array and add child
					var ar = new JsonArray();
					ar.Add(elm);
					tObj.pObj[tObj.lastKeyStr] = ar;
					tObj = objStack.Pop(); // tObj is just a refference, so we can't modify it
					tObj.arrayIndent = arrayIndent;
					objStack.Push(tObj);

					tObj = new ObjElement(elm, keyIndent, keyStr, -1);
					objStack.Push(tObj);
				}
				else
				{
					Debug.WriteLine("array nesting does not match up!");
				}
			}
			// else just add regular key: value pair
			else if (keyIndent > tObj.keyIndent)
			{
				if (!string.IsNullOrEmpty(tObj.lastKeyStr))
				{
					// create new child
					var elm = new JsonObject();
					elm.Add(keyStr, valStr);

					// and nest it
					tObj.pObj[tObj.lastKeyStr] = elm;

					//and update our refference stack
					tObj = new ObjElement(elm, keyIndent, keyStr, -1);
					objStack.Push(tObj);
				}
				else
				{
					Debug.WriteLine("failed to find last key string");
				}
			}
			else //if(keyIndent <= tObj.keyIndent)
			{
				// pop if needed then add
				while (keyIndent < tObj.keyIndent && objStack.Count > 1)
				{
					objStack.Pop();
					tObj = objStack.Peek();
				}

				if (keyIndent == tObj.keyIndent)
				{
					tObj.pObj[keyStr] = valStr;
					tObj = objStack.Pop(); // tObj is just a refference, so we can't modify it
					tObj.lastKeyStr = keyStr;
					tObj.arrayIndent = -1; // clear out previous arrays since we are starting a new sub section
					objStack.Push(tObj);
				}
				else
				{
					Debug.WriteLine("Something did not line up, bad format in yaml string");
				}
			}
		}

		protected JsonNode? getNode(string path)
		{
			try
			{
				string[] levels = path.Split(':');
				JsonNode node = m_rootNode;

				for(int i=0; i<levels.Length; i++)
				{
					string name = levels[i];

					// check if we are at an array index
					string[] ar = name.Split('{', '}');
					if (ar.Length > 1)
					{
						name = ar[0];
						int index = int.Parse(ar[1]);

						JsonArray array = node.AsArray();
						for (int j = 0; j < array.Count; j++)
						{
							if (int.Parse((string)array[j][name]) == index)
							{
								node = array[j];
								break;
							}
						}
					}
					else
					{
						// "value:".Split(':') returns a two element array with the last element empty
						// so ignore that case
						if (node != null && !string.IsNullOrEmpty(name))
							node = node[name];
					}
				}

				return node;
			}
			catch(Exception e) 
			{ 
				Debug.Write("getNode: " + e.ToString());
			}

			return null;
		}

		//---

		protected enum PState
		{
			ParseIndent,
			ParseKey,
			ParseWhitespace,
			ParseValue
		}
		protected struct ObjElement
		{
			public ObjElement(JsonObject pObj, int keyIndent, string lastKeyStr, int arrayIndent)
			{
				this.pObj = pObj;
				this.keyIndent = keyIndent;
				this.lastKeyStr = lastKeyStr;
				this.arrayIndent = arrayIndent;
			}

			public JsonObject pObj { get; set; }
			public int keyIndent { get; set; }
			public string lastKeyStr { get; set; }
			public int arrayIndent { get; set; }
		};

		//---

		internal JsonObject m_rootNode;
	}
}
