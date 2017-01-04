class tortoisesvn () {

  package {"TortoiseSVN 1.8.4.24972 (64 bit)":
    source => "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\TortoiseSVN\\TortoiseSVN-1.8.4.24972-x64-svn-1.8.5.msi",
	install_options => {
	  "ADDLOCAL"    => 'ALL',
    },
  }
}