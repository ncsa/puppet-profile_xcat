# @summary Setup access from xcat master to xcat client
#
# Setup access from xcat master to xcat client
#
# @example
#   include profile_xcat::client
class profile_xcat::client {

  $master_node_ip = lookup( 'profile_xcat::master_node_ip' )
  $my_ip = $facts['networking']['ip']

  # OK to run if this is not the xcat server
  if $master_node_ip != $my_ip {
    include ::profile_xcat::client::ssh
  }
}
