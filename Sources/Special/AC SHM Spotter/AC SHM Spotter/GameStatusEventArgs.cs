using System;

namespace ACSHMSpotter
{
    public class GameStatusEventArgs : EventArgs
    {
        public AC_STATUS GameStatus {get; private set;}

        public GameStatusEventArgs(AC_STATUS status)
        {
            GameStatus = status;
        }
    }
}