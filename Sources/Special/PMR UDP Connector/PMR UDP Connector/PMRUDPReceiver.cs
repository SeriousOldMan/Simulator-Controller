using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Sockets;
using System.Threading;

namespace PMRUDPConnector
{
    public class PMRUDPReceiver
    {
        private UdpClient udpClient;
        private Thread receiveThread;
        private bool isRunning;
        private readonly int port;
        private readonly string multicastGroup;
        private readonly bool useMulticast;

        private UDPRaceInfo raceInfo;
        private Dictionary<int, UDPParticipantRaceState> participantStates = new Dictionary<int, UDPParticipantRaceState>();
        private Dictionary<int, UDPVehicleTelemetry> participantTelemetry = new Dictionary<int, UDPVehicleTelemetry>();
        private int playerVehicleId = -1;
        private readonly object dataLock = new object();

        public PMRUDPReceiver(int port = 7576, string multicastGroup = "224.0.0.150", bool useMulticast = true)
        {
            this.port = port;
            this.multicastGroup = multicastGroup;
            this.useMulticast = useMulticast;
        }

        public bool Start()
        {
            try
            {
                if (useMulticast)
                {
                    udpClient = new UdpClient(port);
                    udpClient.JoinMulticastGroup(IPAddress.Parse(multicastGroup));
                }
                else
                {
                    udpClient = new UdpClient(new IPEndPoint(IPAddress.Any, port));
                }

                isRunning = true;
                receiveThread = new Thread(ReceiveData);
                receiveThread.IsBackground = true;
                receiveThread.Start();
                return true;
            }
            catch
            {
                return false;
            }
        }

        public void Stop()
        {
            isRunning = false;
            udpClient?.Close();
            receiveThread?.Join(1000);
        }

        private void ReceiveData()
        {
            IPEndPoint remoteEndPoint = new IPEndPoint(IPAddress.Any, 0);

            while (isRunning)
            {
                try
                {
                    byte[] data = udpClient.Receive(ref remoteEndPoint);
                    ProcessPacket(data);
                }
                catch (SocketException)
                {
                    break;
                }
                catch
                {
                    // Ignore malformed packets
                }
            }
        }

        private void ProcessPacket(byte[] data)
        {
            if (data.Length < 1) return;

            UDPPacketType packetType = (UDPPacketType)data[0];
            int offset = 1;

            lock (dataLock)
            {
                switch (packetType)
                {
                    case UDPPacketType.RaceInfo:
                        raceInfo = UDPRaceInfo.Decode(data, ref offset);
                        break;

                    case UDPPacketType.ParticipantRaceState:
                        var state = UDPParticipantRaceState.Decode(data, ref offset);
                        participantStates[state.VehicleId] = state;
                        if (state.IsPlayer)
                            playerVehicleId = state.VehicleId;
                        break;

                    case UDPPacketType.ParticipantVehicleTelemetry:
                        var telem = UDPVehicleTelemetry.Decode(data, ref offset);
                        participantTelemetry[telem.VehicleId] = telem;
                        break;

                    case UDPPacketType.SessionStopped:
                        ClearSessionData();
                        break;
                }
            }
        }

        private void ClearSessionData()
        {
            raceInfo = null;
            participantStates.Clear();
            participantTelemetry.Clear();
            playerVehicleId = -1;
        }

        public UDPRaceInfo GetRaceInfo()
        {
            lock (dataLock)
            {
                return raceInfo;
            }
        }

        public UDPParticipantRaceState GetPlayerState()
        {
            lock (dataLock)
            {
                if (playerVehicleId >= 0 && participantStates.ContainsKey(playerVehicleId))
                    return participantStates[playerVehicleId];
                return null;
            }
        }

        public UDPVehicleTelemetry GetPlayerTelemetry()
        {
            lock (dataLock)
            {
                if (playerVehicleId >= 0 && participantTelemetry.ContainsKey(playerVehicleId))
                    return participantTelemetry[playerVehicleId];
                return null;
            }
        }

        public List<UDPParticipantRaceState> GetAllParticipantStates()
        {
            lock (dataLock)
            {
                return new List<UDPParticipantRaceState>(participantStates.Values);
            }
        }

        public bool IsActive()
        {
            lock (dataLock)
            {
                return raceInfo != null && raceInfo.State == UDPRaceSessionState.Active;
            }
        }
		
        public bool HasReceivedData()
        {
            lock (dataLock)
            {
                return raceInfo != null && participantStates.Count > 0 && participantTelemetry.Count > 0;
            }
        }
    }
}
