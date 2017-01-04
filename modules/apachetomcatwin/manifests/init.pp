class apachetomcatwin()
{
include java

$tcVersion = '7.0.53'

exec{"Installing Apache TomCat ${tcVersion}":
  command => "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Apache\\Tomcat\\apache-tomcat-7.0.53.exe /S /D=D:\\Apache-Tomcat",
  unless  => "cmd.exe /c \"powershell.exe -Command \"if (test-path \\\"D:\\Apache-Tomcat\\bin\\tomcat7.exe\\\" -erroraction silentlycontinue) { exit 0} else {exit 1}\"\"",
  require => Exec['Install Java JRE']
}

service { "Tomcat7":
  ensure => 'running',
  enable => true,
  require => Exec["Installing Apache TomCat ${tcVersion}"]
}

}