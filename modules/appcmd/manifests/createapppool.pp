define appcmd::createapppool(
	$appName,
	$runtimeVersion,
	$managedPipeline,
	$userName = undef,
	$password = undef,
	$idletimeout = undef
  ){

include appcmd
	
	exec { "appcmdcreateapppool ${appName}":	
		command => "appcmd.exe add apppool /name:$appName /managedRuntimeVersion:$runtimeVersion /managedPipelineMode:$managedPipeline",
		unless => "cmd.exe /c \"appcmd.exe list APPPOOL | find.exe \"${runtimeVersion}\" |  findstr.exe \"\"\"${appName}\"\"\"\"",
	  }
	
exec { "changeapppool ${appName}":	
       command => "appcmd.exe set apppool /apppool.name:$appName /managedPipelineMode:$managedPipeline",
	     unless => "cmd.exe /c \"appcmd.exe list APPPOOL | find.exe \"${managedPipeline}\" | findstr.exe \"\"\"${appName}\"\"\"\"",
	     require => Exec["appcmdcreateapppool ${appName}"]
    }	
	
	appcmd::32bit { "32bit disabling for app ${appName}":
	  appName  => "${appName}",
	  enabled => "false",
	  require  => Exec["appcmdcreateapppool ${appName}"]	
	  
	}
	
	if $userName {
		appcmd::configapppool { "Configuring AppPool ${appName}":
		  appName  => "${appName}",
		  userName => "${userName}",
		  password => "${password}",
		  require  => Exec["appcmdcreateapppool ${appName}"]	
		}
	}
	
	if $idletimeout {
	  appcmd::idletimeout { "${appName}":
        apppool     => "${appName}",
        idletimeout => "${idletimeout}",
        require     => Exec["appcmdcreateapppool ${appName}"]
      }
	}
	
  }
