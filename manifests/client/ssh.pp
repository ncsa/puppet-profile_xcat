# @summary Allow passwdless root access from xcat master node
#
# Allow passwdless root access from xcat master node
#
# Automatically included by profile_xcat::master
class profile_xcat::client::ssh {

  # Get xcat master node info
  $pubkey = lookup( 'profile_xcat::master::root::sshkey_pub' )
  $master_node_ip = lookup( 'profile_xcat::master_node_ip' )

  # Open firewall and configure sshd_config
  $params = {
    'PubkeyAuthentication'  => 'yes',
    'PermitRootLogin'       => 'without-password',
    'AuthenticationMethods' => 'publickey',
    'Banner'                => 'none',
  }
  if $master_node_ip =~ String[1] {
    ::sshd::allow_from{ 'profile_xcat-client-ssh':
      hostlist                => [ $master_node_ip ],
      users                   => [ root ],
      additional_match_params => $params,
    }
  }

  # Authorize root's public key (from xcat master node)
  if $pubkey =~ String[1] {
    $pubkey_parts = split( $pubkey, ' ' )
    $key_type = $pubkey_parts[0]
    $key_data = Sensitive( $pubkey_parts[1] )
    $key_name = $pubkey_parts[2]

    ssh_authorized_key { $key_name :
      ensure => present,
      user   => 'root',
      type   => $key_type,
      key    => $key_data,
    }
  }

}
