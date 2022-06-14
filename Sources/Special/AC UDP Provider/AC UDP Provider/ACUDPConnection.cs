using System;
using System.Diagnostics;
using System.Net;
using System.Net.Sockets;
using System.Runtime.InteropServices;
using System.Threading;
using System.Threading.Tasks;

namespace ACUDPProvider
{
    public class AcUdpConnection
    {
        public ConnectionType dataType { get; private set; } // The type of data to request from the server.
        public SessionInfo sessionInfo { get; private set; } = new SessionInfo();
        public LapInfo lapInfo { get; private set; } = new LapInfo();
        public CarInfo carInfo { get; private set; } = new CarInfo();

        public bool isConnected { get; private set; }

        private UdpClient udpClient;
        string ipAddress;
        int port;

        public delegate void UpdatedEventDelegate(object sender, AcUpdateEventArgs e);
        public event UpdatedEventDelegate LapUpdate;
        public event UpdatedEventDelegate CarUpdate;

        public AcUdpConnection(string IpAddress, int port, ConnectionType mode)
        {
            this.dataType = mode;
            this.ipAddress = IpAddress;
            this.port = port;
        }

        ~AcUdpConnection()
        {
            Disconnect();

        }

        public async void Connect()
        {
            if (isConnected) return;

            try
            {
                udpClient = new UdpClient();

                udpClient.Connect(ipAddress, port);

                sendHandshake(AcConverter.handshaker.HandshakeOperation.Connect);

                Task.Run(DispatchMessages);
            }
            catch (Exception)
            {
                throw;
            }
        }

        public void Disconnect()
        {
            if (isConnected)
            {
                sendHandshake(AcConverter.handshaker.HandshakeOperation.Disconnect);
                udpClient.Close();
                udpClient.Dispose();
                udpClient = null;
                isConnected = false;
            }
        }

        private async void sendHandshake(AcConverter.handshaker.HandshakeOperation operationId)
        {
            // Calculate handshake bytes and send them.
            byte[] sendbytes = AcConverter.structToBytes(new AcConverter.handshaker(operationId));

            udpClient.SendAsync(sendbytes, sendbytes.Length).Wait();
        }

        private async void DispatchMessages()
        {
            UdpClient client;

            while ((client = udpClient) != null)
            {
                System.Net.IPEndPoint RemoteIpEndPoint = new IPEndPoint(IPAddress.Any, 0);
                try
                {
                    // Blocks until a message returns on this socket from a remote host.
                    Byte[] receiveBytes = client.Receive(ref RemoteIpEndPoint);

                    MessageReceived(receiveBytes);
                }
                catch (Exception e)
                {
                    Debug.WriteLine(e.ToString());
                }
            }
        }

        private void MessageReceived(byte[] receivebytes)
        {
            if (!isConnected) // Received data is handshake response.
            {
                if (receivebytes.Length != Marshal.SizeOf<AcConverter.handshakerResponse>())
                    return;

                // Check if it is a Handshake response-packet.
                System.Diagnostics.Debug.Assert(receivebytes.Length == Marshal.SizeOf<AcConverter.handshakerResponse>());

                AcConverter.handshakerResponse response = AcConverter.bytesToStruct<AcConverter.handshakerResponse>(receivebytes);

                // Set session info data.
                sessionInfo.driverName = AcHelperFunctions.SanitiseString(response.driverName);
                sessionInfo.carName = AcHelperFunctions.SanitiseString(response.carName);
                sessionInfo.trackName = AcHelperFunctions.SanitiseString(response.trackName);
                sessionInfo.trackLayout = AcHelperFunctions.SanitiseString(response.trackConfig);

                // Confirm handshake with data type.
                sendHandshake((AcConverter.handshaker.HandshakeOperation)dataType);
                isConnected = true;
            }
            else // An actual info packet!
            {
                switch (dataType)
                {
                    case ConnectionType.CarInfo:
                        System.Diagnostics.Debug.Assert(receivebytes.Length == Marshal.SizeOf<AcConverter.RTCarInfo>());
                        AcConverter.RTCarInfo rtcar = AcConverter.bytesToStruct<AcConverter.RTCarInfo>(receivebytes);

                        carInfo.identifier = rtcar.identifier;
                        carInfo.speedAsKmh = rtcar.speed_Kmh;
                        carInfo.engineRPM = rtcar.engineRPM;
                        carInfo.Gear = rtcar.gear;

                        carInfo.currentLapTime = TimeSpan.FromMilliseconds(rtcar.lapTime);
                        carInfo.lastLapTime = TimeSpan.FromMilliseconds(rtcar.lastLap);
                        carInfo.bestLapTime = TimeSpan.FromMilliseconds(rtcar.bestLap);

                        carInfo.position = (int)rtcar.carPositionNormalized;
                        carInfo.splinePosition = rtcar.carPositionNormalized;

                        if (CarUpdate != null)
                        {
                            AcUpdateEventArgs updateArgs = new AcUpdateEventArgs();
                            updateArgs.carInfo = this.carInfo;

                            CarUpdate(this, updateArgs);
                        }
                        break;
                    case ConnectionType.LapTime:
                        // Check if it is the right packet.
                        System.Diagnostics.Debug.Assert(receivebytes.Length == Marshal.SizeOf<AcConverter.RTLap>());

                        AcConverter.RTLap rtlap = AcConverter.bytesToStruct<AcConverter.RTLap>(receivebytes);

                        // Set last lap info data.
                        lapInfo.carName = AcHelperFunctions.SanitiseString(rtlap.carName);
                        lapInfo.driverName = AcHelperFunctions.SanitiseString(rtlap.driverName);
                        lapInfo.carIdentifier = rtlap.carIdentifierNumber;
                        lapInfo.lapNumber = rtlap.lap;
                        lapInfo.lapTime = TimeSpan.FromMilliseconds(rtlap.time);

                        if (LapUpdate != null)
                        {
                            AcUpdateEventArgs updateArgs = new AcUpdateEventArgs();
                            updateArgs.lapInfo = this.lapInfo;

                            LapUpdate(this, updateArgs);
                        }
                        break;
                    default:
                        break;
                }
            }

        }

        public enum ConnectionType
        {
            CarInfo = 1,
            LapTime = 2
        };

        public class AcUpdateEventArgs : EventArgs
        {
            public LapInfo lapInfo;
            public CarInfo carInfo;
        }
    }

}