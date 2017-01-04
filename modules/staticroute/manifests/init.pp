class staticroute () {

file { 'C:\\staticroute':
	ensure => appname03ory
}

file {'C:\\staticroute\\staticroute.bat':
	ensure  => file,
	content => template("staticroute/staticroute.bat"),
	require => File['C:\\staticroute']
}

exec { 'StaticRouteTask':
	command => "cmd.exe /C schtasks /create /tn \"SetStaticRoutes2k8\" /xml \"\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\staticroutes\\SetStaticRoutesWin2k8.xml\"",
	unless  => "cmd.exe /c \"schtasks /Query /tn \"SetStaticRoutes2k8\" /xml | find.exe \"2011-08-25T14:20:57.7124998\"\"",
	require => File['C:\\staticroute\\staticroute.bat']
}

}
