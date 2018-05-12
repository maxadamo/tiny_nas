# == Class: lsync_csync2::files
#
class lsync_csync2::files (
  $sync_group           = $::lsync_csync2::params::sync_group,
  $sync_dir             = $::lsync_csync2::params::sync_dir,
  $sync_exclude         = $::lsync_csync2::params::sync_exclude,
  $csync2_ssl_key       = $::lsync_csync2::params::csync2_ssl_key,
  $csync2_ssl_cert      = $::lsync_csync2::params::csync2_ssl_cert,
  $csync2_preshared_key = $::lsync_csync2::params::csync2_preshared_key,
  $csync_pkgs           = $::lsync_csync2::params::csync_pkgs,
  $nodes_hostname       = $::lsync_csync2::params::nodes_hostname
  ) inherits lsync_csync2::params {

  file {
    default:
      ensure  => file,
      owner   => root,
      group   => root,
      require => Package[$csync_pkgs],
      before  => Xinetd::Service['csync2'];
    '/etc/lsyncd.conf':
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
  exec { 'create_sqlite/_link':
    command => 'ln -sf /usr/lib64/libsqlite3.so.0.8.6 /usr/lib64/libsqlite3.so',
    path    => '/usr/bin:/usr/sbin:/bin',
    creates => '/usr/lib64/libsqlite3.so',
    onlyif  => 'test -f /usr/lib64/libsqlite3.so.0.8.6';
  }

}
# vim:ts=2:sw=2
