class nagios_devops::hostheader () {

require nagios_devops::setup
include nagios_devops::drives

$variable01 = $nagios_devops::setup::variableerb
$variable02 = $nagios_devops::setup::no_template

if ( "pvusaPLW" in $hostname ) or ( "pvusaPAR0" in $hostname ) or ( $hostname =="pvusaPPX20" ) or ( $hostname =="pvusaPPX21" )or ( $hostname =="pvusaPPX22" ) or ( $hostname =="pvusaPPX23" ) {
    notify {"no adding hostheaders":}
} else {
  if ($variable01 != $variable02) or ($variable01 =="pvusapmx01.erb") or ($variable01 =="pvusapmw01.erb") or ($variable01 !="pvusatpw15.erb") {
    if $machine_role == "Web" or $machine_role == "Client - Web APIs" {
      exec { "Adding hostheader to Nagios Template":
        command => "powershell.exe -executionpolicy bypass \\\\yourdomain.mycompany.com\\PDFS\\Shares\\team01\\DevOps\\Scripts\\powershell\\hostheader2.ps1",
        before  => Exec["Adding drives to Nagios Template"]
      }
    }
  }
}
}
