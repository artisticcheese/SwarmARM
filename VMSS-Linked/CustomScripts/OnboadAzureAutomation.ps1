param (
	[string] $RegistrationUrl,
	[string] $RegistrationKey
)



<# Custom Script for Windows #>
[DscLocalConfigurationManager()]
Configuration Main
{
    param
    (
        [Parameter(Mandatory=$True)]
        $RegistrationUrl,
		 
        [Parameter(Mandatory=$True)]
        [string]$RegistrationKey,

        [Int]$RefreshFrequencyMins = 31,
            
        [Int]$ConfigurationModeFrequencyMins = 15,
            
        [String]$ConfigurationMode = "ApplyAndMonitor",
            
        [String]$NodeConfigurationName,

        [Boolean]$RebootNodeIfNeeded= $true,

        [String]$ActionAfterReboot = "ContinueConfiguration",

        [Boolean]$AllowModuleOverwrite = $False
    )

    if(!$RefreshFrequencyMins -or $RefreshFrequencyMins -eq "")
    {
        $RefreshFrequencyMins = 30
    }

    if(!$ConfigurationModeFrequencyMins -or $ConfigurationModeFrequencyMins -eq "")
    {
        $ConfigurationModeFrequencyMins = 15
    }

    if(!$ConfigurationMode -or $ConfigurationMode -eq "")
    {
        $ConfigurationMode = "ApplyAndMonitor"
    }

        if(!$ActionAfterReboot -or $ActionAfterReboot -eq "")
    {
        $ActionAfterReboot = "ContinueConfiguration"
    }

    if(!$NodeConfigurationName -or $NodeConfigurationName -eq "")
    { 
        $ConfigurationNames = ""
    }
    else
    {
        $ConfigurationNames = @($NodeConfigurationName)
    }  
		node localhost {

    Settings
    {
        RefreshFrequencyMins = $RefreshFrequencyMins
        #RefreshMode = "PULL"
        ConfigurationMode = $ConfigurationMode
        AllowModuleOverwrite  = $AllowModuleOverwrite
        RebootNodeIfNeeded = $RebootNodeIfNeeded
        ActionAfterReboot = $ActionAfterReboot
        ConfigurationModeFrequencyMins = $ConfigurationModeFrequencyMins
    }

   # ConfigurationRepositoryWeb AzureAutomationDSC
   # {
   #     ServerUrl = $RegistrationUrl
   #     RegistrationKey = $RegistrationKey
   #     #ConfigurationNames = $ConfigurationNames
   #}

    #ResourceRepositoryWeb AzureAutomationDSC
    #{
    #    ServerUrl = $RegistrationUrl
    #    RegistrationKey = $RegistrationKey
    #}

    ReportServerWeb AzureAutomationDSC
    {
        ServerUrl = $RegistrationUrl
        RegistrationKey = $RegistrationKey
    }
		}
}
Main -OutputPath .\boot.mof -RegistrationUrl $RegistrationUrl -RegistrationKey $RegistrationKey
Set-DscLocalConfigurationManager -Path .\boot.mof 



Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name packagemanagement -Verbose -Repository PSGallery -SkipPublisherCheck
Install-Module -Name cChoco -Verbose -SkipPublisherCheck
Install-Module -Name cDSCDockerSwarm -Verbose -SkipPublisherCheck
Install-Module -Name cAzureKeyVault -Verbose -SkipPublisherCheck


