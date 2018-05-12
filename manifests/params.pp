# == Class: lsync_csync2::params
#
class lsync_csync2::params {

  $nodes_ip4 = [] # an array of IP4, mandatory
  $nodes_ip6 = [] # an array of ipv6
  $node_hostname = [] # an array of hostnames, mandatory
  $sync_group = 'sync_group'
  $sync_dir = ['/sync1', '/sync2']
  $sync_exclude = ['*~', '.*', '*.log', '*.pid']
  $csync2_ssl_key = lookup('csync2_ssl_key')
  $csync2_ssl_cert = lookup('csync2_ssl_cert')
  $csync2_preshared_key = lookup('csync2_preshared_key')
  $csync_pkgs = ['sqlite', 'csync2', 'lsyncd']

}
