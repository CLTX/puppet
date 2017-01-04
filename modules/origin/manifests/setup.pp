class origin::setup () {

include registry
require isapi
require appfabricclient
require iiswebserver
require iiswebserver::iissetup

file {'d:\\css-sessions':
  ensure  => appname03ory,
  require => File['D:\\mycompany\\webpub']
  }

file {'d:\\css-sessions\\attempts':
  ensure  => appname03ory,
  require => File['d:\\css-sessions']
  }

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
