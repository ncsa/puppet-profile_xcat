# @summary Set up (root) ssh.
#
# Set up (root) ssh.
#
# NOTES:
# 1. The xCAT master will generally have an RSA key pair that was already set up
#    for passwordless SSH to the cluster. The private key should be included
#    here. The public key gets included in the main init.pp class in the
#    admin_bastions param. Secondary admin bastion keys can be handled in the
#    same fashion.
# 2. Generally do NOT use RSA. For some reason xCAT likes to put its public key
#    on each client at /root/.ssh/id_rsa.pub (even though it only needs to go
#    in /root/.ssh/authorized_keys). If you configure a non-corresponding
#    private key at /root/.ssh/id_rsa, ssh will generally fail because it
#    notices that the public and private keys do not match. So use an ECDSA or
#    ED25519 key instead.
#
# Automatically included by profile_xcat::admin_bastion
#
# @param private_key_content
#   Private key content - should be encrypted in EYAML.
#
# @param private_key_type
#   SSH key type, e.g., ecdsa, ed25519, or rsa.
#
class profile_xcat::admin_bastion::ssh (
  String $private_key_content,
  String $private_key_type,
) {
  # Secure sensitive data to prevent it showing in logs
  $privkey = Sensitive( $private_key_content )

  # Local variables

  $sshdir = '/root/.ssh'

  $file_defaults = {
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0600',
    require => File[$sshdir],
  }

  # Define unique parameters of each resource
  $data = {
    $sshdir => {
      ensure => directory,
      mode   => '0700',
      require => [],
    },
    "${sshdir}/id_${private_key_type}" => {
      content => $privkey,
    },
  }

  # Ensure the resources
  ensure_resources( 'file', $data, $file_defaults )
}
