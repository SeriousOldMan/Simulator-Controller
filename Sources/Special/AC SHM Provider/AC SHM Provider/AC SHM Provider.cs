using ACSHMProvider;
using System;
using System.Collections.Generic;
using System.IO;
using System.IO.MemoryMappedFiles;
using System.Runtime.InteropServices;
using System.Timers;

namespace ACSHMProvider
{
    public delegate void PhysicsUpdatedHandler(object sender, PhysicsEventArgs e);
    public delegate void GraphicsUpdatedHandler(object sender, GraphicsEventArgs e);
    public delegate void StaticInfoUpdatedHandler(object sender, StaticInfoEventArgs e);
    public delegate void GameStatusChangedHandler(object sender, GameStatusEventArgs e);

    public class AssettoCorsaNotStartedException : Exception
    {
        public AssettoCorsaNotStartedException()
            : base("Shared Memory not connected, is Assetto Corsa running and have you run assettoCorsa.Start()?")
        {
        }
    }

    enum AC_MEMORY_STATUS { DISCONNECTED, CONNECTING, CONNECTED }

    public class SHMProvider
    {
        public void ReadSetup() { }
        public void ReadStandings() { }
        public void ReadData() { }
    }
	
    public class AssettoCorsa
    {
        private Timer sharedMemoryRetryTimer;
        private AC_MEMORY_STATUS memoryStatus = AC_MEMORY_STATUS.DISCONNECTED;
        public bool IsRunning { get { return (memoryStatus == AC_MEMORY_STATUS.CONNECTED); } }

        private AC_STATUS gameStatus = AC_STATUS.AC_OFF;

        public event GameStatusChangedHandler GameStatusChanged;
        public virtual void OnGameStatusChanged(GameStatusEventArgs e)
        {
            if (GameStatusChanged != null)
            {
                GameStatusChanged(this, e);
            }
        }

        public static readonly Dictionary<AC_STATUS, string> StatusNameLookup = new Dictionary<AC_STATUS, string>
        {
            { AC_STATUS.AC_OFF, "Off" },
            { AC_STATUS.AC_LIVE, "Live" },
            { AC_STATUS.AC_PAUSE, "Pause" },
            { AC_STATUS.AC_REPLAY, "Replay" },
        };

        public AssettoCorsa()
        {
            sharedMemoryRetryTimer = new Timer(2000);
            sharedMemoryRetryTimer.AutoReset = true;
            sharedMemoryRetryTimer.Elapsed += sharedMemoryRetryTimer_Elapsed;

            physicsTimer = new Timer();
            physicsTimer.AutoReset = true;
            physicsTimer.Elapsed += physicsTimer_Elapsed;
            PhysicsInterval = 10;

            graphicsTimer = new Timer();
            graphicsTimer.AutoReset = true;
            graphicsTimer.Elapsed += graphicsTimer_Elapsed;
            GraphicsInterval = 1000;

            staticInfoTimer = new Timer();
            staticInfoTimer.AutoReset = true;
            staticInfoTimer.Elapsed += staticInfoTimer_Elapsed;
            StaticInfoInterval = 1000;

            Stop();
        }

        /// <summary>
        /// Connect to the shared memory and start the update timers
        /// </summary>
        public void Start()
        {
            sharedMemoryRetryTimer.Start();
        }

        void sharedMemoryRetryTimer_Elapsed(object sender, ElapsedEventArgs e)
        {
            ConnectToSharedMemory();
        }

        private bool ConnectToSharedMemory()
        {
            try
            {
                memoryStatus = AC_MEMORY_STATUS.CONNECTING;
                // Connect to shared memory
                physicsMMF = MemoryMappedFile.OpenExisting("Local\\acpmf_physics");
                graphicsMMF = MemoryMappedFile.OpenExisting("Local\\acpmf_graphics");
                staticInfoMMF = MemoryMappedFile.OpenExisting("Local\\acpmf_static");

                // Start the timers
                staticInfoTimer.Start();
                ProcessStaticInfo();

                graphicsTimer.Start();
                ProcessGraphics();

                physicsTimer.Start();
                ProcessPhysics();

                // Stop retry timer
                sharedMemoryRetryTimer.Stop();
                memoryStatus = AC_MEMORY_STATUS.CONNECTED;
                return true;
            }
            catch (FileNotFoundException)
            {
                staticInfoTimer.Stop();
                graphicsTimer.Stop();
                physicsTimer.Stop();
                return false;
            }
        }

        /// <summary>
        /// Stop the timers and dispose of the shared memory handles
        /// </summary>
        public void Stop()
        {
            memoryStatus = AC_MEMORY_STATUS.DISCONNECTED;
            sharedMemoryRetryTimer.Stop();

            // Stop the timers
            physicsTimer.Stop();
            graphicsTimer.Stop();
            staticInfoTimer.Stop();
        }

        /// <summary>
        /// Interval for physics updates in milliseconds
        /// </summary>
        public double PhysicsInterval
        {
            get
            {
                return physicsTimer.Interval;
            }
            set
            {
                physicsTimer.Interval = value;
            }
        }

        /// <summary>
        /// Interval for graphics updates in milliseconds
        /// </summary>
        public double GraphicsInterval
        {
            get
            {
                return graphicsTimer.Interval;
            }
            set
            {
                graphicsTimer.Interval = value;
            }
        }

