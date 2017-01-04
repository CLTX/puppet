class mdbaccess()
{

$PathMDBAccess = "C:\\Program Files\\Microsoft mydomain\\mydomain14\\1033\\STSLISTI.DLL"

exec{'install Microsoft Database Access 2010':
	command => "cmd.exe /c \"\"\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\mydomain Access\\AccessDatabaseEngine_x64.exe\" /quiet /norestart\"",
	onlyif => "cmd.exe /c if exist \"${PathMDBAccess}\" (EXIT /B 1) ELSE (EXIT /B 0)",
	}
}
