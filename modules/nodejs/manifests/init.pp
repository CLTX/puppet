class nodejs () {
    $sourceNew = "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Node.js\\node-v0.10.28-x86.msi"
    $pathNode = "C:\\Users\\daebuilduser\\AppData\\Roaming\\npm"

    package {"Node.js":
      ensure => present, 
      source => "${sourceNew}",
    }
    windows_env { 'Node':
      variable  => 'PATH',
      value     => $pathNode,
      mergemode => insert
    }
}		
