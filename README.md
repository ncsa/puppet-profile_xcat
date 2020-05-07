# profile_xcat

NCSA Common Profiles - Basic xcat master and client setup

This profile does not install xCAT.

For admin tools, see: [ncsa/xcat-tools](https://github.com/ncsa/xcat-tools)

## Dependencies

- [inkblot/ipcalc](https://forge.puppet.com/inkblot/ipcalc)
- [ncsa/profile_pam_access](https://github.com/ncsa/puppet-profile_pam_access)
- [ncsa/sshd](https://github.com/ncsa/puppet-sshd)
- [puppetlabs/firewall](https://forge.puppet.com/puppetlabs/firewall)
- [puppetlabs/xinetd](https://forge.puppet.com/puppetlabs/xinetd)
- [sharumpe/tcpwrappers](https://forge.puppet.com/sharumpe/tcpwrappers)

## Reference

### class profile_xcat::master::root (
-    String $sshkey_pub,
-    String $sshkey_priv,
-    String $sshkey_type,
### class profile_xcat (
-    String $ipmi_net_cidr,
-    String $mgmt_net_cidr,
-    String $master_node_ip,

[REFERENCE.md](REFERENCE.md)
