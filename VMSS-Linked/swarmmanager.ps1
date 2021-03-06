Configuration SwarmManager
{
    # Parameter help description
    param
    (
		[string] $privateKey,
		[string] $serverCert,
		[string] $CAcert,
		[string] $SwarmManagerURI
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName cChoco
    Import-DSCResource -moduleName cDSCDockerSwarm


    Node localhost
    {
 

        cDockerConfig DaemonJson {
            Ensure          = 'Present'
            RestartOnChange = $false
            ExposeAPI       = $true
            Labels          = "pet_swarm_manager=true"
            EnableTLS       = $false

			BaseConfigJson = '{"tlskey" : "C:\\ProgramData\\docker\\certs.d\\key.cer",
    "tlscert" : "C:\\ProgramData\\docker\\certs.d\\cert.cer",
    "tlsCAcert" : "C:\\ProgramData\\docker\\certs.d\\ca.cer"}' 
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
			Destinationpath = "$($env:programdata)\docker\certs.d\privateKey.cer"
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

