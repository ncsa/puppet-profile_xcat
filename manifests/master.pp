# @summary Configure an xcat master node.
#
# Configure an xcat master node.
#
# Includes all subordinate classes.
class profile_xcat::master {
  include profile_xcat::admin_bastion
  include profile_xcat::master::backup
  include profile_xcat::master::bmc_smtp
  include profile_xcat::master::firewall
  include profile_xcat::master::group_export
  include profile_xcat::master::inventory_audit
  include profile_xcat::master::nfs

  # tcpwrappers was removed in RHEL8
  $os_family = $facts['os']['family']
  $os_rel_major = Integer( $facts['os']['release']['major'] )
  if $os_family == 'RedHat' and $os_rel_major < 8 {
    include profile_xcat::master::tcpwrappers
  }
}
