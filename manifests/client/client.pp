# == Define: tiny_nas::client::client
#
define tiny_nas::client::client (
  $mount_point        = $name,
  $nfs_server_enabled = false,
  $manage_firewall    = true,
  $ipv6_enabled       = true
) {

  unless ($mount_point) {
    fail('please add a value for $mount_point')
  }

  $stripped_mount_point = regsubst($mount_point, '/', '_', 'G')
  $script_name = "/usr/loca/sbin/fix_stale_mount_${stripped_mount_point}.sh"

  file { $script_name:
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0754',
    conten => template("${module_name}/fix_stale_mount.sh.erb");
  }

  cron { $stripped_mount_point:
    command => $script_name,
    user    => 'root',
  }

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
