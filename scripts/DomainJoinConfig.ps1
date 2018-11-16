[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string] $Node,

    [Parameter(Mandatory=$true)]
    [string]$DomainAdminUser,

    [Parameter(Mandatory=$true)]
    [string]$DomainNetBIOSName,

    [Parameter(Mandatory=$true)]
    [string]$DomainDNSName,

    [Parameter(Mandatory=$true)]
    [string]$SSMParamName

)

Configuration DomainJoinConfig {
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
    
    
    Import-DscResource -Module PSDesiredStateConfiguration
    Import-DscResource -Module NetworkingDsc
    Import-DscResource -Module xActiveDirectory
    Import-DscResource -Module ComputerManagementDsc
    Import-DscResource -Module xDnsServer
    Import-DscResource -ModuleName xFailOverCluster
    
    Node 'localhost' {
        Computer JoinDomain
        {
            Name       = $Node
            DomainName = $DomainNetBIOSName
            Credential = $Credential # Credential to join to domain
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
    
    DomainJoinConfig -OutputPath 'C:\cfn\scripts\DomainJoinConfig' -Credentials $Credentials -ConfigurationData $ConfigurationData

    Start-DscConfiguration 'C:\cfn\scripts\DomainJoinConfig' -Wait -Verbose -Force
}
catch {
    $_ | Write-AWSQuickStartException
}