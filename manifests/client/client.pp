# Class: tiny_nas::client::client
#
#
class tiny_nas::client::client {

  include ::tiny_nas::client::firewall

  unless defined(Class['::nfs']) {
    class { '::nfs':
      server_enabled => false,
      client_enabled => true,
    }
  }

}



