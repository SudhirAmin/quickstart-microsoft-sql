[DSCLocalConfigurationManager()]
configuration LCMConfig
{
    Node 'localhost' {
        Settings {
            RefreshMode = 'Push'
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyOnly'            
            RebootNodeIfNeeded = $true  
        }
    }
}
    
LCMConfig -OutputPath 'C:\AWSQuickstart\LCMConfig'
    
Set-DscLocalConfigurationManager -Path 'C:\AWSQuickstart\LCMConfig' 
