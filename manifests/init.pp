# @summary Defines variables that are used by both xcat::master and xcat::client
#
# Defines variables that are used by xcat::master and xcat::client
#
# @param ipmi_net_cidrs
#    xCAT IPMI network(s), in CIDR format
#
# @param mgmt_net_cidrs
#    xCAT boot and mgmt network(s), in CIDR format
#
# @param master_node_ip
#    IP of xCAT master node
class profile_xcat (
  Array $ipmi_net_cidrs,
  Array $mgmt_net_cidrs,
  String $master_node_ip,
  Optional[ String ] $ipmi_bind_ip,
) {
  # nothing to do here, just define class parameters above for use in the
  # other classes
}
