class machineconfig () {
	$env = $machine_env
	$vm = $hostname
		
	if $vm == "pvusaPDW01"  or $vm == "pvusaPDW02" {
        file { 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\CONFIG\machine.config':
          ensure  => 'file',
          content => template('machineconfig/production/appname03-machine.config')
		}
		
        file { 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\CONFIG\machine.config':
          ensure  => 'file',
          content => template('machineconfig/production/appname03-machine.config')
		}
		
	} elsif  $vm == "pvusaDAA01" {
        file { 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\CONFIG\machine.config':
           ensure  => 'file',
           content => template('machineconfig/nonprod/appname01-machine.config')
          }
        file { 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\CONFIG\machine.config':
           ensure  => 'file',
           content => template('machineconfig/nonprod/appname01-machine.config')
          }
		  
	} elsif  "pvusaPAA" in $vm or $vm == "pvusaPAX01" or $vm == "pvusaPAX02" {
	
        file { 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\CONFIG\machine.config':
           ensure  => 'file',
           content => template('machineconfig/production/appname01-machine.config')
          }
        
		file { 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\CONFIG\machine.config':
           ensure  => 'file',
           content => template('machineconfig/production/appname01-machine.config')
          }
  } elsif $machine_role == "Build" and $env == "PRD" {
	
	    file { 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\CONFIG\machine.config':
           ensure  => 'file',
           content => template('machineconfig/production/build-machine.v4.config')
        }
        
		file { 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\CONFIG\machine.config':
           ensure  => 'file',
           content => template('machineconfig/production/build-machine.v4.config')
        }
		
		file { 'C:\Windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\machine.config':
           ensure  => 'file',
           content => template('machineconfig/production/build-machine.v2.x86.config')
        }
		
		file { 'C:\Windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\machine.config':
           ensure  => 'file',
           content => template('machineconfig/production/build-machine.v2.x64.config')
        }
	
	} elsif $machine_role == "Build" and $env != "PRD"  {
		file { 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\CONFIG\machine.config':
          ensure  => 'file',
          content => template('machineconfig/nonprod/build-machine.v4.config')
        }
        
		file { 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\CONFIG\machine.config':
          ensure  => 'file',
          content => template('machineconfig/nonprod/build-machine.v4.config')
        }
		
		file { 'C:\Windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\machine.config':
          ensure  => 'file',
          content => template('machineconfig/nonprod/build-machine.v2.x86.config')
        }
		
		file { 'C:\Windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\machine.config':
          ensure  => 'file',
          content => template('machineconfig/nonprod/build-machine.v2.x64.config')
        }
		
	} else { 
		case $env {
		"PRD" : {
			file { 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\CONFIG\machine.config':
				ensure  => 'file',
				content => template('machineconfig/production/machine.config')
			}
			
			file { 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\CONFIG\machine.config':
				ensure  => 'file',
				content => template('machineconfig/production/machine.config')
			}
		}
		default: {
			file { 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\CONFIG\machine.config':
				ensure  => 'file',
				content => template('machineconfig/nonprod/machine.config')
			}
			
			file { 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\CONFIG\machine.config':
				ensure  => 'file',
				content => template('machineconfig/nonprod/machine.config')
			}
		}
	}
	}
}
