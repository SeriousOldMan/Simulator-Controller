using System;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using F125UDPProtocol;

namespace F125UDPReceiver
{
    public class F125UDPReceiver
    {
        private UdpClient udpClient;
        private Thread receiveThread;
        private volatile bool isRunning;
        private readonly int port;
        private readonly string host;
        private readonly bool useMulticast;

        private long lastUpdate = 0;

        // Packet storage — one per packet type
        private PacketMotionData motionData;
        private PacketSessionData sessionData;
        private PacketLapData lapData;
        private PacketEventData eventData;
        private PacketParticipantsData participantsData;
        private PacketCarSetupData carSetupData;
        private PacketCarTelemetryData carTelemetryData;
        private PacketCarStatusData carStatusData;
        private PacketFinalClassificationData finalClassificationData;
        private PacketCarDamageData carDamageData;
        private PacketSessionHistoryData[] sessionHistoryData = new PacketSessionHistoryData[F125Constants.MaxCars];
        private PacketTyreSetsData tyreSetsData;
        private PacketMotionExData motionExData;

        private readonly object dataLock = new object();
        private bool receivedData = false;
        private int sessionActive = 0;
        private string lastPenalty = null;

        public F125UDPReceiver(int port = 20777, string host = "127.0.0.1", bool useMulticast = true)
        {
            this.port = port;
            this.host = host;
            this.useMulticast = useMulticast;
        }

