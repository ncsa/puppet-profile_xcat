# @summary Configure tcpwrappers to allow from mgmt net and ipmi net
#
# Configure tcpwrappers to allow from mgmt net and ipmi net
#
# Automatically included by profile_xcat::master
class profile_xcat::master::tcpwrappers {

  $mgmt_networks = lookup( 'profile_xcat::mgmt_net_cidrs', Array )
  $ipmi_networks = lookup( 'profile_xcat::ipmi_net_cidrs', Array )

  $mgmt_networks.each | $cidr | {
    tcpwrappers::allow { "allow all from xcat mgmt network '${cidr}'":
      service => 'ALL',
      address => $cidr,
    }
  }

  $ipmi_networks.each | $cidr | {
    tcpwrappers::allow { "allow all from xcat ipmi network '${cidr}'":
      service => 'ALL',
      address => $cidr,
    }
  }

}
