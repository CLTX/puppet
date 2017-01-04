define appcmd::expirewebcontent (
  $timeStamp = '180.00:00:00',
  $status = 'UseMaxAge',
  ){

include appcmd

exec { "expirewebcontent ${timeStamp}":
  command => "appcmd.exe set CONFIG /section:staticContent /clientCache.cacheControlMode:${status} /clientCache.cacheControlMaxAge:${timeStamp}\"",
  unless  => "cmd.exe /c appcmd.exe list CONFIG /section:staticContent | find.exe \"clientCache cacheControlMode=\" | find.exe \"${status}\"",
  }
}

