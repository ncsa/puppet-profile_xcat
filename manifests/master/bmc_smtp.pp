# @summary Forward email from node BMC's to MDA on local (master) node
#
# Forward email from node BMC's to MDA on local (master) node
#
# Automatically included by profile_xcat::master
class profile_xcat::master::bmc_smtp {

  include ::xinetd

  #Check for defined bind address
  $ipmi_bind_ip = lookup( 'profile_xcat::ipmi_bind_ip', String, 'first', undef )

  #If defined set the bind IP and verify the correct IP address
  if ( $ipmi_bind_ip != undef ) {
    if ( $ipmi_bind_ip =~ Stdlib::IP::Address::V4 ) {
      $bind_ip = $ipmi_bind_ip
    } else {
      notify{'$ipmi_bind_ip is not a valid IP address': }
    }
  }
  #Discover the IP address from puppet facts
  else {
    # Get IPMI network CIDR
    $ipmi_networks = lookup( 'profile_xcat::ipmi_net_cidrs', Array )
    $ipmi_networks.each | $cidr | {
      # Validate proper network address for IPMI network
      $tgt_net = ip_address( ip_network( $cidr ) )

      # Check all local ip's if any match one of the $ipmi_networks
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
