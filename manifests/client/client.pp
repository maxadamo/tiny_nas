# Class: tiny_nas::client::client
#
#
class tiny_nas::client::client {

  include ::tiny_nas::client::firewall

  class { '::nfs':
    server_enabled => false,
    client_enabled => true,
    nfs_v4_client  => false;
  }

}



