# Class: tiny_nas::client::client
#
#
class tiny_nas::client::client (
  $nfs_server_enabled = false,
  $ipv6_enabled       = true
) {

  class { '::tiny_nas::client::firewall':
    ipv6_enabled => $ipv6_enabled;
  }

  unless defined(Class['::nfs']) {
    class { '::nfs':
      server_enabled => $nfs_server_enabled,
      client_enabled => true;
    }
  }

}
