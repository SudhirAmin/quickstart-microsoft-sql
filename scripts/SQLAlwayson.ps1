Configuration Alwayson
{

param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credentials
    )

     Import-DscResource -ModuleName SqlServerDsc

     node localhost
     {
          
          
          SqlAlwaysOnService 'EnableAlwaysOn'
        {
            Ensure               = 'Present'
            ServerName           = 'WSFCNode1'
            InstanceName         = 'MSSQLSERVER'
            RestartTimeout       = 120

            PsDscRunAsCredential = $Credentials
     }
}
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

Alwayson -OutputPath 'C:\cfn\scripts\ASConfig' -Credentials $Credentials -ConfigurationData $ConfigurationData

Start-DscConfiguration 'C:\cfn\scripts\ASConfig' -Wait -Verbose -Force