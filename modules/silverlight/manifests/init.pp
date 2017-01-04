class silverlight () {

$msiFilePath = "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Microsoft\\SilverLight\\silverlight_sdk.msi"

  package {"Microsoft Silverlight 5 SDK":
    ensure  => present, 
    source  => "${msiFilePath}",
  }

}
