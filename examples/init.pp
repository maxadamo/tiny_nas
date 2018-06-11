#
#
class { 'tiny_nas':
  sync_dir             => ['/etc/puppetlabs/puppet/ssl'],
  nodes_hostname       => ['puppet02.domain.org', 'puppet03.domain.org'],
  nodes_ip4            => ['192.168.0.10', '192.168.0.11'],
  nodes_ip6            => ['2001:798:3::56', '2001:798:3::54'],
  csync2_ssl_key       => 'csync2_ssl_key',
  csync2_ssl_cert      => 'csync2_ssl_cert',
  csync2_preshared_key => 'csync2_preshared_key';
}
