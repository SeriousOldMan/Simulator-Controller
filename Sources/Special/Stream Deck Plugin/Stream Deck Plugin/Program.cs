﻿using BarRaider.SdTools;
using CommandLine;
using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Pipes;
using System.Text;
using System.Threading;
using System.Windows;

namespace SimulatorControllerPlugin
{
    public class StreamString {
        private Stream ioStream;
        private UnicodeEncoding streamEncoding;

        public StreamString(Stream ioStream) {
            this.ioStream = ioStream;

            streamEncoding = new UnicodeEncoding();
        }

        public string ReadString() {
            int len = 0;

            len = ioStream.ReadByte() * 256;
            len += ioStream.ReadByte();

            byte[] inBuffer = new byte[len];
            
            ioStream.Read(inBuffer, 0, len);

            return streamEncoding.GetString(inBuffer);
        }

        public int WriteString(string outString) {
            byte[] outBuffer = streamEncoding.GetBytes(outString);
            
            int len = outBuffer.Length;
            
            if (len > UInt16.MaxValue) {
                len = (int)UInt16.MaxValue;
            }
            
            ioStream.WriteByte((byte)(len / 256));
            ioStream.WriteByte((byte)(len & 255));
            ioStream.Write(outBuffer, 0, len);
            ioStream.Flush();

            return outBuffer.Length + 2;
        }
    }

    class Program
    {
        private static void ServerThread() {
            while (true) {
                try {
                    NamedPipeServerStream pipeServer = new NamedPipeServerStream("scconnector", PipeDirection.InOut, 1);

                    int threadId = Thread.CurrentThread.ManagedThreadId;
                
                    // Wait for a client to connect
                    pipeServer.WaitForConnection();
                
                    try {
                        StreamString ss = new StreamString(pipeServer);

                        string message = ss.ReadString();

                        Program.ProcessMessage(message);
                    }
                    catch (IOException e) {
                        Logger.Instance.LogMessage(TracingLevel.ERROR, "Error during message processing: " + e.Message);
                    }

                    pipeServer.Close();
                }
                catch (Exception e)
                {
                    Logger.Instance.LogMessage(TracingLevel.ERROR, "Error during message processing: " + e.Message);
                }
            }
        }

        public abstract class Button {
            public string Function { get; set; }

            public void ProcessMessage(string operation, string argument) {
                if (operation == "SetTitle")
                    SetTitle(argument);
                else if (operation == "SetImage")
                    SetImage(argument);
            }

            public virtual void SetTitle(string title) { }

            public virtual void SetImage(string image) { }

            public Button(string function) {
                this.Function = function;
            }
        }

        static List<Button> buttons = new List<Button>();

        public static void RegisterButton(Button button) {
            if (!buttons.Contains(button))
                buttons.Add(button);
        }

        public static void UnregisterButton(Button button) {
            buttons.Remove(button);
        }

        public static void ProcessMessage(string message) {
            string[] parameters = message.Split(":".ToCharArray(), 3);
            string function = parameters[0];
            string operation = parameters[1];
            string argument = parameters[2];

            if (function == "Command")
            {
                if (operation == "SetFile")
                {
                    ControllerFunction.CommandFile = argument;
                    ControllerFunction.HasCommandFile = true;
                }
            }
            else
                foreach (var button in buttons)
                    if (button.Function.CompareTo(function) == 0)
                        button.ProcessMessage(operation, argument);
        }

        static void Main(string[] args)
        {
            // Uncomment this line of code to allow for debugging
            // while (!System.Diagnostics.Debugger.IsAttached) { System.Threading.Thread.Sleep(100); }
            // Logger.Instance.LogMessage(TracingLevel.ERROR, "Starting Simulator Controller Plugin with arguments:");
            // foreach (string s in args)
            //    Logger.Instance.LogMessage(TracingLevel.ERROR, "    " + s);

            new Thread(ServerThread).Start();

            try {
                SDWrapper.Run(args);
            }
            catch (Exception e)
            {
                Logger.Instance.LogMessage(TracingLevel.ERROR, "Error during message processing: " + e.Message);
            }
        }
    }
}
