class perlwindows()
{


$apSourceold = "\\\\csilfs01\\Apps\\DAE-Installs\\ActivePerl\\ActivePerl-5.16.1.1601-MSWin32-x86-296175.msi"
$apSourceNew = "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\ActivePerl\\ActivePerl-5.16.3.1603-MSWin32-x86-296746.msi"
$lastversionperl = "ActivePerl 5.16.3 Build 1603"

$modules = hiera_array('perlmodules')
$all_modules = split(inline_template("<%= (modules).join(',') %>"),',')

perlwindows::addmodule{$all_modules:
	require => Package["ActivePerl 5.16.3 Build 1603"]
  }

if $lastversionperl != $perlversion 
{
  exec { "Uninstalling old perl's version":
    command => "msiexec.exe /x $apSourceold /qn /norestart",
  }
} elsif $perlversion == 'noperl' 
{
	notify {$perlversion:}
}
  
package {"ActivePerl 5.16.3 Build 1603":
  source => "${apSourceNew}",
  install_options => {
    "ADDLOCAL"    => "PERL_FEATURE,PERLIS,PERLSE,PPM",
    "TARGETDIR"   => "C:\\",
    "PERL_PATH"   => "Yes",
    "PERL_EXT"    => "Yes",
    "PL_IISMAP"   => "Yes",
    "PLEX_IISMAP" => "Yes",
    "PLX_IISMAP"  => "Yes",
  },
}  

}
