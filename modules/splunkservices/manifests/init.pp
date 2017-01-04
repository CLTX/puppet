class splunkservices() {

  service { "Splunkd":
    ensure => 'running',
    enable => true,
  }
  
  service { "Splunkweb":
    ensure => 'running',
    enable => true,
  }
}
