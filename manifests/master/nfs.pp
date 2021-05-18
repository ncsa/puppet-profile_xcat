# @summary Harden NFS settings on xcat-master
#
# Harden NFS settings on xcat-master
#
# Allow NFS exports only to known management networks
#
# Automatically included by profile_xcat::master
class profile_xcat::master::nfs {

  $mgmt_networks = lookup( 'profile_xcat::mgmt_net_cidrs', Array )

  $common_options = [ 'rw', 'no_root_squash', 'sync', 'no_subtree_check' ]

  $mount_points = {
    '/tftpboot' => $common_options,
    '/install'  => $common_options,
  }

  $mgmt_networks.each | $net | {
    $mount_points.each | $mount, $opts | {
      $uniq_name="${module_name} export '${mount}' to network '${net}'"
      profile_xcat::master::nfs::export { $uniq_name :
        mount_point => $mount,
        network     => $net,
        options     => $opts,
      }
    }
  }
}
