require 'spec_helper'
describe 'tiny_nas' do
  context 'with default values for all parameters' do
    let(:params) do
      {
        'sync_dir ' => {
          'moodledata' => {
            'client_list' => [
              '192.168.0.100(rw,insecure,async,no_root_squash)',
              '192.168.0.101(rw,insecure,async,no_root_squash)',
              '2001:777:3::12c(rw,insecure,async,no_root_squash)',
            ],
            'dir_watch' => 'false',
          },
          'puppet_ca' => {
            'client_list' => [
              '192.168.0.102(rw,insecure,async,no_root_squash)',
              '192.168.0.103(rw,insecure,async,no_root_squash)',
              '2001:777:3::13a(rw,insecure,async,no_root_squash)',
            ],
            'dir_watch' => 'false',
          },
        },
        'nodes_hostnames' => ['nas01.example.org', 'nas02.example.org'],
        'nodes_ip4' => ['192.168.0.10', '192.168.0.11'],
        'nodes_ip6' => ['2001:777:3::13', '2001:777:3::14'],
        'vip_ip4' => '192.168.0.12',
        'vip_ip4_subnet' => '24',
        'vip_ip6' => '2001:777:3::15',
        'vip_ip6_subnet' => '64',
        'csync2_ssl_key' => 'this_is_my_csync2_ssl_key',
        'csync2_ssl_cert' => 'this_is_my_csync2_ssl_cert',
        'csync2_preshared_key' => 'this_is_my_csync2_preshared_key',
        'manage_lvm' => true,
        'vg_name' => 'rootvg',
        'lv_size' => 3,
      }
    end

    it {
      is_expected.to contain_class('tiny_nas')
    }
  end
end
