class acda::machineconfig () {
if $machine_env == 'PRD' {
  file { 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Config\machine.config':
    ensure => 'file',
    content => template('acda/csapi/prod/machine.config')
  }
} else {
    file { 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Config\machine.config':
      ensure => 'file',
      content => template('acda/csapi/non-prd/machine.config')
    }
}
}

