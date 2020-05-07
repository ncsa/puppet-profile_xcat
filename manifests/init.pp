# @summary Primarily houses variables that are used by both xcat::master
#          and xcat::client
#
# @param network_mgmt - String
#                       xCAT boot and mgmt network, in CIDR format
#
# @param network_ipmi - String
#                       xCAT IPMI network, in CIDR format
class profile_xcat (
    String $network_mgmt,
    String $network_ipmi,
) {
    # does nothing at the moment
}
