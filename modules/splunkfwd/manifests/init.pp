class splunkfwd () {

$newinstallerfile = '\\yourdomain.mycompany.com\installers\Shared-Apps\Splunk\splunkfwd\splunkforwarder-6.1.3-220630-x64-release.msi'
$deployServer  = 'splunkmaster.mydomain.mycompany.com:8089'
$indexer_server = 'splunkheavyforwarder.mydomain.mycompany.com:9997'

package {"UniversalForwarder":
  ensure          => present, 
  source          => "${newinstallerfile}",
  install_options => {
    "AGREETOLICENSE"    => "Yes",
    "DEPLOYMENT_SERVER" => "${deployServer}",
    "RECEIVING_INDEXER" => "${indexer_server}"
  }
}

service { "SplunkForwarder":
  ensure  => 'running',
  enable  => true,
  require =>  Package["UniversalForwarder"],
  }
 
file {'C:\Program Files\SplunkUniversalForwarder\etc\system\local\deploymentclient.conf':
    ensure  => present,
    owner   => 'Everyone',
    group   => 'Administrators',
    mode    => '0770',
    source  => 'puppet:///modules/splunkfwd/deploymentclient.conf',
    require =>  Package["UniversalForwarder"],
}
  
}
