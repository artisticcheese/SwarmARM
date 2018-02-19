Configuration SwarmManager
{
    # Parameter help description
    param
    (
		[string] $privateKey,
		[string] $serverCert,
		[string] $CAcert,
		[string] $SwarmManagerURI,
[string] $CustomData
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName cChoco
    Import-DSCResource -moduleName cDSCDockerSwarm
    Import-DscResource -ModuleName cAzureKeyVault 

    Node localhost
    {
 

        cDockerConfig DaemonJson {
            Ensure          = 'Present'
            RestartOnChange = $false
            ExposeAPI       = $true
            Labels          = "pet_swarm_manager=true"
            EnableTLS       = $false

			BaseConfigJson = '{"privateKeyLocation" : "C:\\ProgramData\\docker\\certs.d\\key.pem",
    "publicKeyLocation" : "C:\\ProgramData\\docker\\certs.d\\cert.pem",
    "publicKeyCALocation" : "C:\\ProgramData\\docker\\certs.d\\ca.pem"}' 
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
		File DumpParameters {
			Destinationpath = "c:\out.txt"
			Contents = "Hello $CustomData"
		}
    }
}
SwarmManager -outputpath .\out.txt

