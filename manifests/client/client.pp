# == Define: tiny_nas::client::client
#
define tiny_nas::client::client (
  $nfs_server_enabled,
  $stripped_mount_point,
  $options_nfs,
  $script_name,
  $server,
  $share,
  $mount_point = $name,
) {

  if $caller_module_name != $module_name {
    fail("this define is intended to be called only within ${module_name}")
  }

  file { $script_name:
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0754',
    content => template("${module_name}/fix_stale_mount.sh.erb");
  }

  cron { $stripped_mount_point:
    command => "flock /tmp/fix_stale_mount.lock ${script_name}",
    user    => 'root',
  }

  unless defined(Class['::nfs']) {
    class { '::nfs':
      server_enabled => $nfs_server_enabled,
      client_enabled => true;
    }
  }

  nfs::client::mount { $mount_point:
    ensure      => mounted,
    server      => $server,
    share       => $share,
    options_nfs => $options_nfs,
    require     => Class['::nfs'];
  }

}
