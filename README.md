# profile_xcat

[![pdk-validate](https://github.com/ncsa/puppet-profile_xcat/actions/workflows/pdk-validate.yml/badge.svg)](https://github.com/ncsa/puppet-profile_xcat/actions/workflows/pdk-validate.yml)

[![yamllint](https://github.com/ncsa/puppet-profile_xcat/actions/workflows/yamllint.yml/badge.svg)](https://github.com/ncsa/puppet-profile_xcat/actions/workflows/yamllint.yml)

NCSA Common Profiles - Basic xcat master and client setup

This profile does not install xCAT.

For admin tools, see: [ncsa/xcat-tools](https://github.com/ncsa/xcat-tools)

## Dependencies

- [inkblot/ipcalc](https://forge.puppet.com/inkblot/ipcalc)
- [ncsa/profile_backup](https://github.com/ncsa/puppet-profile_backup)
- [ncsa/profile_pam_access](https://github.com/ncsa/puppet-profile_pam_access)
- [ncsa/sshd](https://github.com/ncsa/puppet-sshd)
- [puppetlabs/firewall](https://forge.puppet.com/puppetlabs/firewall)
- [puppetlabs/xinetd](https://forge.puppet.com/puppetlabs/xinetd)
- [sharumpe/tcpwrappers](https://forge.puppet.com/sharumpe/tcpwrappers)


## Usage
### xCAT Client
In a role.pp or profile.pp file:
```
include profile_xcat::client
```
Heira data:
```
---
profile_xcat::master_node_ip: "172.28.28.20"
profile_xcat::master::root::sshkey_pub: "\
  ssh-rsa \
  AAAAB3NzaC1yc2EAAAADAQAB\
  fyXKWY8jNYwxtwSeAWXGIxAZ\
  fwq98EgEGMZQV4987g6ehq/o \
  root@xcat_server"
```

### xCAT Server
In a role.pp or profile.pp file:
```
include profile_xcat::master
```
Hiera data ... pay close attention to the formatting of the multi-line strings:
- Spaces are added in the proper place in the ssh public key
- Newline is retained in the ssh private key
```
---
profile_xcat::ipmi_net_cidrs: []
profile_xcat::mgmt_net_cidrs:
  - "172.28.28.0/24"
  - "172.28.20.0/23"
profile_xcat::master_node_ip: "172.28.28.20"
profile_xcat::master::root::sshkey_pub: "\
  ssh-rsa \
  AAAAB3NzaC1yc2EAAAADAQAB\
  fyXKWY8jNYwxtwSeAWXGIxAZ \
  root@xcat_server"
profile_xcat::master::root::sshkey_priv: |
  -----BEGIN OPENSSH PRIVATE KEY-----
  b3BlbnNzaC1rZXktdjEAAAAAB
  NhAAAAAwEAAQAAAQEA5UTveYT
  ...
  -----END OPENSSH PRIVATE KEY-----
```

When using an xCat server on a VM or a routed network, define the bind ip in hiera for xinetd for the xcat server.
```
profile_xcat::ipmi_bind_ip: "172.28.16.67"
```

Allowed ports have been trimmed down from security vetting, you can override this hiera value to open up anything extra
```
profile_xcat::master::firewall::net_port_map
```
Also see the defaults for `net_port_map` set in common.yaml, which has many of the possible ports listed but commented out

## Reference

### class profile_xcat::master::firewall (
-  Hash $net_port_map,
### class profile_xcat::master::root (
-  String $sshkey_pub,
-  String $sshkey_priv,
-  String $sshkey_type,
### class profile_xcat::master::bmc_smtp (
-  Boolean $enable_bmc_smtp,
### define profile_xcat::master::nfs::export (
-  String $mount_point,
-  String $network,
-  Array  $options,
### class profile_xcat (
-  Array $ipmi_net_cidrs,
-  Array $mgmt_net_cidrs,
-  String $master_node_ip,
-  Optional[ String ] $ipmi_bind_ip,

[REFERENCE.md](REFERENCE.md)
