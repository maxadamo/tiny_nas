# == Class: lsync_csync2::params
#
class lsync_csync2::params {

  $nodes_ip4 = [
    '192.168.0.1', # first IPv4
    '192.168.0.2', # second IPv4
  ]
  $nodes_ip6 = [
    '2001:798:3::56', # first IPv6
    '2001:798:3::54', # second IPv6
  ]
  $node_hostnames = [
    'host01.geant.net',
    'host02.geant.net',
  ]
  $csync_group = 'sync_group'
  $csync_dir = ['/sync1', '/sync2']
  $csync2_ssl_key = lookup('csync2_ssl_key')
  $csync2_ssl_cert = lookup('csync2_ssl_cert')
  $csync2_preshared_key = lookup('csync2_preshared_key')
  $csync_pkgs = ['sqlite', 'csync2', 'lsyncd']

}
