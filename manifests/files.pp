# == Class: lsync_csync2::files
#
class lsync_csync2::files (
  String $csync_group          = $::lsync_csync2::params::csync_group,
  String $csync_dir            = $::lsync_csync2::params::csync_dir,
  String $csync2_ssl_key       = $::lsync_csync2::params::csync2_ssl_key,
  String $csync2_ssl_cert      = $::lsync_csync2::params::csync2_ssl_cert,
  String $csync2_preshared_key = $::lsync_csync2::params::csync2_preshared_key,
  Array $csync_pkgs            = $::lsync_csync2::params::csync_pkgs,
  Array $nodes_hosts          = $::lsync_csync2::params::nodes_hosts
  ) inherits lsync_csync2::params {

  file {
    default:
      ensure  => file,
      owner   => root,
      group   => root,
      require => Package[$csync_pkgs];
    '/etc/lsyncd.conf':
      notify  => Service['lsyncd'],
      content => template("${module_name}/lsyncd.conf.erb");
    "/etc/csync2_${csync_group}.cfg":
      content => template("${module_name}/csync2.cfg.erb");
    "/etc/csync2_${csync_group}-group.key":
      mode    => '0640',
      content => $csync2_preshared_key;
    '/etc/csync2_ssl_cert.pem':
      content => $csync2_ssl_cert;
    '/etc/csync2_ssl_key.pem':
      mode    => '0640',
      content => $csync2_ssl_key;
    '/usr/lib64/libsqlite3.so':
      ensure => link,
      target => '/usr/lib64/libsqlite3.so.0.8.6';
    ['/var/log/csync2', '/var/log/csync2/sync-conflicts']:
      ensure => directory;
  }

}
# vim:ts=2:sw=2
