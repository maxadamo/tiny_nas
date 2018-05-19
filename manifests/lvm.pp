# == Class: tiny_nas::lvm
#
class tiny_nas::lvm (
  $manage_lvm = $::tiny_nas::params::manage_lvm,
  $lv_size    = $::tiny_nas::params::lv_size,
  $vg_name    = $::tiny_nas::params::vg_name,
  $nas_root   = $::tiny_nas::params::nas_root,
  ) inherits tiny_nas::params {

  if ($lv_size) { $first_param = 1 } else { $first_param = 0 }
  if ($vg_name) { $second_param = 1 } else { $second_param = 0 }
  if ($manage_lvm) { $third_param = 1 } else { $third_param = 0 }
  $total_param = $first_param + $second_param + $third_param

  if $total_param != 0 and $total_param != 3 {
    fail('$manage_lvm, $lv_size and $vg_name are not set consistently. I give up')
  }

  if $total_param == 3 {
    logical_volume { 'lv_nas':
      ensure       => present,
      volume_group => $vg_name,
      size         => "${lv_size}G",
    }

    filesystem { "/dev/mapper/${vg_name}-lv_nas":
      ensure  => present,
      fs_type => 'ext4',
      require => Logical_volume['lv_nas']
    }

    file { $nas_root:
      ensure => directory,
      mode   => '0755',
      owner  => root,
      group  => root;
    }

    mount { $nas_root:
      ensure  => mounted,
      fstype  => 'ext4',
      atboot  => true,
      device  => "/dev/mapper/${vg_name}-lv_nas",
      require => [
        File[$nas_root],
        Filesystem["/dev/mapper/${vg_name}-lv_nas"]
      ],
    }
  }

}
