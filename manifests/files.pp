# == Class: lsyncd_csync2::files
#
class lsyncd_csync2::files (
  $use_lsyncd,
  $nodes_hostnames,
  $sync_dir,
  $csync2_ssl_key,
  $csync2_ssl_cert,
  $csync2_preshared_key,
  $sync_exclude    = $::lsyncd_csync2::params::sync_exclude,
  $csync_packages  = $::lsyncd_csync2::params::csync_packages,
  $lsyncd_packages = $::lsyncd_csync2::params::lsyncd_packages,
  $lsyncd_conf_dir = $::lsyncd_csync2::params::lsyncd_conf_dir,
  $lsyncd_conf     = $::lsyncd_csync2::params::lsyncd_conf,
  $sync_group      = $::lsyncd_csync2::params::sync_group,
  ) inherits lsyncd_csync2::params {

  if any2bool($use_lsyncd) == true {
    $all_packages = concat($csync_packages, $lsyncd_packages)
    $lsyncd_conf_status = file
  } else {
    $all_packages = $csync_packages
    $lsyncd_conf_status = absent
  }

  $sync_dir_array = keys($sync_dir)
  $lsyncd_dir_array = $sync_dir_array
  $sync_dir_array.each | String $sync_item | {
    if $sync_dir[$sync_item][watch_dir] == 'false' {
      notify { "notify ${sync_dir[$sync_item][watch_dir]}":
        message => "notify ${sync_dir[$sync_item][watch_dir]}";
      }
      delete($lsyncd_dir_array, $sync_item)
    }
  }

  file {
    default:
      ensure  => file,
      owner   => root,
      group   => root,
      require => Package[$all_packages],
      before  => Xinetd::Service['csync2'];
    "${lsyncd_conf_dir}/${lsyncd_conf}":
      ensure  => $lsyncd_conf_status,
      notify  => Service['lsyncd'],
      require => File[$lsyncd_conf_dir],
      content => template("${module_name}/lsyncd.conf.erb");
    "/etc/csync2_${sync_group}.cfg":
      content => template("${module_name}/csync2.cfg.erb");
    "/etc/csync2_${sync_group}-group.key":
      mode    => '0640',
      content => $csync2_preshared_key;
    '/etc/csync2_ssl_cert.pem':
      content => $csync2_ssl_cert;
    '/etc/csync2_ssl_key.pem':
      mode    => '0640',
      content => $csync2_ssl_key;
    [
      '/var/log/csync2', '/var/log/csync2/sync-conflicts',
      '/var/log/lsyncd', $lsyncd_conf_dir
    ]:
      ensure => directory;
    '/etc/keepalived/nfs_check.sh':
      mode    => '0755',
      require => Class['keepalived'],
      content => template("${module_name}/nfs_check.sh.erb");
    '/etc/keepalived/keepalived-down.sh':
      mode    => '0755',
      require => Class['keepalived'],
      source  => "puppet:///modules/${module_name}/keepalived-down.sh";
    '/etc/keepalived/keepalived-up.sh':
      mode    => '0755',
      require => Class['keepalived'],
      source  => "puppet:///modules/${module_name}/keepalived-up.sh";
  }

  # work-around for centos 7
  exec { 'create_sqlite_link':
    command => 'ln -sf /usr/lib64/libsqlite3.so.0.8.6 /usr/lib64/libsqlite3.so',
    path    => '/usr/bin:/usr/sbin:/bin',
    creates => '/usr/lib64/libsqlite3.so',
    onlyif  => 'test -f /usr/lib64/libsqlite3.so.0.8.6';
  }

  $sync_dir_array.each | String $sync_directory | {
    exec { "create_sync_dir_${sync_directory}":
      command => "install -d ${sync_directory}",
      path    => '/usr/bin:/usr/sbin:/bin',
      creates => $sync_directory;
    }
  }

}
# vim:ts=2:sw=2
