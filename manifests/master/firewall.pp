# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# Required ports list at:
# https://xcat-docs.readthedocs.io/en/stable/advanced/ports/xcat_ports.html
#
# @example
#   include profile_xcat::master::firewall
class profile_xcat::master::firewall {

    # Get required values from hiera, ensure they are not empty
    # network CIDR has a min length of 11 (x.x.x.x/nn)
    $mgmt_network = lookup( 'profile_xcat::network_mgmt', String[11] )
    $ipmi_network = lookup( 'profile_xcat::network_ipmi', String[11] )

    $net_names = {
        'MGMT' => $mgmt_network,
        'IPMI' => $ipmi_network,
    }

    $net_port_map = {
        'MGMT' => {
            'tcp' => [ 53, 67, 68, 69, 80, 123, 514, 782, 873, 2049, 3001, 3002, 4011 ],
            'udp' => [ 53, 69, 80, 514, 873, 2049, 3001, 3002 ],
        },
        'IPMI' => {
            'tcp' => [ 25 ]
        },
    }

    # Allow known ports on xcat networks
    $net_port_map.each | $name, $proto_port_map | {
        $network = $net_names[$name]
        $proto_port_map.each | $protocol, $portlist | {
            firewall {
                "208 allow incoming ${protocol} ports on XCAT ${name} net":
                    action => 'accept',
                    dport  => $portlist,
                    proto  => $protocol,
                    source => $network,
            }
        }
    }

}
