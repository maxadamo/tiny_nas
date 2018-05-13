# == Class: lsyncd_csync2::files
#
class lsyncd_csync2::files (
  $use_lsyncd,
  $nodes_hostname,
  $sync_dir,
  $csync2_ssl_key,
  $csync2_ssl_cert,
  $csync2_preshared_key,
  $sync_exclude    = $::lsyncd_csync2::params::sync_exclude,
  $csync_packages  = $::lsyncd_csync2::params::csync_packages,
  $lsyncd_packages = $::lsyncd_csync2::params::lsyncd_packages,
  $sync_group      = $::lsyncd_csync2::params::sync_group,
  ) inherits lsyncd_csync2::params {

  if any2bool($use_lsyncd) == true {
    $all_packages = concat($csync_packages, $lsyncd_packages)
    $lsyncd_conf = file
  } else {
    $all_packages = $csync_packages
    $lsyncd_conf = absent
  }

  file {
    default:
      ensure  => file,
      owner   => root,
      group   => root,
      require => Package[$all_packages],
      before  => Xinetd::Service['csync2'];
    '/etc/lsyncd.conf':
      ensure  => $lsyncd_conf,
      notify  => Service['lsyncd'],
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
    ['/var/log/csync2', '/var/log/csync2/sync-conflicts']:
      ensure => directory;
  }

  # work-around for centos 7
  exec {
    default:
      path    => '/usr/bin:/usr/sbin:/bin';
    'create_sqlite_link':
      command => 'ln -sf /usr/lib64/libsqlite3.so.0.8.6 /usr/lib64/libsqlite3.so',
      creates => '/usr/lib64/libsqlite3.so',
      onlyif  => 'test -f /usr/lib64/libsqlite3.so.0.8.6';
    'create_sync_dir':
      command => "install -d ${sync_dir}",
      creates => $sync_dir;
  }

}
# vim:ts=2:sw=2
