class rmadminpath()
{
$rmadminpath = '\\yourdomain.mycompany.com\PDFS\Shares\team01\DevOps\Scripts\rmadmin'

 windows_env { 'Add rmadmin to Path':
  variable  => 'PATH',
  value     => "${rmadminpath}",
  mergemode => insert,
}
}