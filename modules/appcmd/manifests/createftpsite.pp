define appcmd::createftpsite (
  $ftpSiteName,
  $physicalPath,
  $authentication = "anonymous",
  $accesstype
  
) {
 
include appcmd 

  exec { "CreateFTPSite ${ftpSiteName}":
    command => "appcmd add site /name:\"${ftpSiteName}\" /bindings:ftp://*:21 /physicalPath:\"${physicalPath}\"",
    unless => "cmd /c \"appcmd list site | findstr \"SITE\" | findstr  \"${ftpSiteName}\"\"\"\"\"",
  }
  
  exec { "Configuring Control Channel ${ftpSiteName}":
    command => "appcmd set config -section:system.applicationHost/sites /[name=\'${ftpSiteName}\'].ftpServer.security.ssl.controlChannelPolicy:\"SslAllow\" ",
	unless => "cmd /c \"appcmd list config  -section:system.applicationHost/sites | findstr \"controlChannelPolicy=\"\"SslAllow\"\"\"\"\"",
    require => Exec["CreateFTPSite ${ftpSiteName}"]
  }
  
  exec { "Configuring Data Channel ${ftpSiteName}":
    command => "appcmd set config -section:system.applicationHost/sites /[name=\'${ftpSiteName}\'].ftpServer.security.ssl.dataChannelPolicy:\"SslAllow\" ",
	unless => "cmd /c \"appcmd list config -section:system.applicationHost/sites | findstr \"dataChannelPolicy=\"\"SslAllow\"\"\"\"\"",
    require => Exec["CreateFTPSite ${ftpSiteName}"]
  }  
  
  if $authentication == "anonymous" {
      exec { "Configuring Anonymous Authentication ${ftpSiteName}":
        command => "appcmd set config -section:system.applicationHost/sites /[name=\'${ftpSiteName}\'].ftpServer.security.authentication.anonymousAuthentication.enabled:true",
	    unless => "cmd /c \"appcmd list config -section:system.applicationHost/sites | findstr \"anonymousAuthentication enabled=\"\"true\"\"\"\"\"",
        require => Exec["CreateFTPSite ${ftpSiteName}"]
      }  
  } else{
      exec { "Configuring Basic Authentication ${ftpSiteName}":
        command => "appcmd set config -section:system.applicationHost/sites /[name=\'${ftpSiteName}\'].ftpServer.security.authentication.basicAuthentication.enabled:true",
	    unless => "cmd /c \"appcmd list config -section:system.applicationHost/sites | findstr \"basicAuthentication enabled=\"\"true\"\"\"\"\"",
        require => Exec["CreateFTPSite ${ftpSiteName}"]
      }  
  }
  
  exec { "Configuring Access Type ${ftpSiteName}":
    command => "appcmd set config ${ftpSiteName} /section:system.ftpserver/security/authorization /+[accessType=\'Allow\',permissions=\'${accesstype}\',roles=\'\',users=\'*\'] /commit:apphost",
	unless => "cmd /c \"appcmd list config confirmit /section:system.ftpserver/security/authorization | findstr \"accessType=\"\"Allow\"\"\"\"\"",
    require => Exec["CreateFTPSite ${ftpSiteName}"]
  }  
}
