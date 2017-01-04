class sso-web()
{
  require iiswebserver::iissetup
  include sso-web::config
}
