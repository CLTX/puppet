class webconfig () {
  
 if $machine_env == "PRD" {
          case $hostname {
              "pvusaPPW09","pvusaPPW10" : {
                  file { 'D:\mycompany\webpub\my.mycompany.com\wwwroot\web.config':
                    ensure => 'file',
                    content => template('webconfig/prod/my.config'),
                    replace => true,
                    require => File["D:\\mycompany\\webpub\\my.mycompany.com\\wwwroot"]
                  }
              }
          }
 }elsif $machine_env == "TST" {
      case $hostname {
          "pvusaTPW09" : {
                file { 'D:\mycompany\webpub\my.mycompany.com\wwwroot\web.config':
                  ensure => 'file',
                  content => template('webconfig/nonprod/my.config'),
                  replace => true,
                  require => File["D:\\mycompany\\webpub\\my.mycompany.com\\wwwroot"] 
                }
          }
      }
 }elsif $machine_env == "INT" {
      case $hostname {
          "pvusaDPW09": {
            file { 'D:\mycompany\webpub\my.mycompany.com\wwwroot\web.config':
                 ensure => 'file',
                 content => template('webconfig/nonprod/my.config'),
                 replace => true,
                 require => File["D:\\mycompany\\webpub\\my.mycompany.com\\wwwroot"]
            }
          }
      }
  }
}