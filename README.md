# tiny_nas

#### Table of Contents

1. [Description](#description)
    * [Setup requirements](#setup-requirements)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Tiny_NAS sets up a tiny, low-end HA NAS with two ways synchronization.
tiny_nas works in two ways. A directory can be either:

* watched and immediately synchronized based on kernel events
* synchronized through a cron job

You can have a combination of them (some directory watched other directories under cron)

No ZFS. Tiny NAS is tiny, and it doesn't need a fancy filesystem or complex volume management.
It allows to use LVM through the options mentioned in `init.pp`.
If you intend to use ZFS, disable LVM management, and add the ZFS volume yourself.

Tiny NAS is low-end by design.
If you have a huge amount of files and the files are changing frequently neither lscyncd + csync2 nor scheduled job are a proper solution and you should look in to clustered filesystems.

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

This is all you need (ipv6 is optional):

```puppet
class { 'tiny_nas':
  sync_group           => 'puppet_ca',
  sync_dir             => ['/etc/puppetlabs/puppet/ssl'],
  nodes_hostname       => ['puppet02.domain.org', 'puppet03.domain.org'],
  nodes_ip4            => ['192.168.0.10', '192.168.0.11'],
  nodes_ip6            => ['2001:798:3::56', '2001:798:3::54'],
  csync2_ssl_key       => lookup('csync2_ssl_key'),
  csync2_ssl_cert      => lookup('csync2_ssl_cert'),
  csync2_preshared_key => lookup('csync2_preshared_key');
}
```

If you use templates for the keys and you want to disable directory watching:

```puppet
class { 'tiny_nas':
  use_lsyncd           => false,
  sync_group           => 'puppet_ca',
  sync_dir             => ['/etc/puppetlabs/puppet/ssl'],
  nodes_hostname       => ['puppet02.domain.org', 'puppet03.domain.org'],
  nodes_ip4            => ['192.168.0.10', '192.168.0.11'],
  csync2_ssl_key       => template('mymodule/ssl_key'),
  csync2_ssl_cert      => template('mymodule/ssl_cert'),
  csync2_preshared_key => template('mymodule/preshared_key'),
}
```

## Limitations

It is untested on more then two hosts.
It is untested without IPv6.

## Development

Feel free to make pull requests and/or open issues on [my GitHub Repository](https://github.com/maxadamo/tiny_nas)
