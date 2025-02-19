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

using NCalc.Domain;
using System;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Text.Json.Nodes;
using System.Collections.Generic;

namespace iRacing.IRSDK
{
	public class IRSDKDiskReader
	{
		public IRSDKDiskReader() { }
		public IRSDKDiskReader(string path)
		{
			openFile(path);
		}

		// opens a file and parses the headers
		public void openFile(string path)
		{
			//****FixMe, what is the C# way of handling IO errors?
			m_br = new BinaryReader(File.OpenRead(path));
			m_header.parseHeader(m_br);
			m_sessionInfoObj.parseYaml(m_header.sessionInfoStr);
		}

		public void closeFile()
		{
			m_br.Close();
			m_br.Dispose(); // is this needed?
		}

		// session
		public DateTime getSessionStartDate() { return m_header.sessionStartDate; }
		public double getSessionStartTime() { return m_header.sessionStartTime; } // seconds
		public double getSessionEndTime() { return m_header.sessionEndTime; } // seconds
		public int getSessionLapCount() { return m_header.sessionLapCount; }

		// records 
		public int getNumRecords() { return m_header.sessionRecordCount; }
		// Reads the next line from disk and prepares it for processing.
		public void readNextRecordLine() { m_dataline = m_br.ReadBytes(m_header.bufLen); }

		public int getUpdateTickRate_Hz() { return m_header.tickRate; }
		public float getUpdateInterval_s() { return 1.0f / (float)m_header.tickRate; }

		// vars
		public int getNumVars() { return m_header.numVars; }
		public string getVarName(int index) { return m_header.varHeaders[index].name; }
		public string getVarDesc(int index) { return m_header.varHeaders[index].desc; }
		public string getVarUnit(int index) { return m_header.varHeaders[index].unit; }
		public irsdk_VarType getVarType(int index) { return m_header.varHeaders[index].type; }
		public int getVarCount(int index) { return m_header.varHeaders[index].count; }
		public bool getVarCountAsTime(int index) { return m_header.varHeaders[index].countAsTime; }

		//****Note, this is relatively slow, use double calls if you need speed but don't care about the type
		public object getVarValue(int index) { return m_header.varHeaders[index].getValue(m_dataline); }
		public double getVarValueAsDouble(int index, int offset = 0) { return m_header.varHeaders[index].getValueAsDouble(m_dataline, offset); }
		public double[] getVarValueAsDoubleArray(int index) { return m_header.varHeaders[index].getValueAsDoubleArray(m_dataline); }

		// session string
		public string getSessionStr() { return m_header.sessionInfoStr; }
		public YAMLObj getSessionObj() { return m_sessionInfoObj; }
		public string getSessionPath(string path) { return m_sessionInfoObj.getPathAsString(path);  }
		public float getSessionPathAsFloat(string path, float defVal = 0) { return m_sessionInfoObj.getPathAsFloat(path, defVal);  }
		public int getSessionPathAsInt(string path, int defVal = 0) { return m_sessionInfoObj.getPathAsInt(path, defVal);  }

		//---

		internal bool m_isOpen = false;
		internal FileStream m_file = default!;
		internal BinaryReader m_br = default!;
		internal irsdk_header m_header = new();

		internal byte[] m_dataline = default!;

		// session string parsed into an object tree
		internal YAMLObj m_sessionInfoObj = new YAMLObj(); 

		//---

		internal const int IRSDK_MAX_STRING = 32;
		internal const int IRSDK_MAX_DESC = 64; // descriptions can be longer than max_string!

		// define markers for unlimited session lap and time
		public const int IRSDK_UNLIMITED_LAPS = 32767;
		public const float IRSDK_UNLIMITED_TIME = 604800.0f;

		// latest version of our telemetry headers
		public const int IRSDK_VER = 2;


		//----

