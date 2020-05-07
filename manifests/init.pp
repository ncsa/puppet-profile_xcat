# @summary Defines variables that are used by both xcat::master and xcat::client
#
# Defines variables that are used by xcat::master and xcat::client
#
# @param ipmi_net_cidr
#    xCAT IPMI network, in CIDR format
#
# @param mgmt_net_cidr
#    xCAT boot and mgmt network, in CIDR format
#
# @param master_node_ip
#    IP of xCAT master node
class profile_xcat (
    String $ipmi_net_cidr,
    String $mgmt_net_cidr,
    String $master_node_ip,
) {
    # does nothing at the moment
}
