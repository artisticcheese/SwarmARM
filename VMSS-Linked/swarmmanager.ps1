Configuration SwarmManager
{
    # Parameter help description
    param
    (
		[string] $privateKey = (Get-AutomationVariable -Name privatekey),
		[string] $serverCert = (Get-AutomationVariable -Name servercert),
		[string] $CAcert = (Get-AutomationVariable -Name ca),
		[string] $SwarmManagerURI
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName cChoco
    Import-DSCResource -moduleName cDSCDockerSwarm
Import-DSCResource -moduleName xDSCFirewall
    
    

    Node localhost
    {
 

        cDockerConfig DaemonJson {
            Ensure          = 'Present'
            RestartOnChange = $false
            ExposeAPI       = $true
            Labels          = "pet_swarm_manager=true"
            

			BaseConfigJson = '{"tlsverify": true,
				"tlskey" : "C:\\ProgramData\\docker\\certs.d\\key.cer",
    "tlscert" : "C:\\ProgramData\\docker\\certs.d\\cert.cer",
    "tlscacert" : "C:\\ProgramData\\docker\\certs.d\\ca.cer"}' 
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
		cDockerSwarm Swarm {
    DependsOn = '[cDockerConfig]DaemonJson'
    SwarmMasterURI = "$($SwarmManagerURI):2377"
    SwarmMode = 'Active'
    ManagerCount = 3
    SwarmManagement = 'Automatic'
}

        cChocoInstaller installChoco {
            InstallDir = "c:\choco"
        }
        cChocoPackageInstallerSet ProgramInstalls {
            Ensure = 'Present'
            Name   = @(
                "classic-shell"
                "7zip"
                "visualstudiocode"
				"sysinternals"
            )
            
        }
		
		File PrivateKey{
			Destinationpath = "$($env:programdata)\docker\certs.d\key.cer"
			Contents = $privateKey
			Force = $true
		}
		File ServerCert
		{
						Destinationpath = "$($env:programdata)\docker\certs.d\cert.cer"
			Contents = $serverCert
			Force = $true
		}
		File CACert
		{
			Destinationpath = "$($env:programdata)\docker\certs.d\ca.cer"
			Contents = $CAcert
			Force = $true
		}
    }
}
SwarmManager -outputpath .\out.txt

