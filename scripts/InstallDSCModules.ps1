[CmdletBinding()]
param()

Set-ExecutionPolicy RemoteSigned -Force

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module NetworkingDsc
Install-Module -Name "xActiveDirectory" -RequiredVersion 2.18.0.0
Install-Module ComputerManagementDsc
Install-Module -Name "xDnsServer"
Install-Module -Name "xFailOverCluster"

Get-NetFirewallProfile | Set-NetFirewallProfile -Enabled False