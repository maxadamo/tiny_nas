# Class: tiny_nas::client::client
#
#
class tiny_nas::client::client (
  $nfs_server_enabled = false,
  $manage_firewall    = true,
  $ipv6_enabled       = true
) {

  if any2bool($manage_firewall) == true {
    class { '::tiny_nas::client::firewall':
      ipv6_enabled => $ipv6_enabled;
    }
  }

  unless defined(Class['::nfs']) {
    class { '::nfs':
      server_enabled => $nfs_server_enabled,
      client_enabled => true;
    }
  }

}
