class pythonwindows()
{

$apSourceNew = "\\\\yourdomain.mycompany.com\\installers\\Shared-Apps\\Phyton\\python-2.7.6.amd64.msi"
  
package {"Python 2.7.6 (64-bit)":
  source => "${apSourceNew}",
  install_options => {
    "TARGETDIR"   => "D:\\python",
  },
}  

}
