# == Class: lsync_csync2::params
#
# (see file init.pp for variables explanation )
#
class lsync_csync2::params {

  $nodes_ip4 = []
  $nodes_ip6 = []
  $node_hostname = []
  $sync_group = 'main'
  $sync_dir = []
  $sync_exclude = ['*.swp', '*~', '.*', '*.log', '*.pid']
  $csync2_ssl_key = undef
  $csync2_ssl_cert = undef
  $csync2_preshared_key = undef
  $lsyncd_packages = ['lsyncd']
  $csync_packages = ['sqlite', 'csync2']

}
