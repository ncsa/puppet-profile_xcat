# profile_xcat

[![pdk-validate](https://github.com/ncsa/puppet-profile_xcat/actions/workflows/pdk-validate.yml/badge.svg)](https://github.com/ncsa/puppet-profile_xcat/actions/workflows/pdk-validate.yml)

[![yamllint](https://github.com/ncsa/puppet-profile_xcat/actions/workflows/yamllint.yml/badge.svg)](https://github.com/ncsa/puppet-profile_xcat/actions/workflows/yamllint.yml)

NCSA Common Profiles - Configure an xCAT master, clients, and general admin bastions. (An xCAT master will generally also be an admin bastion.)

This profile does not install xCAT.

For admin tools, see: [ncsa/xcat-tools](https://github.com/ncsa/xcat-tools)

## Breaking Change History
- `v2.0.0` Replaced `profile_xcat::master_node_ip` and `profile_xcat::master::root::*` Strings with `profile_xcat::admin_bastions` Hash along with `profile_xcat::admin_bastion::ssh::private_key_content` and `profile_xcat::admin_bastion::ssh::private_key_type` Strings.


## Dependencies

- [inkblot/ipcalc](https://forge.puppet.com/inkblot/ipcalc)
- [ncsa/profile_backup](https://github.com/ncsa/puppet-profile_backup)
- [ncsa/profile_pam_access](https://github.com/ncsa/puppet-profile_pam_access)
- [ncsa/sshd](https://github.com/ncsa/puppet-sshd)
- [puppetlabs/firewall](https://forge.puppet.com/puppetlabs/firewall)
- [puppetlabs/xinetd](https://forge.puppet.com/puppetlabs/xinetd)
- [sharumpe/tcpwrappers](https://forge.puppet.com/sharumpe/tcpwrappers)

The various parallel shell packages will also generally require configuration of the EPEL repo.


## Usage
### xCAT Client
In a role.pp or profile.pp file:
```
include profile_xcat::client
```
Heira data:
```
---
# key-value pairs defining admin bastion IPs and their root public SSH keys;
# NOTE: for clusters with more complicated networking setups, the IPs may
# have to vary depending on the networks and routing for bastions and clients
profile_xcat::admin_bastions:
  172.27.28.2: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABfyXKWY8jNYwxtwSeAWXGIxAZfwq98EgEGMZQV4987g6ehq/o root@xcat_server"
  172.27.28.3: "ssh-ecdsa AJLUDnJd83JAkJFID root@admin_bastion"
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
profile_xcat::master_node_hostname: "xcat-master.internal.ncsa.edu"
profile_xcat::mgmt_net_cidrs:
  - "172.28.28.0/24"
  - "172.28.20.0/23"

# sync parallel shell group config from...itself
profile_xcat::admin_bastion::parallel_shells::cron_enable: true

profile_xcat::admin_bastion::ssh::private_key_type: "rsa"
# the private key should generally be encrypted and stored in EYAML;
# rsa is recommended for an xCAT master; other types are recommended
# for secondary admin bastions
profile_xcat::admin_bastion::ssh::private_key_content: |
  -----BEGIN OPENSSH PRIVATE KEY-----
  b3BlbnNzaC1rZXktdjEAAAAAB
  NhAAAAAwEAAQAAAQEA5UTveYT
  ...
  -----END OPENSSH PRIVATE KEY-----

# export xCAT node data and construct parallel shell group config that
# admin bastions can import
profile_xcat::master::group_export::cron_enable: true
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

### Secondary admin bastion
In a role.pp or profile.pp file:
```
include profile_xcat::admin_bastion
```
Hiera data:
```
# set this next parameter to true if you want to sync
# /etc/hosts from the xCAT master; this may help make
# it easier for the admin bastion to SSH via mgmt net
# to the clients
profile_xcat::admin_bastion::hosts::cron_enable: true

# the private key should generally be encrypted and stored in EYAML;
# a type other than rsa is recommended for secondary admin bastion,
# see code for details
profile_xcat::admin_bastion::parallel_shells::cron_enable: true

# If a secondary admin bastion was provisioned with xCAT, the master's
# RSA .pub key will be present on the bastion in /root/.ssh/.
# You should either delete that (it is unnecessary) or use
# a different key type for the secondary admin bastion. This
# will prevent a mismatch between the bastion's id_rsa private key
# and the id_rsa.pub key that the master installed on the bastion.
profile_xcat::admin_bastion::ssh::private_key_type: "ecdsa"

profile_xcat::admin_bastion::ssh::private_key_content: |
  -----BEGIN OPENSSH PRIVATE KEY-----
  b3BlbnNzJFJkkd1rZXktdjAAB
  NhAHHjJEJJkdJ9KAwEQAAAeYT
  ...
  -----END OPENSSH PRIVATE KEY-----
```

## Reference

[REFERENCE.md](REFERENCE.md)
