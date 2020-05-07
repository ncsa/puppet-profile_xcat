# profile_xcat

NCSA Common Profiles - Basic xcat master and client setup

This profile does not install xCAT.

For admin tools, see: [ncsa/xcat-tools](https://github.com/ncsa/xcat-tools)

## Dependencies

- inkblot-ipcalc
- [ncsa/sshd](https://github.com/ncsa/puppet-sshd)
- [sharumpe/tcpwrappers](https://forge.puppet.com/sharumpe/tcpwrappers)
- puppetlabs/xinetd
- puppetlabs/firewall

## Reference
### class profile_xcat::master::root (
-    String $sshkey_pub,
-    String $sshkey_priv,
-    String $sshkey_type,
### class profile_xcat::client::ssh (
-    String $master_node_ip,
### class profile_xcat (
-    String $mgmt_net_cidr,
-    String $ipmi_net_cidr,

[/REFERENCE.md](REFERENCE.md)

