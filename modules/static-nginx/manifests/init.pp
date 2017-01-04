class static-nginx () {

require iiswebserver::iissetup
include static-nginx::setup
}

