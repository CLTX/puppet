class acda () {

	require iiswebserver::iissetup
	include acda::amt-config
  include acda::appname03admin-config
  include acda::comcom-config
  include acda::lp2-config
}
