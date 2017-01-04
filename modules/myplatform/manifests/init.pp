class myplatform()
{

$findstrPath = "C:\\windows\\system32\\findstr.exe"

  file { "${findstrPath}":
    ensure => present,
  } -> Myplatform::Install<| |>
}
