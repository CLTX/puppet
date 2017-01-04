class appname05::setup () {
include registry
require isapi
require appfabricclient
require iiswebserver
require iiswebserver::iissetup

file {'D:\\mycompany\\webpub\\conf':
  ensure  => appname03ory,
  require => File['D:\\mycompany\\webpub']
  }

# if css file doesn't exist create an empty one, else, do nothing.
file {'D:\\mycompany\\webpub\\conf\\css.conf':
  ensure   => present,
  checksum => none,
  require  => File['D:\\mycompany\\webpub\\conf'],
  }

# delete Default Web Site
appcmd::deletesite { 'DeleteSite':
  siteName => 'Default Web Site'
  }
}
