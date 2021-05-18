# @summary Open firewall for xcat services on mgmt and ipmi networks
#
# Open firewall for xcat services on mgmt and ipmi networks
#
# Required ports list at:
# https://xcat-docs.readthedocs.io/en/stable/advanced/ports/xcat_ports.html
#
# Automatically included by profile_xcat::master
class profile_xcat::master::firewall {

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

  $net_port_map = {
    'MGMT' => {
      'tcp' => [ 53, 67, 68, 69, 80, 123, 514, 782, 873, 2049, 3001, 3002, 4011 ],
      'udp' => [ 53, 69, 80, 514, 873, 2049, 3001, 3002 ],
    },
    'IPMI' => {
      'tcp' => [ 25 ]
    },
  }

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
