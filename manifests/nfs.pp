# Class: tiny_nas::nfs
#
#
class tiny_nas::nfs (
  $sync_dir,
  $nas_root = $::tiny_nas::params::nas_root,
) {

  class { '::nfs':
    server_enabled => true,
    nfs_v4         => false;
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
