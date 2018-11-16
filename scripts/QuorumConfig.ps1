[CmdletBinding()]
param(

    [Parameter(Mandatory=$true)]
    [string]$DomainAdminUser,

    [Parameter(Mandatory=$true)]
    [string]$DomainNetBIOSName,

    [Parameter(Mandatory=$true)]
    [string]$SSMParamName

)

Configuration QuorumConfig {
    param
    (
        [PSCredential] $Credentials
    )

    Import-Module -Name xFailOverCluster
    Import-DscResource -ModuleName xFailOverCluster
    
    Node 'localhost' {
        
        xClusterQuorum 'SetQuorumToNodeAndDiskMajority'
        {
            IsSingleInstance = 'Yes'
            Type             = 'NodeAndFileShareMajority'
            Resource         = '\\WSFCFileserver\witness'
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
    
    QuorumConfig -OutputPath 'C:\cfn\scripts\QuorumConfig' -Credentials $Credentials -ConfigurationData $ConfigurationData

    Start-DscConfiguration 'C:\cfn\scripts\QuorumConfig' -Wait -Verbose -Force
}
catch {
    $_ | Write-host "hello"
}