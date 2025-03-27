# @summary Defines variables that are generally used by two or more sub-profiles (client, master, admin_bastion).
#
# Defines variables that are generally used by two or more sub-profiles (client, master, admin_bastion).
#
# @param admin_bastions
#   Optionally allow SSH from admin bastions, which should include the xCAT node.
#   Hash of the form:
#     IP1: <content>
#     IP2: <content>
#     ...
#   <content> is an OpenSSH key - generally type, key, and comment. In this case
#   "comment" should be a single word of the form root@<FQDN>.
#
# @param ipmi_bind_ip
#   Optional IP address to bind xinetd service for IPMI
#
# @param ipmi_net_cidrs
#   xCAT IPMI network(s), in CIDR format
#
# @param master_node_hostname
#   Hostname of xCAT master node.
#
# @param mgmt_net_cidrs
#   xCAT boot and mgmt network(s), in CIDR format
class profile_xcat (
  Hash             $admin_bastions,
  Array            $ipmi_net_cidrs,
  Array            $mgmt_net_cidrs,
  Optional[String] $ipmi_bind_ip,
  String           $master_node_hostname,
) {
  # nothing to do here, just define class parameters above for use in the
  # other classes
}