		internal class irsdk_varHeader
		{
			internal irsdk_VarType type;		// irsdk_VarType int
			internal int offset = 0;			// offset fron start of buffer row
			internal int count = 0;				// number of entrys (array)
			internal int bytes = 0;				// nunber of bytes this var type takes up
												// so length in bytes would be irsdk_VarTypeBytes[type] * count
			internal bool countAsTime = false;
			//public char pad[3];				// (16 byte align)

			internal string name = "";	// char name[IRSDK_MAX_STRING];
			internal string desc = "";	// char desc[IRSDK_MAX_DESC]; description
			internal string unit = "";	// char unit[IRSDK_MAX_STRING]; something like "kg/m^2"

			//---

			internal int getTotalBytes() { return bytes * count; }

			internal object getValue(byte[] data)
			{
				switch (type)
				{
					// 1 byte
					case irsdk_VarType.irsdk_char:
						//****FixMe, we should support this
						throw new NotSupportedException();

					case irsdk_VarType.irsdk_bool:
						if (count == 1)
							return BitConverter.ToBoolean(data, offset);
						else
						{
							var array = new bool[count];
							Buffer.BlockCopy(data, offset, array, 0, getTotalBytes());
							return array;
						}

					// 4 bytes
					case irsdk_VarType.irsdk_bitField:
					case irsdk_VarType.irsdk_int:
						if (count == 1)
						{
							//****FixMe, correct the .ibt file format so all bitfields are tagged properly
							// that will save some time doing string comparisions on every int
							// try to cast to the proper bitfield if known
							if (unit == "irsdk_Flags")
								return (irsdk_Flags)BitConverter.ToInt32(data, offset);
							else if (unit == "irsdk_CameraState")
								return (irsdk_CameraState)BitConverter.ToInt32(data, offset);
							else if (unit == "irsdk_EngineWarnings")
								return (irsdk_EngineWarnings)BitConverter.ToInt32(data, offset);
							else if (unit == "irsdk_PitSvFlags")
								return (irsdk_PitSvFlags)BitConverter.ToInt32(data, offset);
							else if (unit == "irsdk_PaceFlags")
								return (irsdk_PaceFlags)BitConverter.ToInt32(data, offset);
							// try to cast to the proper enum if known
							else if (unit == "irsdk_TrkLoc")
								return (irsdk_TrkLoc)BitConverter.ToInt32(data, offset);
							else if (unit == "irsdk_TrkSurf")
								return (irsdk_TrkSurf)BitConverter.ToInt32(data, offset);
							else if (unit == "irsdk_SessionState")
								return (irsdk_SessionState)BitConverter.ToInt32(data, offset);
							else if (unit == "irsdk_CarLeftRight")
								return (irsdk_CarLeftRight)BitConverter.ToInt32(data, offset);
							else if (unit == "irsdk_PitSvStatus")
								return (irsdk_PitSvStatus)BitConverter.ToInt32(data, offset);
							else if (unit == "irsdk_PaceMode")
								return (irsdk_PaceMode)BitConverter.ToInt32(data, offset);

							// else fall back to int
							else
								return BitConverter.ToInt32(data, offset);
						}
						else
						{
							//****FixMe, for now we don't support arrays of bitfields
							//but we should at least support irsdk_Flags, irsdk_TrkLoc, irsdk_TrkSurf, irsdk_Flags, irsdk_PaceFlags
							var array = new int[count];
							Buffer.BlockCopy(data, offset, array, 0, getTotalBytes());
							return array;
						}

					case irsdk_VarType.irsdk_float:
						if (count == 1)
							return BitConverter.ToSingle(data, offset);
						else
						{
							var array = new float[count];
							Buffer.BlockCopy(data, offset, array, 0, getTotalBytes());
							return array;
						}

					// 8 bytes
					case irsdk_VarType.irsdk_double:
						if (count == 1)
							return BitConverter.ToDouble(data, offset);
						else
						{
							var array = new double[count];
							Buffer.BlockCopy(data, offset, array, 0, getTotalBytes());
							return array;
						}

					default:
						throw new NotSupportedException();
				}
			}

