# @summary Open firewall for xcat services on mgmt and ipmi networks
#
# Open firewall for xcat services on mgmt and ipmi networks
#
# @param net_port_map
#   Hash of hashes defining the Network (MGMT or IPMI, both required), the protocol (tcp or udp),
#   and the port(s) to open. See common.yaml for example
#
# Required ports list at:
# https://xcat-docs.readthedocs.io/en/stable/advanced/ports/xcat_ports.html
#
# Automatically included by profile_xcat::master
class profile_xcat::master::firewall (
  Hash $net_port_map,
){

  # Get required values from hiera, ensure they are not empty
  # network CIDR has a min length of 11 (x.x.x.x/nn)
  $mgmt_networks = lookup( 'profile_xcat::mgmt_net_cidrs', Array )
  $ipmi_networks = lookup( 'profile_xcat::ipmi_net_cidrs', Array )

  # assign typekey to each network
  $m_nets = $mgmt_networks.reduce({}) | $memo, $net | {
    $memo + { $net =>  'MGMT' }
  }
  $i_nets = $ipmi_networks.reduce({}) | $memo, $net | {
    $memo + { $net =>  'IPMI' }
  }
  # combine the hashes
  $all_nets = $m_nets + $i_nets

  # For each network, for each protocol, add firewall exceptions for the ports
  # Outer loop is the networks passed in, so if any were empty lists, nothing
  # will happen or error-out
  $all_nets.each | $src, $typekey | {
    each( $net_port_map[ $typekey ] ) | $protocol, $portlist | {
      firewall {
        "208 allow incoming '${protocol}' ports on XCAT '${typekey}' net '${src}'":
            action => 'accept',
            dport  => $portlist,
            proto  => $protocol,
            source => $src,
      }
    }
  }

}
