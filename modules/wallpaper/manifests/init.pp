class wallpaper () {
	$env = $machine_env

    case $env {
		PRD : {
			    file { 'C:\BGInfo\bginfo.bgi':
				  ensure  => 'file',
				  source  => "puppet:///modules/wallpaper/bginfo.prd.bgi",
				
			    }
		      }
		STAG : {
			    file { 'C:\BGInfo\bginfo.bgi':
				  ensure  => 'file',
				  source  => "puppet:///modules/wallpaper/bginfo.stg.bgi",
			    }
		      }
		TST : {
		       file { 'C:\BGInfo\bginfo.bgi':
			     ensure  => 'file',
				 source  => "puppet:///modules/wallpaper/bginfo.tst.bgi",
			   }
		      }
		INT : {
                file { 'C:\BGInfo\bginfo.bgi':
				  ensure  => 'file',
				  source  => "puppet:///modules/wallpaper/bginfo.dev.bgi",
			     }
		       }
		default: {
			   file { 'C:\BGInfo\bginfo.bgi':
				 ensure  => 'file',
				 source  => "puppet:///modules/wallpaper/bginfo.noenv.bgi",
			   }
		    }
	}

}


