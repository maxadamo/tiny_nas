# tiny_nas

#### Table of Contents

1. [Description](#description)
    * [Setup requirements](#setup-requirements)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Tiny_NAS sets up a tiny, low-end and Highly-Available NAS with two ways synchronization.
Tiny_nas works in two ways. Directories can be either:

* watched and immediately synchronized based on kernel events
* synchronized through a cron job

You can have a combination of them (some directories watched, other directories under cron)

No ZFS. Tiny NAS is tiny, and it doesn't need a fancy filesystem nor complex volume management.
It allows to use LVM through the options mentioned in `init.pp`.
If you intend to use ZFS, disable LVM management, and add the ZFS volume yourself.

No NFS4. Tiny NAS is tiny and the security is based on the IP (managed throught the firewall module)

Tiny NAS is low-end by design.
If you have a high load on you NAS neither lscyncd + csync2 nor scheduled job are a proper solution and you should consider a clustered filesystems.

### Setup Requirements

On CentOS 7 the package csync2 is missing.
You can download an [RPM here](http://repo.okay.com.mx/?dir=centos/7/x86_64/release)

You need to create the keys beforehand, using the following commands:

```sh
openssl req -x509 -newkey rsa:1024 -days 7200 \
-keyout ./csync2_ssl_key.pem -nodes \
-out ./csync2_ssl_cert.pem -subj '/CN=puppet'
csync2 -k ./csync2_puppet-group.key
```

You can either store the values in Hiera or they can be provided as templates.

## Usage

### Server setup

This is all you need (ipv6 is optional):

```yaml
sync_dir:
  moodledata:
    client_list:
      - '192.168.0.10(rw,insecure,async,no_root_squash)'
      - '192.168.0.11(rw,insecure,async,no_root_squash)'
      - '2001:777:3::50(rw,insecure,async,no_root_squash)'
      - '2001:777:3::51(rw,insecure,async,no_root_squash)'
    dir_watch: false
  puppet_ca:
    client_list:
      - '192.168.0.12(rw,insecure,async,no_root_squash)'
      - '192.168.0.13(rw,insecure,async,no_root_squash)'
      - '2001:777:3::52(rw,insecure,async,no_root_squash)'
      - '2001:777:3::53(rw,insecure,async,no_root_squash)'
    dir_watch: true
```

```puppet
class { 'tiny_nas':
  sync_dir             => lookup('sync_dir'),
  nodes_hostnames      => ['nas01.example.org', 'nas02.example.org'],
  nodes_ip4            => ['192.168.0.48', '192.168.0.49'],
  nodes_ip6            => ['2001:777:3::98', '2001:777:3::99'],
  vip_ip4              => '192.168.0.50',
  vip_ip4_subnet       => '22',
  vip_ip6              => '2001:777:3::100',
  vip_ip6_subnet       => '64',
  csync2_ssl_key       => lookup('csync2_ssl_key'),
  csync2_ssl_cert      => lookup('csync2_ssl_cert'),
  csync2_preshared_key => lookup('csync2_preshared_key'),
  manage_lvm           => true,
  vg_name              => 'rootvg',
  lv_size              => 3;
}
```

If can also use templates for the keys:

```puppet
  csync2_ssl_key       => template('mymodule/ssl_key'),
  csync2_ssl_cert      => template('mymodule/ssl_cert'),
  csync2_preshared_key => template('mymodule/preshared_key'),
```

### Client setup

```puppet
tiny_nas::client { '/etc/puppetlabs/pupet/ssl':
  ensure             => present,
  nfs_server_enabled => true,
  server             => 'nas.example.org',
  share              => '/nas/puppet_ca';
}
```

nfs options default is:

```puppet
options_nfs => 'tcp,soft,nolock,rsize=32768,wsize=32768,intr,noatime,actimeo=3'
```

Please check `manifests/client.pp` for other available options.

## Limitations

It is untested on more then two hosts.
It is untested without IPv6.
It is not tested very well on CentOS

## Development

Feel free to make pull requests and/or open issues on [my GitHub Repository](https://github.com/maxadamo/tiny_nas)
