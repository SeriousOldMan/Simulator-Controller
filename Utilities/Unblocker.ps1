takeown.exe /F . /R /D N
Get-ChildItem -Path '.' -Recurse | Unblock-File