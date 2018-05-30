# == Class: tiny_nas::firewall
#
class tiny_nas::firewall (
  $sync_dir,
  $nodes_ip4,
  $nodes_ip6 = []
  ) {

# sync_dir:
#   moodledata:
#     client_list:
#       - '83.97.93.24(rw,insecure,async,no_root_squash)'
#       - '83.97.93.25(rw,insecure,async,no_root_squash)'
#       - '2001:798:3::12c(rw,insecure,async,no_root_squash)'
#       - '2001:798:3::12d(rw,insecure,async,no_root_squash)'
#     dir_watch: false
#   puppet_ca:
#     client_list:
#       - '83.97.92.62(rw,insecure,async,no_root_squash)'
#       - '83.97.92.60(rw,insecure,async,no_root_squash)'
#       - '2001:798:3::56(rw,insecure,async,no_root_squash)'
#       - '2001:798:3::54(rw,insecure,async,no_root_squash)'
#     dir_watch: true
#   letsencrypt_wildcard:
#     client_list:
#       - '83.97.93.17(rw,insecure,async,no_root_squash)'
#       - '2001:798:3::125(rw,insecure,async,no_root_squash)'
#     dir_watch: true

  $filtered_syncd_dir = $sync_dir.filter |$keys, $values| {
    $keys != 'dir_watch'
  }

  notify { "test ${filtered_syncd_dir}":
    message => "test ${filtered_syncd_dir}";
  }

  $nodes_ips = concat($nodes_ip4, $nodes_ip6)
  $peer_ip = delete($nodes_ip4, $::ipaddress)

  $nodes_ips.each | String $node_ip | {
    if ':' in $node_ip { $provider = 'ip6tables' } else { $provider = 'iptables' }
    firewall {
      "200 allow outbound TCP to Csync to ${node_ip} for provider ${provider}":
        chain       => 'OUTPUT',
        action      => accept,
        destination => $node_ip,
        provider    => $provider,
        proto       => tcp,
        dport       => 30865;
      "200 allow inbound TCP to Csync from ${node_ip} for provider ${provider}":
        chain    => 'INPUT',
        action   => accept,
        source   => $node_ip,
        provider => $provider,
        proto    => tcp,
        dport    => 30865;
    }
  }

  firewall {
    default:
      action => accept,
      proto  => 'vrrp';
    "200 Allow VRRP inbound from ${peer_ip}":
      chain  => 'INPUT',
      source => $peer_ip;
    '200 Allow VRRP inbound to multicast':
      chain       => 'INPUT',
      destination => '224.0.0.0/8';
    '200 Allow VRRP outbound to multicast':
      chain       => 'OUTPUT',
      destination => '224.0.0.0/8';
    "200 Allow VRRP outbound to ${peer_ip}":
      chain       => 'OUTPUT',
      destination => $peer_ip;
  }


}
# vim:ts=2:sw=2
