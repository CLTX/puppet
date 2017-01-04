class isapi () {
  require iiswebserver::iissetup

  include isapi::files
  include isapi::setup
}
