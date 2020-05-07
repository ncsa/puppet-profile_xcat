# @summary Setup root account
#
# Setup root account
#
# Automatically included by profile_xcat::master
#
# @param sshkey_pub
#   Public part of root's sshkey.
#
#   Installed on all client nodes for passwdless access from xcat mn
#
# @param sshkey_priv
#    Private part of root's sshkey.
#
# @param sshkey_type
#    Currently, xcat supports only rsa sshkeys.
#
#    Sshkeys are stored in /root/id_<TYPE>* files
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
