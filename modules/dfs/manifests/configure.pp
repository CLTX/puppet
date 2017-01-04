class dfs::configure()
{

include dfs
require dfs::deploying_dfs
require dfs::registry_keys


	exec 	{ 
		"Install KB2663685":
			command => "wusa.exe \\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\DFS\\DFS-automatic_recovery_Hotfix(KB2663685).msu /quiet",
      unless => "cmd.exe /c \"powershell.exe -command (Get-HotFix) | find.exe \"KB2663685\"\""
			}
}
