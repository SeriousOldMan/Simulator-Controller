using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Sockets;
using System.Text;
using System.Threading.Tasks;

namespace ksBroadcastingNetwork
{
    public class ACCUdpRemoteClient : IDisposable
    {
        private UdpClient _client;
        private Task _listenerTask;
        public BroadcastingNetworkProtocol MessageHandler { get; }
        public string IpPort { get; }
        public string DisplayName { get; }
        public string ConnectionPassword { get; }
        public string CommandPassword { get; }
        public int MsRealtimeUpdateInterval { get; }

        /// <summary>
        /// To get the events delivered inside the UI thread, just create this object from the UI thread/synchronization context.
        /// </summary>
        public ACCUdpRemoteClient(string ip, int port, string displayName, string connectionPassword, string commandPassword, int msRealtimeUpdateInterval)
        {
            IpPort = $"{ip}:{port}";
            MessageHandler = new BroadcastingNetworkProtocol(IpPort, Send);
            _client = new UdpClient();
            _client.Connect(ip, port);

            DisplayName = displayName;
            ConnectionPassword = connectionPassword;
            CommandPassword = commandPassword;
            MsRealtimeUpdateInterval = msRealtimeUpdateInterval;

            _listenerTask = ConnectAndRun();
        }

        private void Send(byte[] payload)
        {
            var sent = _client.Send(payload, payload.Length);
        }

        public void Shutdown()
        {
            ShutdownAsnyc().ContinueWith(t =>
             {
                 if (t.Exception?.InnerExceptions?.Any() == true)
                     System.Diagnostics.Debug.WriteLine($"Client shut down with {t.Exception.InnerExceptions.Count} errors");
                 else
                     System.Diagnostics.Debug.WriteLine("Client shut down asynchronously");

             });
        }

        public async Task ShutdownAsnyc()
        {
            if (_listenerTask != null && !_listenerTask.IsCompleted)
            {
                MessageHandler.Disconnect();
                _client.Close();
                _client = null;
                await _listenerTask;
            }
        }

        private async Task ConnectAndRun()
        {
            MessageHandler.RequestConnection(DisplayName, ConnectionPassword, MsRealtimeUpdateInterval, CommandPassword);
            while (_client != null)
            {
                try
                {
                    var udpPacket = await _client.ReceiveAsync();
                    using (var ms = new System.IO.MemoryStream(udpPacket.Buffer))
                    using (var reader = new System.IO.BinaryReader(ms))
                    {
                        MessageHandler.ProcessMessage(reader);
                    }
                }
                catch (ObjectDisposedException)
                {
                    // Shutdown happened
                    break;
                }
                catch (Exception ex)
                {
                    // Other exceptions
                    System.Diagnostics.Debug.WriteLine(ex);
                }
            }
        }

        #region IDisposable Support
        private bool disposedValue = false; // To detect redundant calls

        protected virtual void Dispose(bool disposing)
        {
            if (!disposedValue)
            {
                if (disposing)
                {
                    try
                    {
                        if (_client != null)
                        {
                            _client.Close();
                            _client.Dispose();
                            _client = null;
                        }

                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine(ex);
                    }
                }

                // TODO: free unmanaged resources (unmanaged objects) and override a finalizer below.
                // TODO: set large fields to null.

                disposedValue = true;
            }
        }

        // TODO: override a finalizer only if Dispose(bool disposing) above has code to free unmanaged resources.
        // ~ACCUdpRemoteClient() {
        //   // Do not change this code. Put cleanup code in Dispose(bool disposing) above.
        //   Dispose(false);
        // }

        // This code added to correctly implement the disposable pattern.
        public void Dispose()
        {
            // Do not change this code. Put cleanup code in Dispose(bool disposing) above.
            Dispose(true);
            // TODO: uncomment the following line if the finalizer is overridden above.
            // GC.SuppressFinalize(this);
        }
        #endregion
    }
}
