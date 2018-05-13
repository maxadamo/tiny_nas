# == Class: lsyncd_csync2::keepalived
#
class lsyncd_csync2::keepalived (
  $network_interface,
  $nodes_ip4,
  $vip_ip4,
  $vip_ip4_subnet,
  $nodes_ip6 = [],
  $vip_ip6 = undef,
  $vip_ip6_subnet = undef,
  ) inherits lsyncd_csync2::params {

  if ($vip_ip6) and not ($vip_ip6_subnet) {
    fail('$vip_ip6 is set $vip_ip6_subnet is not set')
  } elsif ($vip_ip6_subnet) and not ($vip_ip6) {
    fail('$vip_ip6_subnet is set $vip_ip6 is not set')
  }

  $peer_ip = delete($nodes_ip4, $::ipaddress)

  include ::keepalived

  keepalived::vrrp::script { 'check_nfs':
    script   => '/etc/keepalived/nfs_check.sh',
    interval => '2',
    weight   => '2';
  }

  if ($vip_ip6) {
    keepalived::vrrp::instance { 'NFS':
      interface                  => $network_interface,
      state                      => 'BACKUP',
      virtual_router_id          => '50',
      unicast_source_ip          => $::ipaddress,
      unicast_peers              => [$peer_ip],
      priority                   => '100',
      auth_type                  => 'PASS',
      auth_pass                  => 'secret',
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
      virtual_router_id    => '50',
      unicast_source_ip    => $::ipaddress,
      unicast_peers        => [$peer_ip],
      priority             => '100',
      auth_type            => 'PASS',
      auth_pass            => 'secret',
      virtual_ipaddress    => "${vip_ip4}/${vip_ip4_subnet}",
      track_script         => 'check_nfs',
      notify_script_backup => '/etc/keepalived/keepalived-down.sh',
      notify_script_master => '/etc/keepalived/keepalived-up.sh';
    }
  }

}
