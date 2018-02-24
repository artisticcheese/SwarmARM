Configuration swarmhost
{

	    param
    (
		[Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
		[string] $SwarmManagerURI
    )


Import-DscResource -ModuleName PSDesiredStateConfiguration
Import-DSCResource -moduleName xDSCFirewall
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
    ExposeAPI = $false
    EnableTLS = $false
	 Dependson = @("[xDSCFirewall]DisablePublic", "[xDSCFirewall]DisablePublic")
}

	   cChocoInstaller installChoco {
            InstallDir = "c:\choco"
        }
xDSCFirewall DisablePublic
{
  Ensure = "Absent"
  Zone = "Public"

}
	  xDSCFirewall DisablePrivate
{
  Ensure = "Absent"
  Zone = "Private"

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