# Class: lsyncd_csync2::nfs
#
#
class lsyncd_csync2::nfs (
  $sync_dir,
) {

  class { '::nfs':
    server_enabled => true;
  }

  $sync_dir.each | String $exported_dir, $client_array | {
      $clients_acl = strip(join($client_array[client_list], ' '))
      nfs::server::export{ $exported_dir:
        ensure  => 'mounted',
        clients => $clients_acl;
      }
    }
  }

}
# vim:ts=2:sw=2
