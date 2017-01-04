class appname04 () {
  require iiswebserver::iissetup
  require appfabricclient
  
  include appname04::setup
  include appname04::appname04config
  include appname04::apiconfig
  include appname04::imagesconfig
  include appname04::internalapiconfig
  include appname04::mysearchconfig
  include appname04::apitestconfig
}
