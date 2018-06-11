# == Class: tiny_nas::client::firewall
#
class tiny_nas::client::firewall (
  $ipv6_enabled,
) {

  if any2bool($ipv6_enabled) == true {
    ['iptables', 'ip6tables'].each | String $provider | {
      firewall {
        "200 allow outbound UDP to port 111, 892, 2049, 4045 for provider ${provider}":
          chain    => 'OUTPUT',
          action   => accept,
          provider => $provider,
          proto    => udp,
          dport    => [111, 892, 2049, 4045];
        "200 allow outbound TCP to port 111, 892, 2049, 4045 for provider ${provider}":
          chain    => 'OUTPUT',
          action   => accept,
          provider => $provider,
          proto    => tcp,
          dport    => [111, 892, 2049, 4045];
      }
    }
  } else {
    firewall {
      '200 allow outbound UDP to port 111, 892, 2049, 4045':
        chain  => 'OUTPUT',
        action => accept,
        proto  => udp,
        dport  => [111, 892, 2049, 4045];
      '200 allow outbound TCP to port 111, 892, 2049, 4045':
        chain  => 'OUTPUT',
        action => accept,
        proto  => tcp,
        dport  => [111, 892, 2049, 4045];
    }
  }

}
# vim:ts=2:sw=2
