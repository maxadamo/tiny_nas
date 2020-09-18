# == Class: tiny_nas::service
#
class tiny_nas::service (
  $use_lsyncd,
  $lsyncd_packages,
  $nodes_ip4,
  $nodes_ip6 = []
) {

  $nodes_ips = concat($nodes_ip4, $nodes_ip6, '127.0.0.1')
  $_only_from = delete($nodes_ips, [$::ipaddress, $::ipaddress6])
  $only_from = strip(join($_only_from, ' '))

  xinetd::service { 'csync2':
    disable        => 'no',
    server         => '/usr/sbin/csync2',
    socket_type    => 'stream',
    protocol       => 'tcp',
    port           => '30865',
    user           => 'root',
    group          => 'root',
    groups         => 'yes',
    wait           => 'no',
    flags          => 'REUSE',
    server_args    => '-i -l',
    log_on_success => '',
    only_from      => $only_from,
    log_on_failure => 'USERID',
    per_source     => 'UNLIMITED';
  }

  if any2bool($use_lsyncd) == true {
    service { 'lsyncd':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
      require    => Package[$lsyncd_packages];
    }
  }

}
# vim:ts=2:sw=2
