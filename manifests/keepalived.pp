# == Class: tiny_nas::keepalived
#
class tiny_nas::keepalived (
  $network_interface,
  $nodes_hostnames,
  $nodes_ip4,
  $vip_ip4,
  $vip_ip4_subnet,
  $keepalived_sysconf_options,
  $nodes_ip6 = [],
  $vip_ip6 = undef,
  $vip_ip6_subnet = undef,
) {

  if ($vip_ip6) and !($vip_ip6_subnet) {
    fail('$vip_ip6 is set but $vip_ip6_subnet is not set')
  } elsif ($vip_ip6_subnet) and !($vip_ip6) {
    fail('$vip_ip6_subnet is set but $vip_ip6 is not set')
  }

  $keepalived_state = $nodes_ip4[0] ? {
    $facts['ipaddress'] => 'MASTER',
    default             => 'BACKUP'
  }
  $keepalived_priority = $nodes_ip4[0] ? {
    $facts['ipaddress'] => 100,
    default             => 50
  }

  $peer_ip4 = delete($nodes_ip4, $::ipaddress)
  $_peer_host = delete($nodes_hostnames, [$::hostname, $::fqdn])
  $peer_host = regsubst($_peer_host, ".${::domain}", '')

  class { 'keepalived': sysconf_options => $keepalived_sysconf_options; }

  keepalived::vrrp::script { 'check_nfs':
    script   => 'killall -0 nfsd',
    interval => 2,
    weight   => 2;
  }

  if ($vip_ip6) {
    $peer_ip6 = delete($nodes_ip6, $::ipaddress6)
    keepalived::vrrp::instance { 'NFS':
      interface                  => $network_interface,
      state                      => $keepalived_state,
      virtual_router_id          => seeded_rand(255, "${module_name}${::environment}") + 0,
      unicast_source_ip          => $::ipaddress,
      unicast_peers              => [$peer_ip4[0]],
      priority                   => $keepalived_priority,
      auth_type                  => 'PASS',
      auth_pass                  => seeded_rand_string(10, "${module_name}${::environment}"),
      virtual_ipaddress          => "${vip_ip4}/${vip_ip4_subnet}",
      virtual_ipaddress_excluded => ["${vip_ip6}/${vip_ip6_subnet}"],
      track_script               => 'check_nfs',
      notify_script_backup       => '/etc/keepalived/keepalived-down.sh',
      notify_script_master       => '/etc/keepalived/keepalived-up.sh';
    }
  } else {
    keepalived::vrrp::instance { 'NFS':
      interface            => $network_interface,
      state                => 'BACKUP',
      virtual_router_id    => seeded_rand(255, "${module_name}${::environment}") + 0,
      unicast_source_ip    => $::ipaddress,
      unicast_peers        => [$peer_ip4[0]],
      priority             => 100,
      auth_type            => 'PASS',
      auth_pass            => seeded_rand_string(10, "${module_name}${::environment}"),
      virtual_ipaddress    => "${vip_ip4}/${vip_ip4_subnet}",
      track_script         => 'check_nfs',
      notify_script_backup => '/etc/keepalived/keepalived-down.sh',
      notify_script_master => '/etc/keepalived/keepalived-up.sh';
    }
  }

}
# vim:ts=2:sw=2