			internal double getValueAsDouble(byte[] data, int index = 0)
			{
				// sainity check
				if (index < 0 || index >= count)
					index = 0;

				switch (type)
				{
					// 1 byte
					case irsdk_VarType.irsdk_char:
						//****FixMe, we should support this
						//****FixMe, how costly is throwing an error?  Maybe we want to go quietly for the sake of speed
						throw new NotSupportedException();

					case irsdk_VarType.irsdk_bool:
							return (BitConverter.ToBoolean(data, offset + (index * 1))) ? 1.0 : 0.0;

					// 4 bytes
					case irsdk_VarType.irsdk_bitField:
					case irsdk_VarType.irsdk_int:
							return BitConverter.ToInt32(data, offset + (index * 4));

					case irsdk_VarType.irsdk_float:
							return BitConverter.ToSingle(data, offset + (index * 4));

					// 8 bytes
					case irsdk_VarType.irsdk_double:
							return BitConverter.ToDouble(data, offset + (index * 8));

					default:
						throw new NotSupportedException();
				}
			}

			internal double[] getValueAsDoubleArray(byte[] data)
			{
				double[] ret = new double[count];
				int i;
				switch (type)
				{
					// 1 byte
					case irsdk_VarType.irsdk_char:
						//****FixMe, we should support this
						//****FixMe, how costly is throwing an error?  Maybe we want to go quietly for the sake of speed
						throw new NotSupportedException();

					case irsdk_VarType.irsdk_bool:
						for (i = 0; i < count; i++)
							ret[i] = (BitConverter.ToBoolean(data, offset + (i * 1))) ? 1.0 : 0.0;
						break;

					// 4 bytes
					case irsdk_VarType.irsdk_bitField:
					case irsdk_VarType.irsdk_int:
						for (i = 0; i < count; i++)
							ret[i] = BitConverter.ToInt32(data, offset + (i * 4));
						break;

					case irsdk_VarType.irsdk_float:
						for (i = 0; i < count; i++)
							ret[i] = BitConverter.ToSingle(data, offset + (i * 4));
						break;

					// 8 bytes
					case irsdk_VarType.irsdk_double:
						for (i = 0; i < count; i++)
							ret[i] = BitConverter.ToDouble(data, offset + (i * 8));
						break;

					default:
						throw new NotSupportedException();
				}

				return ret;
			}

			internal void parseHeader(BinaryReader br)
			{
				type = (irsdk_VarType)br.ReadInt32();				// irsdk_VarType
				offset = br.ReadInt32();							// offset fron start of buffer row
				count = br.ReadInt32();								// number of entrys (array)
				bytes = IRSDKHelper.getVarTypeBytes(type);			// so length in bytes would be bytes * count

				countAsTime = (br.ReadByte() != 0);
				br.ReadBytes(3);									//public char pad[3]; // (16 byte align)

				name = cStringReaderHelper(br, IRSDK_MAX_STRING);	// char name[IRSDK_MAX_STRING];
				desc = cStringReaderHelper(br, IRSDK_MAX_DESC);		// char desc[IRSDK_MAX_DESC];
				unit = cStringReaderHelper(br, IRSDK_MAX_STRING);	// char unit[IRSDK_MAX_STRING];    // something like "kg/m^2"
			}
		}

		internal class irsdk_header
		{
			//----------
			// irsdk_header
			// main header used both for disk and live data

			internal int ver = 0;					// this api header version, see IRSDK_VER
			internal irsdk_StatusField status = irsdk_StatusField.irsdk_stDisconnected; // bitfield using irsdk_StatusField
			internal int tickRate = 0;				// ticks per second (60 or 360 etc)

			// session information, updated periodicaly
			internal int sessionInfoUpdate = 0;		// Incremented when session info changes
			internal int sessionInfoLen = 0;		// Length in bytes of session info string
			internal int sessionInfoOffset = 0;		// Session info, encoded in YAML format

			// State data, output at tickRate
			internal int numVars = 0;				// length of arra pointed to by varHeaderOffset
			internal int varHeaderOffset = 0;		// offset to irsdk_varHeader[numVars] array, Describes the variables received in varBuf

