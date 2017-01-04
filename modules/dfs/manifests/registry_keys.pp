class dfs::registry_keys()
{

include dfs
require dfs::deploying_dfs

registry_key { 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\DFSR\Parameters\Settings\AsyncIoMaxBufferSizeBytes':
    ensure => present,
}

registry_value { 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\DFSR\Parameters\Settings\AsyncIoMaxBufferSizeBytes':
    ensure => present,
    type   => dword,
    data  => '0x00800000'
}

registry_key { 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\DFSR\Parameters\Settings\RpcFileBufferSize':
    ensure => present,
}

registry_value { 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\DFSR\Parameters\Settings\RpcFileBufferSize':
    ensure => present,
    type   => dword,
    data  => '0x00080000'
}

registry_key { 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\DFSR\Parameters\Settings\StagingThreadCount':
    ensure => present,
}

registry_value { 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\DFSR\Parameters\Settings\StagingThreadCount':
    ensure => present,
    type   => dword,
    data  => '0x00000008'
}

registry_key { 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\DFSR\Parameters\Settings\TotalCreditsMaxCount':
    ensure => present,
}

registry_value { 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\DFSR\Parameters\Settings\TotalCreditsMaxCount':
    ensure => present,
    type   => dword,
    data  => '0x00001000'
}

registry_key { 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\DFSR\Parameters\Settings\UpdateWorkerThreadCount':
    ensure => present,
}

registry_value { 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\DFSR\Parameters\Settings\UpdateWorkerThreadCount':
    ensure => present,
    type   => dword,
    data  => '0x00000020'
}

}
