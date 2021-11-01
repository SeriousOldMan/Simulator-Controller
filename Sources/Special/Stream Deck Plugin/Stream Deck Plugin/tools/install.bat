REM USAGE: Install.bat <DEBUG/RELEASE> <UUID>
REM Example: Install.bat RELEASE com.barraider.spotify
setlocal
cd /d %~dp0
cd ../bin/%1

REM MAKE SURE THE FOLLOWING ARE CORRECT
REM ALSO, UPDATE YOUR_USERNAME ON LINE 16
SET OUTPUT_DIR="C:\TEMP"
SET DISTRIBUTION_TOOL="..\..\tools\DistributionTool.exe"
SET STREAM_DECK_FILE="C:\Program Files\Elgato\StreamDeck\StreamDeck.exe"

taskkill /f /im streamdeck.exe
taskkill /f /im %2.exe
timeout /t 2
del %OUTPUT_DIR%\%2.streamDeckPlugin
%DISTRIBUTION_TOOL% -b -i %2.sdPlugin -o %OUTPUT_DIR%
rmdir C:\Users\ahupp\AppData\Roaming\Elgato\StreamDeck\Plugins\%2.sdPlugin /s /q
START "" %STREAM_DECK_FILE%
timeout /t 3
%OUTPUT_DIR%\%2.streamDeckPlugin