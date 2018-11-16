[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$WSFCNode1NetBIOSName,

    [Parameter(Mandatory=$true)]
    [string]$DomainAdminUser,

    [Parameter(Mandatory=$true)]
    [string]$DomainNetBIOSName,

    [Parameter(Mandatory=$true)]
    [string]$DomainDNSName,

    [Parameter(Mandatory=$true)]
    [string]$SSMParamName

)

Configuration WSFCNode1Config {
    param
    (
        [PSCredential] $Credentials
    )
    
    Import-Module -Name PSDesiredStateConfiguration
    Import-Module -Name xActiveDirectory
    Import-Module -Name NetworkingDsc
    Import-Module -Name ComputerManagementDsc
    Import-Module -Name xDnsServer
    Import-Module -Name xFailOverCluster
    Install-Module -Name SqlServerDsc

    Import-DscResource -ModuleName SqlServerDsc
    Import-DscResource -Module PSDesiredStateConfiguration
    Import-DscResource -Module NetworkingDsc
    Import-DscResource -Module xActiveDirectory
    Import-DscResource -Module ComputerManagementDsc
    Import-DscResource -Module xDnsServer
    Import-DscResource -ModuleName xFailOverCluster
    
    Node 'localhost' {
        
        WindowsFeature 'NetFramework45'
        {
             Name   = 'NET-Framework-45-Core'
             Ensure = 'Present'
        }

        SqlSetup 'InstallDefaultInstance'
        {
             InstanceName        = 'MSSQLSERVER'
             Features            = 'SQLENGINE'
             SourcePath          = 'C:\SQL2017'
             SQLSysAdminAccounts = @('Administrators')
             DependsOn           = '[WindowsFeature]NetFramework45'
        }
        
    }
}

$ClusterAdminUser = $DomainNetBIOSName + '\' + $DomainAdminUser
$Password = (Get-SSMParameterValue -Names $SSMParamName -WithDecryption $True).Parameters[0].Value
$Credentials = (New-Object System.Management.Automation.PSCredential($ClusterAdminUser,(ConvertTo-SecureString $Password -AsPlainText -Force)))



$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName="*"
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true
        },
        @{
            NodeName = 'localhost'
        }
    )
}

try {
    
    Start-Transcript -Path C:\cfn\log\$($MyInvocation.MyCommand.Name).log -Append
    
    WSFCNode1Config -OutputPath 'C:\cfn\scripts\WSFCNode1Config' -Credentials $Credentials -ConfigurationData $ConfigurationData

    Start-DscConfiguration 'C:\cfn\scripts\WSFCNode1Config' -Wait -Verbose -Force
}
catch {
    $_ | Write-AWSQuickStartException
}