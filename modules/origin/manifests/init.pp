class origin () {

	require iiswebserver::iissetup
	include origin::my-config
  include origin::my-delivery
}
