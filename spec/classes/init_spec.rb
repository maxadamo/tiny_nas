require 'spec_helper'
describe 'tiny_nas' do
  context 'with default values for all parameters' do
    let(:params) { {
      'sync_group'           => 'nas',
      'sync_dir '            => {
        'moodledata' => {
          'client_list' => [
            '83.97.93.24(rw,insecure,async,no_root_squash)',
            '2001:798:3::12c(rw,insecure,async,no_root_squash)'
          ],
          'dir_watch' => 'false'
        },
        'puppet_ca' => {
          'client_list' => [
            '83.97.92.62(rw,insecure,async,no_root_squash)',
            '2001:798:3::56(rw,insecure,async,no_root_squash)'
          ],
          'dir_watch' => 'false'
        }
      },
      'nodes_hostnames'      => ['nas01.geant.org', 'nas02.geant.org'],
      'nodes_ip4'            => ['83.97.93.40', '83.97.93.41'],
      'nodes_ip6'            => ['2001:798:3::13c', '2001:798:3::13d'],
      'vip_ip4'              => '83.97.93.46',
      'vip_ip4_subnet'       => '22',
      'vip_ip6'              => '2001:798:3::142',
      'vip_ip6_subnet'       => '64',
      'csync2_ssl_key'       => 'csync2_ssl_key',
      'csync2_ssl_cert'      => 'csync2_ssl_cert',
      'csync2_preshared_key' => 'csync2_preshared_key',
      'manage_lvm'           => true,
      'vg_name'              => 'rootvg',
      'lv_size'              => 3,
    } }
    it {
      is_expected.to contain_class('tiny_nas')
    }
  end
end
