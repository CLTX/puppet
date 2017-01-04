class appname05 () {
  require iiswebserver::iissetup
  include appname05::cpmconfig
  include appname05::adminconfig
  include appname05::appname05siteconfig
  include appname05::stagingarconfig
  include appname05::appname05pollconfig
  include appname05::insightsconfig
  include appname05::clubhouseconfig
  include appname05::clientuploadconfig
  include appname05::qna5config
  include appname05::grocerysurvconfig
  
}