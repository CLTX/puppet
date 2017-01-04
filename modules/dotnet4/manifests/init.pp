class dotnet4()
{

file {'D:\Powershell-Scripts':
  ensure => appname03ory,
}

file {'D:\Powershell-Scripts\Apps':
  ensure => appname03ory,
}

file {'D:\Powershell-Scripts\scripts':
  ensure => appname03ory,
  source  => 'puppet:///modules/dotnet4/scripts',
  recurse => true,
}

file {"D:/Powershell-Scripts/Apps/dotNetFx40_Full_x86_x64.exe":
  source => 'puppet:///modules/dotnet4/dotNetFx40_Full_x86_x64.exe',
}

exec { 'Install-DotNet4':
  command => 'powershell.exe -ExecutionPolicy remotesigned -File D:\\Powershell-Scripts\\scripts\\Install-dotNet4.ps1',
  require => File['D:\Powershell-Scripts\scripts'],
  timeout => 500,
}

}
