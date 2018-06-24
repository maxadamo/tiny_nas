# == Define: tiny_nas::client
#
define tiny_nas::client (
  $mount_point        = $name,
  $nfs_server_enabled = false,
  $manage_firewall    = true,
  $ipv6_enabled       = true
) {

  if any2bool($manage_firewall) == true {
    unless defined(Class['::tiny_nas::client::firewall']) {
      class { '::tiny_nas::client::firewall':
        ipv6_enabled => $ipv6_enabled;
      }
    }
  }

  $stripped_mount_point = regsubst($mount_point, '/', '_', 'G')
  $script_name = "/usr/loca/sbin/fix_stale_mount_${stripped_mount_point}.sh"

  tiny_nas::client::client { $mount_point:
    stripped_mount_point => $stripped_mount_point,
    script_name          => $script_name,
    nfs_server_enabled   => $nfs_server_enabled,
  }

}
