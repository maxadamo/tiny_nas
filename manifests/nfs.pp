# Class: lsyncd_csync2::nfs
#
#
class lsyncd_csync2::nfs (
  $sync_dir,
  $nas_root = $::lsyncd_csync2::params::nas_root,
) {

  class { '::nfs':
    server_enabled => true;
  }

  $sync_dir.each | String $exported_dir, $client_array | {
    $clients_acl = strip(join($client_array[client_list], ' '))
    nfs::server::export { "${nas_root}/${exported_dir}":
      ensure  => 'mounted',
      clients => $clients_acl;
    }
  }

}
# vim:ts=2:sw=2
