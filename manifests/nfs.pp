# Class: lsyncd_csync2::nfs
#
#
class lsyncd_csync2::nfs {

  class { '::nfs':
    server_enabled => true;
  }

}