			internal int numBuf = 0;				// <= IRSDK_MAX_BUFS (3 for now)
			internal int bufLen = 0;				// length in bytes for one line

			//internal int pad[2];					// (16 byte align)

			//internal irsdk_varBuf varBuf[IRSDK_MAX_BUFS]; // IRSDK_MAX_BUFS = 4
			internal int varBufOffset = 0;			// first line of variable data

			//----------
			// irsdk_diskSubHeader
			// sub header used when writing telemetry to disk

			internal System.DateTime sessionStartDate; // time_t sessionStartDate;
			internal double sessionStartTime = 0;
			internal double sessionEndTime = 0;
			internal int sessionLapCount = 0;
			internal int sessionRecordCount = 0;

			//----------
			// everything below is not part of the header structure

			internal string sessionInfoStr = "";
			internal irsdk_varHeader[] varHeaders = default!;

			//----------

			internal void parseHeader(BinaryReader br)
			{
				//----------
				// irsdk_header

				ver = br.ReadInt32();							// this api header version, see IRSDK_VER
				status = (irsdk_StatusField)br.ReadInt32();		// bitfield using irsdk_StatusField
				tickRate = br.ReadInt32();						// ticks per second (60 or 360 etc)

				// session information, updated periodicaly
				sessionInfoUpdate = br.ReadInt32();				// Incremented when session info changes
				sessionInfoLen = br.ReadInt32();				// Length in bytes of session info string
				sessionInfoOffset = br.ReadInt32();				// Session info, encoded in YAML format

				// State data, output at tickRate
				numVars = br.ReadInt32();						// length of arra pointed to by varHeaderOffset
				varHeaderOffset = br.ReadInt32();				// offset to irsdk_varHeader[numVars] array, Describes the variables received in varBuf
				numBuf = br.ReadInt32();						// <= IRSDK_MAX_BUFS (3 for now)
				bufLen = br.ReadInt32();						// length in bytes for one line

				// int pad[2]
				br.ReadInt32();
				br.ReadInt32();

				// Disk header only fills in the first irsdk_varBuf value, of 4
				//public irsdk_varBuf varBuf[IRSDK_MAX_BUFS];
				br.ReadInt32(); // tickCount
				varBufOffset = br.ReadInt32();
				br.ReadBytes(8 + 16 * 3);

				//----------
				// irsdk_diskSubHeader

				Int64 sd = br.ReadInt64();
				sessionStartDate = new System.DateTime(1970, 1, 1).AddSeconds(sd);

				sessionStartTime = br.ReadDouble();				// in seconds
				sessionEndTime = br.ReadDouble();				// in seconds
				sessionLapCount = br.ReadInt32();
				sessionRecordCount = br.ReadInt32();

				//----------
				// session string

				br.BaseStream.Seek(sessionInfoOffset, SeekOrigin.Begin);
				sessionInfoStr = cStringReaderHelper(br, sessionInfoLen);

				//----------
				// var headers (irsdk_varHeader)

				br.BaseStream.Seek(varHeaderOffset, SeekOrigin.Begin);
				varHeaders = new irsdk_varHeader[numVars];
				for (int i = 0; i < numVars; i++)
				{
					varHeaders[i] = new();
					varHeaders[i].parseHeader(br);
				}

				// put pointer at start of data
				br.BaseStream.Seek(varBufOffset, SeekOrigin.Begin);
			}
		}

		//---

		protected static string cStringReaderHelper(BinaryReader br, int maxLen)
		{
			var sb = new StringBuilder();
			for (int c = 0; c < maxLen; c++)
			{
				byte b = br.ReadByte();

				// found a NULL termination, so quit read early
				if (0 == b)
				{
					// seek to end of string, probably a faster way to do this
					int bytesRemaining = maxLen - c - 1;
					if (bytesRemaining > 0)
						br.ReadBytes(bytesRemaining);

					break;
				}
				sb.Append((char)b);
			}

			return sb.ToString();
		}
	}
}
