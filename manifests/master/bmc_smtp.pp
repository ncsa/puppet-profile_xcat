# @summary Setup xinetd to allow forwarding email from node BMC's to MDA on local (master) node
#
# Setup xinetd to allow forwarding email from node BMC's to MDA on local (master) node
#
# @param enable_bmc_smtp
#   Enable/disable the xinetd service allowing xcat nodes to send to xcat master.
#
# Automatically included by profile_xcat::master
class profile_xcat::master::bmc_smtp (
  Boolean $enable_bmc_smtp,
) {

  $xinetd_svc_name = 'bmc_smtp'
  $svc_file_path = "/etc/xinetd.d/${xinetd_svc_name}"

  if ($enable_bmc_smtp) {

    include ::xinetd

    #Check for defined bind address
    $ipmi_bind_ip = lookup( 'profile_xcat::ipmi_bind_ip', undef, undef, undef )

    #If defined set the bind IP and verify the correct IP address
    if ( $ipmi_bind_ip != undef ) {
      if ( $ipmi_bind_ip =~ Stdlib::IP::Address::V4 ) {
        $bind_ip = $ipmi_bind_ip
      } else {
        $bind_ip = ''
        notify{'$ipmi_bind_ip is not a valid IP address': }
      }
    } else {
      #Discover the IP address from puppet facts
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

    ::xinetd::service { $xinetd_svc_name:
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

  } else {
    # Make sure xinetd service is absent

    # Really ugly way since we can't include ::xinetd::service without
    # it enforcing xinetd is running
    exec { 'rm_svc_file_and_restart':
      path    => ['/bin', '/usr/bin'],
      command => "rm ${svc_file_path}; systemctl restart xinetd",
      onlyif  => "test -e ${svc_file_path}",

    }
  }
}
