# == Class: lsync_csync2
#
# == Example
#
# Create certificate:
#
# cd /etc/
# openssl req -x509 -newkey rsa:1024 -days 7200 \
# -keyout /etc/csync2/csync2_ssl_key.pem -nodes \
# -out /etc/csync2/csync2_ssl_cert.pem -subj '/CN=puppet'
# csync2 -k /etc/csync2_puppet-group.key
# chmod 0600 /etc/csync2_puppet-group.key
#
# and store them to hiera or store as templates
#
class lsync_csync2 (
  String $sync_group           = $::lsync_csync2::params::sync_group,
  Array $sync_dir              = $::lsync_csync2::params::sync_dir,
  Array $sync_exclude          = $::lsync_csync2::params::sync_exclude,
  String $csync2_ssl_key       = $::lsync_csync2::params::csync2_ssl_key,
  String $csync2_ssl_cert      = $::lsync_csync2::params::csync2_ssl_cert,
  String $csync2_preshared_key = $::lsync_csync2::params::csync2_preshared_key,
  Array $csync_pkgs            = $::lsync_csync2::params::csync_pkgs,
  Array $nodes_hostname        = $::lsync_csync2::params::nodes_hostname,
  Array $nodes_ip4             = $::lsync_csync2::params::nodes_ip4,
  Array $nodes_ip6             = $::lsync_csync2::params::nodes_ip6
  ) inherits lsync_csync2::params {

  if empty($nodes_hostname) {
    fail('please provide values for the array $nodes_hostname')
  } elsif empty($nodes_ip4) {
    fail('please provide values for the array $nodes_ip4')
  } elsif empty($nodes_ip6) {
    fail('please provide values for the array $nodes_ip6')
  } elsif !($csync2_ssl_key) {
    fail('please provide a value for $csync2_ssl_key')
  } elsif !($csync2_ssl_cert) {
    fail('please provide a value for $csync2_ssl_cert')
  } elsif !($csync2_preshared_key) {
    fail('please provide a value for $csync2_preshared_key')
  }

  class {
    'lsync_csync2::service':
      nodes_ip4 => $nodes_ip4,
      nodes_ip6 => $nodes_ip6;
    'lsync_csync2::files':
      sync_group           => $sync_group,
      sync_dir             => $sync_dir,
      sync_exclude         => $sync_exclude,
      csync2_ssl_key       => $csync2_ssl_key,
      csync2_ssl_cert      => $csync2_ssl_cert,
      csync2_preshared_key => $csync2_preshared_key,
      csync_pkgs           => $csync_pkgs,
      nodes_hostname       => $nodes_hostname
  }

  package { $csync_pkgs: ensure => present; }

}
# vim:ts=2:sw=2
