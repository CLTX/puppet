class nagios_devops::setup () {

include stdlib
$hostname = upcase($hostname)

$variable = downcase($hostname)
$variablecfg = "${variable}.cfg"
$variableerb = "${variable}.erb"

$contact = hiera_hash('contact')
$role = hiera_hash('role')
$application = hiera_hash('application')
$noapply= hiera_hash('noapply')
$contactpd = hiera_hash('contactpd')
$role_template = $role[$machine_role]
$app_template = $application[$machine_app]
$no_template = $noapply[$hostname]
$pagerduty_contact = $contactpd[$machine_app]

if $match_techsql == "1" {
$techsqlpd_template = $techsql_contact 
$contactgroup = "techsqlsupport" 
} else {
$techsqlpd_template = $contactpd[$machine_app]
$contactgroup = $contact[$machine_app]
}

if ( "pvusaPAR0" in $hostname ) 
  {
		file {"\\\\pvusapeds02\\shares\\devops\\nsclient\\servers\\$variablecfg":
          ensure  => absent,
        }
		
		file {"\\\\pvusapeds02\\shares\\devops\\nsclient\\templates\\$variablecfg":
          ensure  => absent,
        }
  } else {
    if 'pvusaPAR' in $hostname {
     file {"\\\\pvusapeds02\\shares\\devops\\nsclient\\servers\\$variablecfg":
          ensure  => 'file',
          content => template('nagios_devops/prod/PAR10_20_30-servers.erb')
       }   
    } elsif $machine_env == "PRD" { 
      if $machine_app == "Unknown" or $machine_role == "Unknown" {
        file {"\\\\pvusapeds02\\shares\\devops\\nsclient\\servers\\$variablecfg":
          ensure  => 'file',
          content => template('nagios_devops/prod/Default.erb')
        }
      } elsif $no_template == $variableerb {
        file {"\\\\pvusapeds02\\shares\\devops\\nsclient\\servers\\$variablecfg":
          ensure  => 'file',  
          content => template("nagios_devops/prod/$no_template")
        }  
      } elsif $machine_app == "appname04" and $machine_role == "Web" {
        file {"\\\\pvusapeds02\\shares\\devops\\nsclient\\servers\\$variablecfg":
          ensure  => 'file',
          content => template('nagios_devops/prod/appname04Web.erb')
        }
      } elsif $machine_app == "PlatfformTeam" {
        file {"\\\\pvusapeds02\\shares\\devops\\nsclient\\servers\\$variablecfg":
          ensure  => 'file',
          content => template('nagios_devops/prod/App_Platform.erb')
        }
     } elsif $machine_app == "team01"  and $machine_role == "Storage" {
        file {"\\\\pvusapeds02\\shares\\devops\\nsclient\\servers\\$variablecfg":
          ensure  => 'file',  
          content => template("nagios_devops/prod/dfs.erb")
        }
      } elsif $no_template != $variableerb and $machine_role != "Application And Services" {
        file {"\\\\pvusapeds02\\shares\\devops\\nsclient\\servers\\$variablecfg":
          ensure  => 'file',  
          content => template("nagios_devops/prod/$role_template")
        }
      } elsif $machine_role == "Application And Services" and $machine_app != nil {
        file {"\\\\pvusapeds02\\shares\\devops\\nsclient\\servers\\$variablecfg":
          ensure  => 'file',
          content => template("nagios_devops/prod/$app_template")
        }
      } else {
        file {"\\\\pvusapeds02\\shares\\devops\\nsclient\\servers\\$variablecfg":
          ensure  => 'file',  
          content => template('nagios_devops/prod/Default.erb')
        }  
      }  	  
    } else {
      if $machine_app == "Unknown" or $machine_role == "Unknown" {
        file {"\\\\pvusapeds02\\shares\\devops\\nsclient\\servers\\$variablecfg":
          ensure  => 'file',
          content => template('nagios_devops/non-prod/Default.erb')
        }
      } elsif $machine_app == "appname04" and $machine_role == "Web" and $variable != "pvusapmw01" {
        file {"\\\\pvusapeds02\\shares\\devops\\nsclient\\servers\\$variablecfg":
          ensure  => 'file',
          content => template('nagios_devops/non-prod/appname04Web.erb')
        }
      } elsif $machine_app == "PlatfformTeam" {
        file {"\\\\pvusapeds02\\shares\\devops\\nsclient\\servers\\$variablecfg":
          ensure  => 'file',
          content => template('nagios_devops/non-prod/App_Platform.erb')
        }
      } elsif $machine_app == "team01"  and $machine_role == "Storage" {
         file {"\\\\pvusapeds02\\shares\\devops\\nsclient\\servers\\$variablecfg":
           ensure  => 'file',
           content => template("nagios_devops/non-prod/dfs.erb")
         }
      } elsif $no_template != $variableerb and $machine_role != "Application And Services" {
         file {"\\\\pvusapeds02\\shares\\devops\\nsclient\\servers\\$variablecfg":
           ensure  => 'file',
           content => template("nagios_devops/non-prod/$role_template")
         }
      } elsif $no_template == $variableerb {
          file {"\\\\pvusapeds02\\shares\\devops\\nsclient\\servers\\$variablecfg":
            ensure  => 'file',
            content => template("nagios_devops/non-prod/$no_template")
          }
      } elsif $machine_role == "Application And Services" and $machine_app != nil {
          file {"\\\\pvusapeds02\\shares\\devops\\nsclient\\servers\\$variablecfg":
            ensure  => 'file',
            content => template("nagios_devops/non-prod/$app_template")
          }
      } else {
          file {"\\\\pvusapeds02\\shares\\devops\\nsclient\\servers\\$variablecfg":
            ensure  => 'file',
            content => template('nagios_devops/non-prod/Default.erb')
          }
      }
    }
  }
}
