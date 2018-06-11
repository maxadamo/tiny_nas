# == Class: tiny_nas
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
# [*nodes_hostnames*] <Array>
#   default: empty (list of servers hostnames). Mandatory.
#
# [*sync_dir*] <Hash>
#   default: empty (
#            hash of directories associated to clients who gain access
#            through NFS ACL
#            ). Mandatory.
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
# [*nas_root*] <String>
#   default: '/nas' (this is the nas root directory)
#
# [*manage_lvm*] <Boolean>
#   default: false (wheter to manage LVM or not)
#
# [*lv_size*] <Integer>
#   default: undef (LV size in GB: minimum 1)
#
# [*vg_name*] <String>
#   default: undef (name of Volume Group)
#
# Examples
# --------
#
# class { 'tiny_nas':
#   sync_dir             => ['/etc/puppetlabs/puppet/ssl'],
#   nodes_hostnames       => ['puppet02.domain.org', 'puppet03.domain.org'],
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
class tiny_nas (

  Boolean $use_lsyncd                    = $::tiny_nas::params::use_lsyncd,
  String $lsyncd_conf                    = $::tiny_nas::params::lsyncd_conf,
  String $lsyncd_conf_dir                = $::tiny_nas::params::lsyncd_conf_dir,
  Hash $sync_dir                         = $::tiny_nas::params::sync_dir,
  Array $sync_exclude                    = $::tiny_nas::params::sync_exclude,
  String $csync2_ssl_key                 = $::tiny_nas::params::csync2_ssl_key,
  String $csync2_ssl_cert                = $::tiny_nas::params::csync2_ssl_cert,
  String $csync2_preshared_key           = $::tiny_nas::params::csync2_preshared_key,
  Array $lsyncd_packages                 = $::tiny_nas::params::lsyncd_packages,
  Array $csync_packages                  = $::tiny_nas::params::csync_packages,
  Array $nodes_hostnames                 = $::tiny_nas::params::nodes_hostnames,
  Array $nodes_ip4                       = $::tiny_nas::params::nodes_ip4,
  Array $nodes_ip6                       = $::tiny_nas::params::nodes_ip6,
  String $vip_ip4                        = $::tiny_nas::params::vip_ip4,
  String $vip_ip4_subnet                 = $::tiny_nas::params::vip_ip4_subnet,
  String $network_interface              = $::tiny_nas::params::network_interface,
  Optional[String] $vip_ip6              = $::tiny_nas::params::vip_ip6,
  Optional[String] $vip_ip6_subnet       = $::tiny_nas::params::vip_ip6_subnet,
  String $nas_root                       = $::tiny_nas::params::nas_root,
  Optional[Boolean] $manage_lvm          = $::tiny_nas::params::manage_lvm,
  Optional[Integer[1, default]] $lv_size = $::tiny_nas::params::lv_size,
  Optional[String] $vg_name              = $::tiny_nas::params::vg_name,
  Optional[String] $cron_sync_minute     = $::tiny_nas::params::cron_sync_minute,
  String $nfs_server_config              = $::tiny_nas::params::nfs_server_config

) inherits tiny_nas::params {

  if empty($nodes_hostnames) {
    fail('please provide values for the array $nodes_hostnames')
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
    'tiny_nas::lvm':
      nas_root   => $nas_root,
      manage_lvm => $manage_lvm,
      lv_size    => $lv_size,
      vg_name    => $vg_name,
      before     => Class['tiny_nas::files'];
    'tiny_nas::firewall':
      sync_dir  => $sync_dir,
      nodes_ip4 => $nodes_ip4,
      nodes_ip6 => $nodes_ip6;
    'tiny_nas::service':
      use_lsyncd      => $use_lsyncd,
      lsyncd_packages => $lsyncd_packages,
      nodes_ip4       => $nodes_ip4,
      nodes_ip6       => $nodes_ip6;
    'tiny_nas::files':
      nfs_server_config    => $nfs_server_config,
      use_lsyncd           => $use_lsyncd,
      sync_dir             => $sync_dir,
      sync_exclude         => $sync_exclude,
      csync2_ssl_key       => $csync2_ssl_key,
      csync2_ssl_cert      => $csync2_ssl_cert,
      csync2_preshared_key => $csync2_preshared_key,
      csync_packages       => $csync_packages,
      lsyncd_packages      => $lsyncd_packages,
      lsyncd_conf          => $lsyncd_conf,
      lsyncd_conf_dir      => $lsyncd_conf_dir,
      nodes_hostnames      => $nodes_hostnames;
    'tiny_nas::keepalived':
      network_interface => $network_interface,
      nodes_hostnames   => $nodes_hostnames,
      nodes_ip4         => $nodes_ip4,
      vip_ip4           => $vip_ip4,
      vip_ip4_subnet    => $vip_ip4_subnet,
      nodes_ip6         => $nodes_ip6,
      vip_ip6           => $vip_ip6,
      vip_ip6_subnet    => $vip_ip6_subnet;
    'tiny_nas::nfs':
      sync_dir => $sync_dir;
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
