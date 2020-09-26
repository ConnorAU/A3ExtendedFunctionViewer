using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace A3ExtendedFunctionViewer
{
	internal class SyntaxHighlight
	{
		private static int taskID = -1;
		private static string func = "";

		private static readonly char[] VAL_LETTERS_LOWER = new char[] { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z' };
		private static readonly char[] VAL_LETTERS_UPPER = new char[] { 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z' };
		private static readonly char[] VAL_DIGITS = new char[] { '1', '2', '3', '4', '5', '6', '7', '8', '9', '0' };

		private static readonly char[] VAL_BRACKETS = new char[] { '[', ']', '{', '}', '(', ')' };
		private static readonly char[] VAL_QUOTES = new char[] { '\'', '"' };

		private static readonly char[] VAL_LETTERS = VAL_LETTERS_LOWER.Concat(VAL_LETTERS_UPPER).ToArray();
		private static readonly char[] VAL_CHARS = new char[] { '_' }.Concat(VAL_LETTERS).Concat(VAL_DIGITS).ToArray();
		private static readonly char[] VAL_DIGIT_CHARS = new char[] { '.' }.Concat(VAL_DIGITS).ToArray();

		private static readonly string[] VAL_PREPROCESSOR = new string[] { "include", "define", "undef", "ifdef", "ifndef", "else", "endif", "line" };
		private static readonly string[] VAL_KEYWORDS = new string[] { "case", "catch", "default", "do", "else", "exit", "exitwith", "for", "foreach", "from", "if", "private", "switch", "then", "throw", "to", "try", "waituntil", "while", "with" };
		private static readonly string[] VAL_LITTERALS = new string[] { "blufor", "civilian", "confignull", "controlnull", "displaynull", "diaryrecordnull", "east", "endl", "false", "grpnull", "independent", "linebreak", "locationnull", "nil", "objnull", "opfor", "pi", "resistance", "scriptnull", "sideambientlife", "sideempty", "sidelogic", "sideunknown", "tasknull", "teammembernull", "true", "west" };
		private static readonly string[] VAL_MAGIC_VARS = new string[] { "_this", "_x", "_foreachindex", "_exception", "_thisscript", "_thisfsm", "_thiseventhandler" };
		private static readonly string[] VAL_NULLS = new string[] { "nil", "controlnull", "displaynull", "diaryrecordnull", "grpnull", "locationnull", "netobjnull", "objnull", "scriptnull", "tasknull", "teammembernull", "confignull" };

		private static List<string> output = new List<string>();
		private static string segment = "";

		internal void Execute(int id, string function, string[] args)
		{
			taskID = id;
			func = function;

			//DllEntry.Log(args[0].Substring(0,Math.Min(args[0].Length,100)));
			//DllEntry.Log(args[1]);

			switch (function)
			{
				case "countlines":
					CountLines(args[0], Convert.ToBoolean(args[1]));
					break;

				case "highlight":
					Highlight(args[0], args[1]);
					break;
			}
		}



		private static void callback(string data)
		{
			//DllEntry.Log($"{$"{func}:{taskID} - {data}"}");
			DllEntry.callback("cau_extendedfunctionviewer", $"{func}:{taskID}", data);
		}

		private static void Highlight(string s, string c)
		{
			// I thought creating SyntaxHighlight as a new object thing would start with clean variables, but these
			// seem to carry over with every new task. I don't know why and I've been at this too long to care
			// so I force reset them here and pretend everything is okay.
			output = new List<string>();
			segment = "";

			string[] colorsArray = c.TrimStart('[').TrimEnd(']').Split(',').Select(cc => cc.Trim('"')).ToArray();
			string c_comment = colorsArray[0];
			string c_string = colorsArray[1];
			string c_number = colorsArray[2];
			string c_magicvar = colorsArray[3];
			string c_localvar = colorsArray[4];
			string c_function = colorsArray[5];
			string c_preprocessor = colorsArray[6];
			string c_keyword = colorsArray[7];
			string c_literal = colorsArray[8];
			string c_null = colorsArray[9];
			string c_command = colorsArray[10];
			string c_globalvar = colorsArray[11];


			List<char> textArray = s.ToCharArray().ToList();

			char[] spaceTab = new char[] { (char)32, (char)9 };

			int textLen = s.Length;
			for (int i = 0; i < textLen; i++)
			{
				char thisChar = textArray[i];
				char prevChar = (char)0;
				if (i > 0) prevChar = textArray[i - 1];
				char nextChar = (char)0;
				if (i < textLen - 1) nextChar = textArray[i + 1];

				if (thisChar == '/' && nextChar == '*')
				{
					PushSegment();
					segment = s.Substring(i);
					int index = 4 + segment.Substring(2).IndexOf("*/");
					segment = segment.Substring(0, index);
					PushSegment();
					i = i + index - 1;
				}
				else if (thisChar == '/' && nextChar == '/')
				{
					PushSegment();
					segment = s.Substring(i);
					int index = segment.IndexOf((char)10);
					if (index == -1) index = segment.Length;
					segment = segment.Substring(0, index);
					PushSegment();
					i = i + index - 1;
				}
				else if (VAL_QUOTES.Contains(thisChar))
				{
					PushSegment();
					segment = s.Substring(i);
					int index = 2 + segment.Substring(1).IndexOf(thisChar);
					segment = segment.Substring(0, index);
					PushSegment();
					i = i + index - 1;
				}
				else if (VAL_DIGIT_CHARS.Contains(thisChar))
				{
					PushSegment();
					char[] tmp_segment = textArray.GetRange(i, textLen - i).ToArray();
					int index = -1;
					for (int ii = 0; ii < tmp_segment.Length; ii++)
					{
						if (!VAL_DIGIT_CHARS.Contains(tmp_segment[ii]))
						{
							index = ii;
							break;
						}
					}
					if (index == -1) index = tmp_segment.Length;
					segment = s.Substring(i, index);
					PushSegment();
					i = i + index - 1;
				}
				else if (VAL_CHARS.Contains(thisChar))
				{
					PushSegment();
					char[] tmp_segment = textArray.GetRange(i, textLen - i).ToArray();
					int index = -1;
					for (int ii = 0; ii < tmp_segment.Length; ii++)
					{
						if (!VAL_CHARS.Contains(tmp_segment[ii]))
						{
							index = ii;
							break;
						}
					}
					if (index == -1) index = tmp_segment.Length;
					segment = s.Substring(i, index);
					PushSegment();
					i = i + index - 1;
				}
				else if (VAL_BRACKETS.Contains(thisChar) || new char[] { ',', '#', (char)10 }.Contains(thisChar))
				{
					PushSegment();
					segment = Convert.ToString(thisChar);
					PushSegment();
				}
				else
				{
					if (
						(spaceTab.Contains(thisChar) && (!spaceTab.Contains(prevChar))) ||
						(spaceTab.Contains(prevChar) && (!spaceTab.Contains(thisChar)))
					)
					{
						PushSegment();
					}
					segment += Convert.ToString(thisChar);
				}
			}

			PushSegment();

			for (int i = 0; i < output.Count(); i++)
			{
				segment = output[i];

				string color = "";
				if (segment.Length >= 2 && new string[] { "/*", "//" }.Contains(segment.Substring(0, 2))) color = c_comment;
				else if (segment.Length >= 1 && new string[] { "'", "\"" }.Contains(segment.Substring(0, 1))) color = c_string;
				else
				{
					bool condition = true;
					for (int ii = 0; ii < segment.Length; ii++)
					{
						if (!VAL_DIGIT_CHARS.Contains(Convert.ToChar(segment.Substring(ii, 1))))
						{
							condition = false;
							break;
						}
					}

					if (condition) color = c_number;
					else
					{
						if (VAL_MAGIC_VARS.Contains(segment.ToLower())) color = c_magicvar;
						else
						{
							condition = true;
							for (int ii = 0; ii < segment.Length; ii++)
							{
								if (ii == 0)
								{
									if (segment.Substring(0, 1) != "_")
									{
										condition = false;
										break;
									}
								}
								else
								{
									if (!VAL_CHARS.Contains(Convert.ToChar(segment.Substring(ii, 1))))
									{
										condition = false;
										break;
									}
								}
							}

							if (condition) color = c_localvar;
							else
							{
								condition = true;
								for (int ii = 0; ii < segment.Length; ii++)
								{
									if (!VAL_CHARS.Contains(Convert.ToChar(segment.Substring(ii, 1))))
									{
										condition = false;
										break;
									}
								}

								if (segment.Length >= 2 && condition && segment.Substring(1, segment.Length - 2).ToLower().Contains("_fnc_")) color = c_function;
								else
								{
									condition = i > 0 && output[i - 1] == "#";
									if (condition && VAL_PREPROCESSOR.Contains(segment.ToLower())) color = c_preprocessor;
									else if (VAL_KEYWORDS.Contains(segment.ToLower())) color = c_keyword;
									else if (VAL_LITTERALS.Contains(segment.ToLower())) color = c_literal;
									else if (VAL_NULLS.Contains(segment.ToLower())) color = c_null;
									else if (DllEntry.sqfCommands.Contains(segment.ToLower())) color = c_command;
									else
									{
										condition = true;
										for (int ii = 0; ii < segment.Length; ii++)
										{
											if (!VAL_CHARS.Contains(Convert.ToChar(segment.Substring(ii, 1))))
											{
												condition = false;
												break;
											}
										}

										if (segment.Length >= 1 && condition) color = c_globalvar;
									}
								}
							}
						}
					}
				}

				segment = ReplaceChars(segment);
				if (color == "") output[i] = segment;
				else output[i] = $"<t color='{color}'>{segment}</t>";
			}

			int[] data = string.Join("", output).ToCharArray().Select(cc => Convert.ToInt32(cc)).ToArray();
			//DllEntry.Log($"{$"[{string.Join(",", data)}]".Length}");
			callback($"[{string.Join(",", data)}]");
		}
		private static void PushSegment()
		{
			if (segment != "")
			{
				output.Add(segment);
				segment = "";
			}
		}

		private static void CountLines(string s, bool multipleLineMarkers)
		{
			s = ReplaceChars(s);
			List<string> lineNumbers = new List<string>();

			string[] lines = s.Split(new string[] { "<br/>" }, StringSplitOptions.None);

			if (multipleLineMarkers)
			{
				int l = 1;
				for (int i = 0; i < lines.Length; i++)
				{
					string line = lines[i];
					if (line.Contains("#line "))
					{
						string[] lineSplit = line.Split(new string[] { " " }, StringSplitOptions.None);
						int lineNumber = 0;
						for (int ii = 0; ii < lineSplit.Length; ii++)
						{
							if (lineSplit[ii].EndsWith("#line"))
							{
								try
								{
									lineNumber = int.Parse(lineSplit[ii + 1]);
								} catch {
									//DllEntry.Log($"CountLines:int.Parse:FAILED:{lineSplit[ii + 1]}");
								}
								break;
							}
						}
						if (lineNumber > 0)
						{
							l = Math.Max(lineNumber - 1, 0);
							lineNumbers.Add($"\"{(char)9472}\"");
						}
						else
							lineNumbers.Add($"{l}");
					}
					else
						lineNumbers.Add($"{l}");
					l++;
				}
			} else
			{
				for (int i = 1;i < lines.Length + 1;i++)
					lineNumbers.Add($"{i}");
			}

			int[] data = $"[{string.Join(",", lineNumbers)}]".ToCharArray().Select(c => Convert.ToInt32(c)).ToArray();
			callback($"[{string.Join(",", data)}]");
		}

		private static string ReplaceChars(string s)
		{
			s = s
				.Replace("&", "&amp;")
				.Replace("<", "&lt;")
				.Replace(">", "&gt;")
				.Replace(Convert.ToString((char)13), "")
				.Replace(Convert.ToString((char)10), $"{(char)9472}<br/>")
				.Replace(Convert.ToString((char)9), "&#32;&#32;&#32;&#32;")
				.Replace("    ", "&#32;&#32;&#32;&#32;");

			return s;
		}
	}
}
