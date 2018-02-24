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
			DependsOn = @("[Script]CertFiles")
            Ensure          = 'Present'
            RestartOnChange = $true
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
		#Have to use Script to save files with [File] resource is saving by default in UTF8-BOM
		Script CertFiles
{
  SetScript = {
    $privateKey | out-file -FilePath "C:\ProgramData\docker\certs.d\key.cer" -Encoding ascii
	  $serverCert | out-file -FilePath "C:\ProgramData\docker\certs.d\cert.cer" -Encoding ascii
	  $CAcert | out-file -FilePath "C:\ProgramData\docker\certs.d\ca.cer" -Encoding ascii
  }
  TestScript = { 
	  (Test-Path -Path "C:\ProgramData\docker\certs.d\key.cer") -and
	  (Test-Path -Path "C:\ProgramData\docker\certs.d\cert.cer") -and
	  (Test-Path -Path "C:\ProgramData\docker\certs.d\ca.cer")
  }
  GetScript = { @{CertFiles = (Test-Path "C:\ProgramData\docker\certs.d\ca.cer" )} }
}

		
    }
}
SwarmManager -outputpath .\out.txt

