# == Class: lsyncd_csync2::params
#
# (see file init.pp for variables explanation )
#
class lsyncd_csync2::params {

  $use_lsyncd = true
  $vip_ip4 = []
  $vip_ip6 = undef
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
  $csync_packages = $::osfamily ? {
    'Debian' => ['libsqlite3-0', 'csync2'],
    'RedHat' => ['sqlite', 'csync2']
  }

}
