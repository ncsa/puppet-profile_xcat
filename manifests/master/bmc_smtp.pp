# @summary Forward email from node BMC's to MDA on local (master) node
#
# @example
#   include profile_xcat::master::bmc_smtp
class profile_xcat::master::bmc_smtp {

    include ::xinetd

    # Get IPMI network CIDR
    $ipmi_network = lookup( 'profile_xcat::network_ipmi', String[11] )

    # Ensure proper network address for IPMI network
    $tgt_net = ip_address( ip_network( $ipmi_network ) )

    # Check all ip's, find if one is on the same network as $ipmi_network
    $bind_ip = $facts['networking']['interfaces'].reduce('') | $memo, $kv | {
        # $kv is [ interface_name , interface_data ]
        $if_name = $kv[0]
        $interface_data = $kv[1]
        $ip = $interface_data['ip']
        $network = $interface_data['network']
        if $network == $tgt_net {
            $interface_data['ip']
        } else {
            $memo
        }
    }

    $ensure = $bind_ip ? {
        String[1] => 'present',
        default   => 'absent',
    }
    ::xinetd::service { 'bmc_smtp':
        ensure       => $ensure,
        service_type => 'UNLISTED',
        wait         => 'no',
        user         => 'nobody',
        groups       => 'no',
        group        => 'nobody',
        bind         => $bind_ip,
        port         => '25',
        redirect     => 'localhost 25',
    }

}
