Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions -EnableExpandToOpenFolder -EnableShowFullPathInTitleBar 

Disable-WindowsOptionalFeature -Online -FeatureName smb1protocol -NoRestart

Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Set-Service -Name sshd -StartupType 'Manual'

<#
# Confirm the Firewall rule is configured. It should be created automatically by setup. Run the following to verify
if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
    Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
} else {
    Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
}
#>

# Install Chocolatey (if not already installed)
if (-Not (Test-Path -Path "$env:ProgramData\chocolatey\choco.exe")) {
    Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}


choco feature enable -n=allowGlobalConfirmation

# Copy chocolatey.license.xml to C:\ProgramData\chocolatey\license
choco install chocolatey.extension
choco install boxstarter

# Install Windows features
choco install Microsoft-Hyper-V-All -source windowsfeatures

# Install Windows Subsystem for Linux (WSL) NOT for Win 11
choco install Microsoft-Windows-Subsystem-Linux -source windowsfeatures

# Remove unwanted Store apps
Get-AppxPackage Facebook.Facebook | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage TuneIn.TuneInRadio | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage Microsoft.MinecraftUWP | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage Microsoft.MicrosoftSolitaireCollection | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage KeeperSecurityInc.Keeper | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage 2FE3CB00.PicsArt-PhotoStudio | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage 9E2F88E3.Twitter | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage -AllUser -Name *Twitter | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage -AllUser -Name *MarchofEmpires | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage -AllUser -Name king.com.* | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage -AllUser -Name Microsoft.3DBuilder | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage -AllUser -Name *Bing* | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage -AllUser -Name Microsoft.Office.Word | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage -AllUser -Name Microsoft.Office.PowerPoint | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage -AllUser -Name Microsoft.Office.Excel | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage -AllUser -Name Microsoft.MicrosoftOfficeHub | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage -AllUser -Name DellInc.PartnerPromo | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage -AllUser -Name Microsoft.Office.OneNote | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage -AllUser -Name Microsoft.MicrosoftSolitaireCollection | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage -AllUser -Name Microsoft.SkypeApp | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage -AllUser -Name *XBox* | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage -AllUser -Name Microsoft.MixedReality.Portal | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage -AllUser -Name Microsoft.Microsoft3DViewer | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage -AllUser -Name SpotifyAB.SpotifyMusic | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage -AllUser -Name Microsoft.MSPaint | Remove-AppxPackage -ErrorAction SilentlyContinue # Paint3D

# Define a list of software packages to install
$packages = @(
    'firefox',                    # Mozilla Firefox
    'notepadplusplus',            # Notepad++
    '7zip',                       # 7-Zip
    'git',                        # Git
    'slack',                      # Slack
    'vscode',                     # Visual Studio Code
    'steam',                      # Steam
    'python',                     # Python
    'matlab',                     # MATLAB
    'ltspice',                    # LTspice
    'wireshark',                  # Wireshark
    'virtualbox',                 # VirtualBox
    'putty',                      # PuTTY
    'winscp',                     # WinSCP
    'hwinfo',                     # HWiNFO
    'windirstat',                 # WinDirStat
    'FiraCode',                   # FiraCode
    'pandoc',                     # Pandoc
    'ffmpeg',                     # FFmpeg
    #'winaero-tweaker',            # Winaero Tweaker
    #'windowsspyblocker',          # WindowsSpyBlocker
    # Add more packages here
)

# Install the software packages
foreach ($package in $packages) {
    choco install $package -y
}


# Optionally, remove Chocolatey after installation
#choco uninstall chocolatey -y

# Windows PowerShell modules
if (-not (Get-InstalledModule -Name Terminal-Icons -ErrorAction SilentlyContinue)) {
    Write-Host "Install-Module Terminal-Icons"
    Install-Module -Name "Terminal-Icons" -AllowClobber -Force -Scope AllUsers
}

if ((get-wmiobject Win32_ComputerSystem).manufacturer -like "*Dell*") {
    choco install dellcommandupdate-uwp
    choco install dell-update
}

wsl --install -d Ubuntu-22.04 --no-launch

# Install Windows updates
Get-Command Install-WindowsUpdate

get-module

help Boxstarter.WinConfig\Install-WindowsUpdate

# Avoid clash with builtin function
Boxstarter.WinConfig\Install-WindowsUpdate -getUpdatesFromMS -acceptEula

Write-Host "Software installation completed."

#Restart the computer
Restart-Computer -Force