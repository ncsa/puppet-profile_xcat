# @summary Setup root account
#
# @param sshkey_pub - String
#                     public part of root's sshkey
#                     installed on all client nodes for passwdless access
#                     from xcat mn
#
# @param sshkey_priv - String
#                      private part of root's sshkey
#
# @param sshkey_type - String
#                      Currently, xcat supports only rsa
#                      sshkeys are stored in /root/id_<TYPE>* files
#                      (optional, defaults to 'rsa')
#
# @example
#   include profile_xcat::master::root
class profile_xcat::master::root (
    String $sshkey_pub,
    String $sshkey_priv,
    String $sshkey_type,
) {

    # Secure sensitive data (keep it from showing in logs)
    $pubkey = Sensitive( $sshkey_pub )
    $privkey = Sensitive( $sshkey_priv )

    # Local variables

    $sshdir = '/root/.ssh'

    $file_defaults = {
        ensure  => file,
        owner   => root,
        group   => root,
        mode    => '0600',
        require =>  File[ $sshdir ],
    }


    # Define unique parameters of each resource
    $data = {
        $sshdir => {
            ensure => directory,
            mode   => '0700',
            require => [],
        },
        "${sshdir}/id_${sshkey_type}" => {
            content => $privkey,
        },
        "${sshdir}/id_${sshkey_type}.pub" => {
            content => $pubkey,
            mode    => '0644',
        },
    }

    # Ensure the resources
    ensure_resources( 'file', $data, $file_defaults )
}
