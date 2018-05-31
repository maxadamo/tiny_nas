# == Class: tiny_nas::params
#
# (see file init.pp for variables explanation )
#
class tiny_nas::params {

  $use_lsyncd = true
  $vip_ip4 = undef
  $vip_ip4_subnet = undef
  $vip_ip6 = undef
  $vip_ip6_subnet = unde
  $nodes_ip4 = []
  $nodes_ip6 = []
  $nodes_hostnames = []
  $network_interface = 'eth0'
  $sync_group = 'main'
  $nas_root = '/nas'
  $manage_lvm = undef
  $lv_size = undef
  $vg_name = undef
  $sync_dir = {}
  $sync_exclude = ['*.swp', '*~', '.*', '*.log', '*.pid']
  $csync2_ssl_key = undef
  $csync2_ssl_cert = undef
  $csync2_preshared_key = undef
  $lsyncd_packages = ['lsyncd']
  $lsyncd_conf = $::osfamily ? {
    'Debian' => 'lsyncd.conf.lua',
    'RedHat' => 'lsyncd.conf'
  }
  $lsyncd_conf_dir = $::osfamily ? {
    'Debian' => '/etc/lsyncd',
    'RedHat' => '/etc/'
  }
  $csync_packages = $::osfamily ? {
    'Debian' => ['libsqlite3-0', 'csync2', 'psmisc'],
    'RedHat' => ['sqlite', 'csync2']
  }
  $cron_sync_minute = '*/3'

  $nfs_server_config = $::osfamily ? {
    'Debian' => '/etc/default/nfs-kernel-server',
    'RedHat' => '/etc/sysconfig/nfs'
  }

}
# vim:ts=2:sw=2