        /// <summary>
        /// Interval for static info updates in milliseconds
        /// </summary>
        public double StaticInfoInterval
        {
            get
            {
                return staticInfoTimer.Interval;
            }
            set
            {
                staticInfoTimer.Interval = value;
            }
        }

        MemoryMappedFile physicsMMF;
        MemoryMappedFile graphicsMMF;
        MemoryMappedFile staticInfoMMF;

        Timer physicsTimer;
        Timer graphicsTimer;
        Timer staticInfoTimer;

        /// <summary>
        /// Represents the method that will handle the physics update events
        /// </summary>
        public event PhysicsUpdatedHandler PhysicsUpdated;

        /// <summary>
        /// Represents the method that will handle the graphics update events
        /// </summary>
        public event GraphicsUpdatedHandler GraphicsUpdated;

        /// <summary>
        /// Represents the method that will handle the static info update events
        /// </summary>
        public event StaticInfoUpdatedHandler StaticInfoUpdated;

        public virtual void OnPhysicsUpdated(PhysicsEventArgs e)
        {
            if (PhysicsUpdated != null)
            {
                PhysicsUpdated(this, e);
            }
        }

        public virtual void OnGraphicsUpdated(GraphicsEventArgs e)
        {
            if (GraphicsUpdated != null)
            {
                GraphicsUpdated(this, e);
                if (gameStatus != e.Graphics.Status)
                {
                    gameStatus = e.Graphics.Status;
                    GameStatusChanged(this, new GameStatusEventArgs(gameStatus));
                }
            }
        }

        public virtual void OnStaticInfoUpdated(StaticInfoEventArgs e)
        {
            if (StaticInfoUpdated != null)
            {
                StaticInfoUpdated(this, e);
            }
        }

        private void physicsTimer_Elapsed(object sender, ElapsedEventArgs e)
        {
            ProcessPhysics();
        }

        private void graphicsTimer_Elapsed(object sender, ElapsedEventArgs e)
        {
            ProcessGraphics();
        }

        private void staticInfoTimer_Elapsed(object sender, ElapsedEventArgs e)
        {
            ProcessStaticInfo();
        }

        private void ProcessPhysics()
        {
            if (memoryStatus == AC_MEMORY_STATUS.DISCONNECTED)
                return;

            try
            {
                Physics physics = ReadPhysics();
                OnPhysicsUpdated(new PhysicsEventArgs(physics));
            }
            catch (AssettoCorsaNotStartedException)
            { }
        }

        private void ProcessGraphics()
        {
            if (memoryStatus == AC_MEMORY_STATUS.DISCONNECTED)
                return;

            try
            {
                Graphics graphics = ReadGraphics();
                OnGraphicsUpdated(new GraphicsEventArgs(graphics));
            }
            catch (AssettoCorsaNotStartedException)
            { }
        }

        private void ProcessStaticInfo()
        {
            if (memoryStatus == AC_MEMORY_STATUS.DISCONNECTED)
                return;

            try
            {
                StaticInfo staticInfo = ReadStaticInfo();
                OnStaticInfoUpdated(new StaticInfoEventArgs(staticInfo));
            }
            catch (AssettoCorsaNotStartedException)
            { }
        }

        /// <summary>
        /// Read the current physics data from shared memory
        /// </summary>
        /// <returns>A Physics object representing the current status, or null if not available</returns>
        public Physics ReadPhysics()
        {
            if (memoryStatus == AC_MEMORY_STATUS.DISCONNECTED || physicsMMF == null)
                throw new AssettoCorsaNotStartedException();

            using (var stream = physicsMMF.CreateViewStream())
            {
                using (var reader = new BinaryReader(stream))
                {
                    var size = Marshal.SizeOf(typeof(Physics));
                    var bytes = reader.ReadBytes(size);
                    var handle = GCHandle.Alloc(bytes, GCHandleType.Pinned);
                    var data = (Physics)Marshal.PtrToStructure(handle.AddrOfPinnedObject(), typeof(Physics));
                    handle.Free();
                    return data;
                }
            }
        }

        public Graphics ReadGraphics()
        {
            if (memoryStatus == AC_MEMORY_STATUS.DISCONNECTED || graphicsMMF == null)
                throw new AssettoCorsaNotStartedException();

            using (var stream = graphicsMMF.CreateViewStream())
            {
                using (var reader = new BinaryReader(stream))
                {
                    var size = Marshal.SizeOf(typeof(Graphics));
                    var bytes = reader.ReadBytes(size);
                    var handle = GCHandle.Alloc(bytes, GCHandleType.Pinned);
                    var data = (Graphics)Marshal.PtrToStructure(handle.AddrOfPinnedObject(), typeof(Graphics));
                    handle.Free();
                    return data;
                }
            }
        }

        public StaticInfo ReadStaticInfo()
        {
            if (memoryStatus == AC_MEMORY_STATUS.DISCONNECTED || staticInfoMMF == null)
                throw new AssettoCorsaNotStartedException();

            using (var stream = staticInfoMMF.CreateViewStream())
            {
                using (var reader = new BinaryReader(stream))
                {
                    var size = Marshal.SizeOf(typeof(StaticInfo));
                    var bytes = reader.ReadBytes(size);
                    var handle = GCHandle.Alloc(bytes, GCHandleType.Pinned);
                    var data = (StaticInfo)Marshal.PtrToStructure(handle.AddrOfPinnedObject(), typeof(StaticInfo));
                    handle.Free();
                    return data;
                }
            }
        }
    }
}
