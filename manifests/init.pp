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
  String $csync_group          = $::lsync_csync2::params::csync_group,
  Array $csync_dir             = $::lsync_csync2::params::csync_dir,
  String $csync2_ssl_key       = $::lsync_csync2::params::csync2_ssl_key,
  String $csync2_ssl_cert      = $::lsync_csync2::params::csync2_ssl_cert,
  String $csync2_preshared_key = $::lsync_csync2::params::csync2_preshared_key,
  Array $csync_pkgs            = $::lsync_csync2::params::csync_pkgs,
  Array $nodes_hosts           = $::lsync_csync2::params::nodes_hosts,
  Array $nodes_ip4             = $::lsync_csync2::params::nodes_ip4,
  Array $nodes_ip6             = $::lsync_csync2::params::nodes_ip6
  ) inherits lsync_csync2::params {

  class { 'lsync_csync2::service':
    nodes_ip4 => $nodes_ip4,
    nodes_ip6 => $nodes_ip6;
  }

  class { 'lsync_csync2::files':
    csync_group          => $csync_group,
    csync_dir            => $csync_dir,
    csync2_ssl_key       => $csync2_ssl_key,
    csync2_ssl_cert      => $csync2_ssl_cert,
    csync2_preshared_key => $csync2_preshared_key,
    csync_pkgs           => $csync_pkgs,
    nodes_hosts          => $nodes_hosts
  }

  package { $csync_pkgs: ensure => present; }

}
# vim:ts=2:sw=2
