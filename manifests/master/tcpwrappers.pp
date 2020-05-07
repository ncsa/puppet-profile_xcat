# @summary Configure tcpwrappers to allow from mgmt net and ipmi net
#
# Configure tcpwrappers to allow from mgmt net and ipmi net
#
# Automatically included by profile_xcat::master
class profile_xcat::master::tcpwrappers {

    $mgmt_network = lookup( 'profile_xcat::mgmt_net_cidr', String[11] )
    $ipmi_network = lookup( 'profile_xcat::ipmi_net_cidr', String[11] )

    tcpwrappers::allow { 'allow all from xcat mgmt network':
        service => 'ALL',
        address => $mgmt_network,
    }

    tcpwrappers::allow { 'allow all from xcat ipmi network':
        service => 'ALL',
        address => $ipmi_network,
    }

}
