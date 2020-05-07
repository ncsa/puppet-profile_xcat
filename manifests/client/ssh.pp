# @summary Allow passwdless root access from xcat master node
#
# @param master_node_ip - String
#                         IP address of xcat master node
#
# @example
#   include profile_xcat::client::ssh
class profile_xcat::client::ssh (
    String $master_node_ip,
) {

    # Get xcat master node root public key
    $pubkey = lookup( 'profile_xcat::master::root::sshkey_pub' )

    # Open firewall and configure sshd_config
    $params = {
        'PubkeyAuthentication'  => 'yes',
        'PermitRootLogin'       => 'without-password',
        'AuthenticationMethods' => 'publickey',
        'Banner'                => 'none',
    }
    ::sshd::allow_from{ 'profile_xcat-client-ssh':
        hostlist                => [ $master_node_ip ],
        users                   => [ root ],
        additional_match_params => $params,
    }

    # Authorize root's public key (from xcat master node)
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
