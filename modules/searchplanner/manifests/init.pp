class searchplanner () {
  require iiswebserver::iissetup
  require appfabricclient
  
  include searchplanner::setup
  include searchplanner::config
  
}
