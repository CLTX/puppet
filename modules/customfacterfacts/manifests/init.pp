class customfacterfacts()
{

file {'D:\Program Files (x86)\Puppet Labs\Puppet\facter\lib\facter\cachingservice.rb':
        ensure => 'file',
        content => template("/etc/puppet/modules/customfacterfacts/files/cachingservice.rb"),
    }

}