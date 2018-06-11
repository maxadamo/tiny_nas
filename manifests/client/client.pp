# Class: tiny_nas::client::client
#
#
class tiny_nas::client::client (
  $nfs_server_enabled = false
) {

  include ::tiny_nas::client::firewall

  unless defined(Class['::nfs']) {
    class { '::nfs':
      server_enabled => $nfs_server_enabled,
      client_enabled => true;
    }
  }

}
