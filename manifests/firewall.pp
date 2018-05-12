# == Class: lsyncd_csync2::firewall
#
class lsyncd_csync2::firewall (
  $nodes_ip4,
  $nodes_ip6 = []
  ) {

  $nodes_ips = concat($nodes_ip4, $nodes_ip6)
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

}
# vim:ts=2:sw=2