        public bool Start()
        {
            try
            {
                // F1 25 broadcasts on the specified port — bind to Any
                IPEndPoint endPoint = new IPEndPoint(IPAddress.Any, port);

                if (useMulticast)
                {
                    udpClient = new UdpClient();
                    udpClient.Client.SetSocketOption(SocketOptionLevel.Socket, SocketOptionName.ReuseAddress, true);
                    udpClient.ExclusiveAddressUse = false;
                    udpClient.Client.Bind(endPoint);
                    try
                    {
                        udpClient.JoinMulticastGroup(IPAddress.Parse(host));
                    }
                    catch
                    {
                        // Not valid multicast address — treated as broadcast/unicast
                    }
                }
                else
                {
                    udpClient = new UdpClient();
                    udpClient.Client.SetSocketOption(SocketOptionLevel.Socket, SocketOptionName.ReuseAddress, true);
                    udpClient.ExclusiveAddressUse = false;
                    udpClient.Client.Bind(endPoint);
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
            try { udpClient?.Close(); } catch { }
            receiveThread?.Join(1000);
        }

        public long GetLastUpdate()
        {
            return lastUpdate;
        }

        private void ReceiveData()
        {
            IPEndPoint remoteEndPoint = new IPEndPoint(IPAddress.Any, 0);

            while (isRunning)
            {
                try
                {
                    byte[] data = udpClient.Receive(ref remoteEndPoint);
                    if (data.Length >= F125Constants.HeaderSize)
                        ProcessPacket(data);
                }
                catch
                {
                    // Ignore malformed packets
                    Thread.Sleep(20);
                }
            }
        }

        private void ProcessPacket(byte[] data)
        {
            // Packet ID is at byte offset 6 in the 29-byte header
            byte packetId = data[6];

            lock (dataLock)
            {
                try
                {
                    switch (packetId)
                    {
                        case 0:  // Motion
                            motionData = PacketMotionData.Decode(data);
                            break;
                        case 1:  // Session
                            sessionData = PacketSessionData.Decode(data);

                            lastUpdate = Environment.TickCount;

                            break;
                        case 2:  // Lap Data
                            lapData = PacketLapData.Decode(data);
                            break;
                        case 3:  // Event
                            eventData = PacketEventData.Decode(data);

                            if (eventData.EventStringCode == "SSTA")
                            {
                                lastPenalty = null;
                                sessionActive = Int32.MaxValue;
                            }
                            else if (eventData.EventStringCode == "SEND")
                            {
                                lastPenalty = null;
                                sessionActive = Environment.TickCount + 5000;
                            }
                            else if (eventData.EventStringCode == "PENA")
                            {
                                string penalty = F125Constants.GetPenaltyName(eventData.EventDetails[0]);

                                if (penalty != null)
                                    lastPenalty = penalty;
                            }
                            else if ((eventData.EventStringCode == "DTSV") && (lastPenalty == "DT"))
                                lastPenalty = null;
                            else if ((eventData.EventStringCode == "SGSV") && (lastPenalty == "SG"))
                                lastPenalty = null;

                            break;
                        case 4:  // Participants
                            participantsData = PacketParticipantsData.Decode(data);
                            break;
                        case 5:  // Car Setups
                            carSetupData = PacketCarSetupData.Decode(data);
                            break;
                        case 6:  // Car Telemetry
                            carTelemetryData = PacketCarTelemetryData.Decode(data);
                            break;
                        case 7:  // Car Status
                            carStatusData = PacketCarStatusData.Decode(data);
                            break;
                        case 8:  // Final Classification
                            finalClassificationData = PacketFinalClassificationData.Decode(data);
                            break;
                        case 9:  // Lobby Info – not used at runtime
                            break;
                        case 10: // Car Damage
                            carDamageData = PacketCarDamageData.Decode(data);
                            break;
                        case 11: // Session History (per-car)
                            var hist = PacketSessionHistoryData.Decode(data);
                            if (hist.CarIdx < F125Constants.MaxCars)
                                sessionHistoryData[hist.CarIdx] = hist;
                            break;
                        case 12: // Tyre Sets
                            tyreSetsData = PacketTyreSetsData.Decode(data);
                            break;
                        case 13: // Motion Ex (player car only)
                            motionExData = PacketMotionExData.Decode(data);
                            break;
                        // 14 = Time Trial, 15 = Lap Positions – not essential
                    }

                    receivedData = true;
                }
                catch
                {
                    // Skip packets that fail to decode
                }
            }
        }

        // ── Accessors ────────────────────────────────────────────────────

        public PacketMotionData GetMotionData()
        {
            lock (dataLock) { return motionData; }
        }

        public PacketSessionData GetSessionData()
        {
            lock (dataLock) { return sessionData; }
        }

        public PacketLapData GetLapData()
        {
            lock (dataLock) { return lapData; }
        }

        public PacketEventData GetEventData()
        {
            lock (dataLock) { return eventData; }
        }

        public PacketParticipantsData GetParticipantsData()
        {
            lock (dataLock) { return participantsData; }
        }

        public PacketCarSetupData GetCarSetupData()
        {
            lock (dataLock) { return carSetupData; }
        }

        public PacketCarTelemetryData GetCarTelemetryData()
        {
            lock (dataLock) { return carTelemetryData; }
        }

        public PacketCarStatusData GetCarStatusData()
        {
            lock (dataLock) { return carStatusData; }
        }

        public PacketFinalClassificationData GetFinalClassificationData()
        {
            lock (dataLock) { return finalClassificationData; }
        }

        public PacketCarDamageData GetCarDamageData()
        {
            lock (dataLock) { return carDamageData; }
        }

        public PacketSessionHistoryData GetSessionHistoryData(int carIdx)
        {
            lock (dataLock)
            {
                if (carIdx >= 0 && carIdx < F125Constants.MaxCars)
                    return sessionHistoryData[carIdx];
                return null;
            }
        }

        public PacketTyreSetsData GetTyreSetsData()
        {
            lock (dataLock) { return tyreSetsData; }
        }

        public PacketMotionExData GetMotionExData()
        {
            lock (dataLock) { return motionExData; }
        }

        public byte GetPlayerCarIndex()
        {
            lock (dataLock)
            {
                if (sessionData != null)
                    return sessionData.Header.PlayerCarIndex;
                if (motionData != null)
                    return motionData.Header.PlayerCarIndex;
                if (lapData != null)
                    return lapData.Header.PlayerCarIndex;
                return 0;
            }
        }

        public int GetNumActiveCars()
        {
            lock (dataLock)
            {
                if (participantsData != null)
                    return participantsData.NumActiveCars;
                return 0;
            }
        }

        public string GetLastPenalty()
        {
            lock (dataLock) { return lastPenalty; }
            ;
        }

        public bool IsActive()
        {
            lock (dataLock)
            {
                return Environment.TickCount < sessionActive;
            }
        }

        public bool IsPaused()
        {
            lock (dataLock)
            {
                return Environment.TickCount - GetLastUpdate() > 2000;
            }
        }

        public bool HasReceivedData()
        {
            lock (dataLock)
            {
                return receivedData;
            }
        }

        public void ClearLastPenalty()
        {
            lastPenalty = null;
        }

        public void ClearSessionData()
        {
            lock (dataLock)
            {
                motionData = null;
                sessionData = null;
                lapData = null;
                eventData = null;
                participantsData = null;
                carSetupData = null;
                carTelemetryData = null;
                carStatusData = null;
                finalClassificationData = null;
                carDamageData = null;
                sessionHistoryData = new PacketSessionHistoryData[F125Constants.MaxCars];
                tyreSetsData = null;
                motionExData = null;
                receivedData = false;
            }
        }
    }
}
