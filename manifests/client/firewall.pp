# == Class: tiny_nas::client::firewall
#
class tiny_nas::client::firewall {

  ['iptables', 'ip6tables'].each | String $provider | {
    firewall {
      "200 allow outbound UDP to port 111, 2049, 4045, 10050 for provider ${provider}":
        chain    => 'OUTPUT',
        action   => accept,
        provider => $provider,
        proto    => udp,
        dport    => [111, 2049, 4045, 10050];
      "200 allow outbound TCP to port 111, 2049, 4045, 10050 for provider ${provider}":
        chain    => 'OUTPUT',
        action   => accept,
        provider => $provider,
        proto    => tcp,
        dport    => [111, 2049, 4045, 10050];
    }
  }

}
# vim:ts=2:sw=2
