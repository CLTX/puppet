class appname01::sharesetup () {

include sharefolder
include folderpermission

$userservice = "yourdomain\\daedbuser"

  file {'D:\mycompany':
    ensure  => appname03ory,
    group   => 'Administrators',
  }

  file {'D:\mycompany\Services':
    ensure  => appname03ory,
    group   => 'Administrators',
    require => File['D:\mycompany']
  }
  
  file {'D:\mycompany\appname01':
    ensure  => appname03ory,
    group   => 'Administrators',
    require => File['D:\mycompany']
  }

  folderpermission::rights{'Services':
    path       => 'D:\mycompany\Services',
    user       => "$hostname\Administrators",
    rights     => 'FullControl',
    permission => 'Allow',
    require => File['D:\mycompany\Services']
  }
  
  folderpermission::rights{'Services2':
    path       => 'D:\mycompany\Services',
    user       => 'yourdomain\daebuilduser',
    rights     => 'FullControl',
    permission => 'Allow',
    require => File['D:\mycompany\Services']
  }
  
  folderpermission::rights{'appname01':
    path       => 'D:\mycompany\appname01',
    user       => "$hostname\Administrators",
    rights     => 'FullControl',
    permission => 'Allow',
    require => File['D:\mycompany\appname01']
  }
  
  folderpermission::rights{'appname012':
    path       => 'D:\mycompany\appname01',
    user       => 'yourdomain\daebuilduser',
    rights     => 'FullControl',
    permission => 'Allow',
    require => File['D:\mycompany\appname01']
  }
  
  sharefolder::create{'mycompanyServices':
    sharename => 'mycompanyServices',
    path => 'D:\mycompany\Services',
    user => 'yourdomain\daebuilduser',
    rights => 'Full',
    require => Folderpermission::Rights['Services']
  }
  
  sharefolder::create{'appname01':
    sharename => 'appname01',
    path => 'D:\mycompany\appname01',
    user => 'yourdomain\daebuilduser',
    rights => 'Full',
    require => Folderpermission::Rights['appname01']
  }

  exec { "Grant LogonAsService to ${userservice}":
    command => "powershell.exe -ExecutionPolicy ByPass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\Add-Account-To-LogonAsService.ps1 ${userservice}",
    onlyif  => "powershell.exe -ExecutionPolicy ByPass -File \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\check-logonasservice.ps1 ${userservice}",
  }

}