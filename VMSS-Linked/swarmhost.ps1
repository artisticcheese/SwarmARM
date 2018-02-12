Configuration SwarmHost
{


Import-DscResource -ModuleName PSDesiredStateConfiguration
Import-DscResource -ModuleName PackageManagement -ModuleVersion 1.1.6.0
Import-DscResource -ModuleName cChoco
Import-DSCResource -moduleName cDSCDockerSwarm

Node localhost
  {
 
	  PackageManagement xPSDesiredStateConfiguration {
            Ensure = 'present'
            Name = "xPSDesiredStateConfiguration"
            Source = "PSGallery"
       
        } 
       cDockerConfig DaemonJson
{
    Ensure = 'Present'
    RestartOnChange = $false
    ExposeAPI = $true
    Labels = "contoso.environment=dev","contoso.usage=internal"
    EnableTLS = $false
}
	   cChocoInstaller installChoco {
            InstallDir = "c:\choco"
        }
        cChocoPackageInstallerSet installSomeStuff {
            Ensure = 'Present'
            Name = @(
                "classic-shell"
                "7zip"
                "visualstudiocode"
            )
            
        }
}
	}