# == Class: lsyncd_csync2
#
# Setup remote directory synchronization with Lscynd and Csync2
#
# == Quick Overview
#
# (see file README.md )
#
# === Parameters & Variables
#
# [*use_lsyncd*] <Bool>
#   default: true (
#            enable/disable directory watching.
#            When disabled csync2 must be triggered manually.
#            ). Optional
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
#   default: undef (
#            ssl key: it can be the content of the key as a variable or
#            something like template('mymodule/ssl_key'.
#            see file README.md to learn how to generate one
#            ). Mandatory.
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
# Examples
# --------
#
# class { 'lsyncd_csync2':
#   sync_group           => 'puppet_ca',
#   sync_dir             => ['/etc/puppetlabs/puppet/ssl'],
#   nodes_hostname       => ['puppet02.domain.org', 'puppet03.domain.org'],
#   nodes_ip4            => ['192.168.0.10', '192.168.0.11'],
#   nodes_ip6            => ['2001:798:3::56', '2001:798:3::54'],
#   csync2_ssl_key       => lookup('csync2_ssl_key'),
#   csync2_ssl_cert      => lookup('csync2_ssl_cert'),
#   csync2_preshared_key => lookup('csync2_preshared_key');
# }
#
# Authors
# -------
#
# Massimiliano Adamo <maxadamo@gmail.com>
#
# Copyright
# ---------
#
# Copyright 2018 Massimiliano Adamo, unless otherwise noted.
#
class lsyncd_csync2 (
  Boolean $use_lsyncd              = $::lsyncd_csync2::params::use_lsyncd,
  String $sync_group               = $::lsyncd_csync2::params::sync_group,
  Array $sync_dir                  = $::lsyncd_csync2::params::sync_dir,
  Array $sync_exclude              = $::lsyncd_csync2::params::sync_exclude,
  String $csync2_ssl_key           = $::lsyncd_csync2::params::csync2_ssl_key,
  String $csync2_ssl_cert          = $::lsyncd_csync2::params::csync2_ssl_cert,
  String $csync2_preshared_key     = $::lsyncd_csync2::params::csync2_preshared_key,
  Array $lsyncd_packages           = $::lsyncd_csync2::params::lsyncd_packages,
  Array $csync_packages            = $::lsyncd_csync2::params::csync_packages,
  Array $nodes_hostname            = $::lsyncd_csync2::params::nodes_hostname,
  Array $nodes_ip4                 = $::lsyncd_csync2::params::nodes_ip4,
  Array $nodes_ip6                 = $::lsyncd_csync2::params::nodes_ip6,
  String $vip_ip4                  = $::lsyncd_csync2::params::vip_ip4,
  String $vip_ip4_subnet           = $::lsyncd_csync2::params::vip_ip4_subnet,
  String $network_interface        = $::lsyncd_csync2::params::network_interface,
  Optional[String] $vip_ip6        = $::lsyncd_csync2::params::vip_ip6,
  Optional[String] $vip_ip6_subnet = $::lsyncd_csync2::params::vip_ip6_subnet
  ) inherits lsyncd_csync2::params {

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
    'lsyncd_csync2::firewall':
      nodes_ip4 => $nodes_ip4,
      nodes_ip6 => $nodes_ip6;
    'lsyncd_csync2::service':
      use_lsyncd      => $use_lsyncd,
      lsyncd_packages => $lsyncd_packages,
      nodes_ip4       => $nodes_ip4,
      nodes_ip6       => $nodes_ip6;
    'lsyncd_csync2::files':
      use_lsyncd           => $use_lsyncd,
      sync_group           => $sync_group,
      sync_dir             => $sync_dir,
      sync_exclude         => $sync_exclude,
      csync2_ssl_key       => $csync2_ssl_key,
      csync2_ssl_cert      => $csync2_ssl_cert,
      csync2_preshared_key => $csync2_preshared_key,
      csync_packages       => $csync_packages,
      lsyncd_packages      => $lsyncd_packages,
      nodes_hostname       => $nodes_hostname;
    'lsyncd_csync2::keepalived':
      network_interface => $network_interface,
      nodes_ip4         => $nodes_ip4,
      vip_ip4           => $vip_ip4
      vip_ip4_subnet    => $vip_ip4_subnet,
      nodes_ip6         => $nodes_ip6[],
      vip_ip6           => $vip_ip6,
      vip_ip6_subnet    = $vip_ip6_subnet;
    'lscynd_csync2::nfs':;
  }

  if any2bool($use_lsyncd) == true {
    $all_packages = concat($csync_packages, $lsyncd_packages)
  } else {
    $all_packages = $csync_packages
    $lsyncd_packages.each | String $lsyncd_package | {
      unless defined(Package[$lsyncd_package]) {
        package { $lsyncd_package:
          ensure => installed;
        }
      }
    }
  }

  $all_packages.each | String $sync_package | {
    unless defined(Package[$sync_package]) {
      package { $sync_package:
        ensure => installed;
      }
    }
  }

}
# vim:ts=2:sw=2
