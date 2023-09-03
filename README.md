# windows-setup

Initialize Windows 10 by Chocolatey and Boxstarter

## How To Use

1. Run a script as administrator
   
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force
   iex ((new-object net.webclient).DownloadString(''))
   ```
   