class userwindows()
{
  $netPath = 'C:\Windows\System32\net.exe'
      
  file { "${netPath}":
    ensure => present,
  } #-> Userwindows::Adduser<| |> -> Userwindows::Deluser<| |>

}