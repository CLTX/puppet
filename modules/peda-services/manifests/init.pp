class peda-services () {

include automailer
 
$servPath = 'C:\\Windows\\Microsoft.NET\\Framework\\v4.0.30319\\InstallUtil.exe /username=yourdomain\daewebuser /password=yourpassword /unattended D:\\mycompany\\services'

#exec { 'Install-BulkMappingService':
#  command    => "${servPath}\\appname01\\mycompany.appname01.WindowsServices.exe",
#  timeout    => 0,
#  returns    => ['0','255'],
#  provider   => windows,
#  path       => ['C:\\windows'],
#  }

exec { 'Install-AMTool':
  command    => "${servPath}\\AMTool\\mycompany.AMTool.WindowsService.exe",
  timeout    => 0,
  returns    => ['0','255'],
  provider   => windows,
  path       => ['C:\\windows'],
  }

exec { 'Install-Common2':
  command    => "${servPath}\\ComCom\\mycompany.ComCom.WindowsService.exe",
  timeout    => 0,
  returns    => ['0','255'],
  provider   => windows,
  path       => ['C:\\windows'],
  }

service {'AMToolService':
  ensure     => 'running',
  enable     => true,
  }	

#service {'BulkMappingService':
#  ensure     => 'running',
#  enable     => true,
#  }

service {'Common2Service':
  ensure     => 'running',
  enable     => true,
  }

}
