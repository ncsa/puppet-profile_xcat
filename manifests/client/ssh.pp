# @summary Allow passwdless root access from admin bastions
#
# Allow passwdless root access from admin bastions
#
# Automatically included by profile_xcat::client
class profile_xcat::client::ssh {
  # Get admin bastion node info
  $admin_bastions = lookup ( 'profile_xcat::admin_bastions' )

  # Open firewall, sshd, etc. and add authorized keys.

  $sshd_params = {
    'PubkeyAuthentication'  => 'yes',
    'PermitRootLogin'       => 'without-password',
    'AuthenticationMethods' => 'publickey',
    'Banner'                => 'none',
  }

  $admin_bastions.each | $ip, $pubkey | {
    ::sshd::allow_from { "profile_xcat-client-ssh-${ip}":
      hostlist                => [$ip],
      users                   => [root],
      additional_match_params => $sshd_params,
    }

    $pubkey_parts = split( $pubkey, ' ' )
    $key_type = $pubkey_parts[0]
    $key_data = Sensitive( $pubkey_parts[1] )
    $key_name = $pubkey_parts[2]

    ssh_authorized_key { $key_name :
      ensure  => present,
      user    => 'root',
      type    => $key_type,
      key     => $key_data,
      options => ["from=\"${ip}\""],
    }
  }
}
