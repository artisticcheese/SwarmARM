Configuration swarmhost
{

	    param
    (
		[string] $SwarmManagerURI
    )


Import-DscResource -ModuleName PSDesiredStateConfiguration

Import-DscResource -ModuleName cChoco
Import-DSCResource -moduleName cDSCDockerSwarm

Node localhost
  {
 

	  		cDockerSwarm Swarm {
    DependsOn = '[cDockerConfig]DaemonJson'
    SwarmMasterURI = "$($SwarmManagerURI):2377"
    SwarmMode = 'Active'
    ManagerCount = 3
    SwarmManagement = 'Automatic'
}
       cDockerConfig DaemonJson
{
    Ensure = 'Present'
    RestartOnChange = $false
    ExposeAPI = $true
    
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