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
  Array $csync_pkgs = $::lsync_csync2::params::csync_pkgs,
  ) inherits lsync_csync2::params {

  include csync2::service
  include csync2::files

  package { $csync_pkgs: ensure => present; }

}
# vim:ts=2:sw=2
