# == Class: tiny_nas::files
#
class tiny_nas::files (
  $nfs_server_config,
  $use_lsyncd,
  $nodes_hostnames,
  $sync_dir,
  $csync2_ssl_key,
  $csync2_ssl_cert,
  $csync2_preshared_key,
  $nas_root         = $::tiny_nas::params::nas_root,
  $sync_exclude     = $::tiny_nas::params::sync_exclude,
  $csync_packages   = $::tiny_nas::params::csync_packages,
  $lsyncd_packages  = $::tiny_nas::params::lsyncd_packages,
  $lsyncd_conf_dir  = $::tiny_nas::params::lsyncd_conf_dir,
  $lsyncd_conf      = $::tiny_nas::params::lsyncd_conf,
  $cron_sync_minute = $::tiny_nas::params::cron_sync_minute,
) inherits tiny_nas::params {

  if any2bool($use_lsyncd) == true {
    $all_packages = concat($csync_packages, $lsyncd_packages)
    $lsyncd_conf_status = file
  } else {
    $all_packages = $csync_packages
    $lsyncd_conf_status = absent
  }

  $sync_dir_array = keys($sync_dir)
  $filtered_syncd_dir_array = $sync_dir.keys.filter | $sync_item | {
    $sync_dir.dig($sync_item, 'dir_watch').any2bool
  }
  $unfiltered_syncd_dir_array = $sync_dir.keys.filter | $sync_item | {
    ! $sync_dir.dig($sync_item, 'dir_watch').any2bool
  }

  if ! empty($unfiltered_syncd_dir_array) {
    $nas_async = true
    file { '/etc/csync2_nasasync.cfg':
      ensure  => file,
      owner   => root,
      group   => root,
      require => Package[$all_packages],
      before  => Xinetd::Service['csync2'],
      content => template("${module_name}/csync2async.cfg.erb");
    }
    cron { 'csync2_async':
      command => 'pgrep -f lsyncd >/dev/null && /usr/sbin/csync2 -C nasasync -x',
      user    => 'root',
      minute  => $cron_sync_minute;
    }
  } else {
    $nas_async = false
    file { '/etc/csync2_nasasync.cfg': ensure  => absent; }
  }

    cron { 'ensure_lscynd_status':
      command => '/etc/keepalived/check-lsyncd.sh',
      user    => 'root';
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
      content => epp("${module_name}/lsyncd.conf.epp", {
        filtered_syncd_dir_array => $filtered_syncd_dir_array,
        nas_root                 => $nas_root
      });
    '/etc/csync2_nas.cfg':
      content => template("${module_name}/csync2.cfg.erb");
    '/etc/csync2_nas-group.key':
      mode    => '0640',
      content => $csync2_preshared_key;
    '/etc/csync2_ssl_cert.pem':
      content => $csync2_ssl_cert;
    '/etc/csync2_ssl_key.pem':
      mode    => '0640',
      content => $csync2_ssl_key;
    '/etc/logrotate.d/lsync':
      mode   => '0644',
      source => "puppet:///modules/${module_name}/logrotate_lsync";
    [
      '/var/log/csync2', '/var/log/csync2/sync-conflicts',
      '/var/log/lsyncd', $lsyncd_conf_dir
    ]:
      ensure => directory;
    '/etc/keepalived/keepalived-down.sh':
      mode    => '0755',
      require => Class['keepalived'],
      content => epp("${module_name}/keepalived-down.sh.epp", {
        nas_async => $nas_async
      });
    '/etc/keepalived/keepalived-up.sh':
      mode    => '0755',
      require => Class['keepalived'],
      source  => "puppet:///modules/${module_name}/keepalived-up.sh";
    '/etc/keepalived/check-lsyncd.sh':
      mode    => '0755',
      require => Class['keepalived'],
      source  => "puppet:///modules/${module_name}/check-lsyncd.sh";
    $nfs_server_config:
      source => "puppet:///modules/${module_name}/${nfs_server_config}";
  }

  # work-around for centos 7
  exec { 'create_sqlite_link':
    command => 'ln -sf /usr/lib64/libsqlite3.so.0.8.6 /usr/lib64/libsqlite3.so',
    path    => '/usr/bin:/usr/sbin:/bin',
    creates => '/usr/lib64/libsqlite3.so',
    onlyif  => 'test -f /usr/lib64/libsqlite3.so.0.8.6';
  }

  $service_name = $facts['osfamily'] ? {
    'Debian' => 'nfs-kernel-server',
    'RedHat' => 'nfs-server'
  }

  $sync_dir_array.each | String $sync_directory | {
    exec { "create_sync_dir_${sync_directory}":
      command => "install -d ${nas_root}/${sync_directory}",
      path    => '/usr/bin:/usr/sbin:/bin',
      creates => "${nas_root}/${sync_directory}",
      notify  => Service[$service_name];
    }
  }

  if $facts['osfamily'] == 'Debian' {
    file { '/etc/modprobe.d/options.conf': ensure => file; }
    -> file_line { 'modprobe_options':
      ensure  => present,
      line    => 'options lockd nlm_udpport=4045 nlm_tcpport=4045',
      path    => '/etc/modprobe.d/options.conf',
      match   => '.*lockd',
      replace => true;
    }
  }

}
# vim:ts=2:sw=2
