class sharefolder()
{
$cmdPath = 'C:\Windows\System32\cmd.exe'

file { "${cmdPath}":
    ensure => present
} -> Sharefolder::Create<| |>

}
