[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$WSFCNode2NetBIOSName,

    [Parameter(Mandatory=$true)]
    [string]$DomainAdminUser,

    [Parameter(Mandatory=$true)]
    [string]$DomainNetBIOSName,

    [Parameter(Mandatory=$true)]
    [string]$DomainDNSName,

    [Parameter(Mandatory=$true)]
    [string]$SSMParamName

)

Configuration WSFCNode2Config {
    param
    (
        [PSCredential] $Credentials,
        [PSCredential] $AltCredentials
    )
    
    Import-Module -Name PSDesiredStateConfiguration
    Import-Module -Name xActiveDirectory
    Import-Module -Name NetworkingDsc
    Import-Module -Name ComputerManagementDsc
    Import-Module -Name xDnsServer
    
    Import-DscResource -Module PSDesiredStateConfiguration
    Import-DscResource -Module NetworkingDsc
    Import-DscResource -Module xActiveDirectory
    Import-DscResource -Module ComputerManagementDsc
    Import-DscResource -Module xDnsServer
    
    Node 'localhost' {
        
        Computer NewName {
            Name = $WSFCNode2NetBIOSName
            Credential = $Credentials
        }
        
        
    }
}


$Password = (Get-SSMParameterValue -Names $SSMParamName -WithDecryption $True).Parameters[0].Value
$Credentials = (New-Object System.Management.Automation.PSCredential($DomainAdminUser,(ConvertTo-SecureString $Password -AsPlainText -Force)))


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
    
    WSFCNode2Config -OutputPath 'C:\cfn\scripts\WSFCNode2Config' -Credentials $Credentials -ConfigurationData $ConfigurationData

    Start-DscConfiguration 'C:\cfn\scripts\WSFCNode2Config' -Wait -Verbose -Force
}
catch {
    $_ | Write-host "hello"
}


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
    
    WSFCNode2Config -OutputPath 'C:\cfn\scripts\WSFCNode2Config' -Credentials $Credentials  -ConfigurationData $ConfigurationData

    Start-DscConfiguration 'C:\cfn\scripts\WSFCNode2Config' -Wait -Verbose -Force
}
catch {
    $_ | Write-host "hello"
}