class powershell::psremote () {

if $psremoting_enabled == "False" {
    exec { 'enable PSremote':
       command => "cmd.exe /C \"powershell -Command \"Enable-PSRemoting -Force\"\"",
     }
  }  

if $ps_executionpolicy != "Unrestricted" {
    exec { 'Set Execution Policy to Unrestricted':
       command => "cmd.exe /C \"powershell -Command \"Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Confirm:\$false -Force\"\"",
    }
  }
}