# Class: lsyncd_csync2::nfs
#
#
class lsyncd_csync2::nfs (
  $sync_dir,
) {

  class { '::nfs':
    server_enabled => true;
  }

  $sync_dir.each | String $exported_dir, Array $client_array | {
    $clients_acl = strip(join($client_array, ' '))
    nfs::server::export{ $exported_dir:
      ensure  => 'mounted',
      clients => $clients_acl;
    }
  }

}
# vim:ts=2:sw=2
