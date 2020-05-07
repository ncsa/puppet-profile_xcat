# @summary Primarily houses variables that are used by both xcat::master
#          and xcat::client
#
# @param mgmt_net_cidr - String
#                        xCAT boot and mgmt network, in CIDR format
#
# @param ipmi_net_cidr - String
#                        xCAT IPMI network, in CIDR format
class profile_xcat (
    String $mgmt_net_cidr,
    String $ipmi_net_cidr,
) {
    # does nothing at the moment
}
