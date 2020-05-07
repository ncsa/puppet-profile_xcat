# @summary Configure an xcat master node.
#
# Configure an xcat master node.
#
# Includes all subordinate classes.
class profile_xcat::master {
    include ::profile_xcat::master::bmc_smtp
    include ::profile_xcat::master::firewall
    include ::profile_xcat::master::nfs
    include ::profile_xcat::master::root
    include ::profile_xcat::master::tcpwrappers
}
