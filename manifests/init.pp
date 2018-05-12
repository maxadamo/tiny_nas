# == Class: lsync_csync2
#
# Setup remote directory synchronization with Lscynd and Csync2
#
# == Quick Overview and Examples
#
# (see file README.md )
#
# === Parameters & Variables
#
# [*nodes_ip4*] <Array>
#   default: empty (list of servers IPv4). Mandatory.
#
# [*nodes_ip6*] <Array>
#   default: empty (list of servers IPv6). Mandatory.
#
# [*nodes_hostname*] <Array>
#   default: empty (list of servers hostnames). Mandatory.
#
# [*sync_group*] <String>
#   default: 'main' (name for the synchronizazion group). Optional.
#
# [*sync_dir*] <Array>
#   default: empty (list of directories to synchronize and watch). Mandatory.
#
# [*sync_exclude*] <Array>
#   default: ['*.swp', '*~', '.*', '*.log', '*.pid']
#            (list of directories to exclude from synchronization). Optional.
#
# [*csync2_ssl_key*] <String>
#   default: undef
#            (ssl key: it can be the content of the key as a variable or
#            something like template('mymodule/ssl_key'.
#            see file README.md to learn how to generate one). Mandatory.
#
# [*csync2_ssl_cert*] <String>
#   default: undef (ssl cert: similar to csync2_ssl_key). Mandatory.
#
# [*csync2_preshared_key*] <String>
#   default: undef (ssl cert: similar to csync2_ssl_key). Mandatory.
#
# [*csync_packages*] <Array>
#   default: ['sqlite', 'csync2', 'lsyncd'] 
#            (csync_packages: packages to install). Optional
#
class lsync_csync2 (
  String $sync_group           = $::lsync_csync2::params::sync_group,
  Array $sync_dir              = $::lsync_csync2::params::sync_dir,
  Array $sync_exclude          = $::lsync_csync2::params::sync_exclude,
  String $csync2_ssl_key       = $::lsync_csync2::params::csync2_ssl_key,
  String $csync2_ssl_cert      = $::lsync_csync2::params::csync2_ssl_cert,
  String $csync2_preshared_key = $::lsync_csync2::params::csync2_preshared_key,
  Array $csync_packages        = $::lsync_csync2::params::csync_packages,
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
  } elsif empty($nodes_ip6) {
    fail('please provide values for the array $nodes_ip6')
  } elsif empty($sync_dir) {
    fail('please provide values for the array $sync_dir')
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
      csync_packages       => $csync_packages,
      nodes_hostname       => $nodes_hostname
  }

  $csync_packages.each | String $csync_package | {
    unless defined(Package[$csync_package]) {
      package { $csync_package:
        ensure => installed;
      }
    }
  }

}
# vim:ts=2:sw=2
