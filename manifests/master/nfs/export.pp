# @summary Limit an nfs export of "mountpoint" to a specific "network"
#
# @param mount_point
#   The local mount point that is being exported
#
# @param network
#   The network CIDR to be allowed access
#
# @param options
#   NFS export options
#
# @example
#   profile_xcat::master::nfs::export { 'namevar': }
define profile_xcat::master::nfs::export (
  String $mount_point,
  String $network,
  Array  $options,
) {
  # Create a list of change strings for each mount point
  $dir = "defnode tgtdir dir[. = '${mount_point}'] ${mount_point}"
  $from = "defnode client \$tgtdir/client[. = '${network}'] ${network}"

  # loop through options list, create a list of change strings for augeas
  $opts_changes = $options.reduce([]) |$ary, $opt| {
    # Augeas /etc/exports option identifiers start with 1 (not zero)
    $i = length( $ary ) + 1
    $new_change = "set \$client/option[${i}] ${opt}"
    # append new change string to ary; this is the return value for the next
    # iteration
    $ary + [$new_change]
  }

  # merge all change strings into a single array
  $changes = [$dir] + [$from] + $opts_changes

  # Apply changes (options) to the nfs exports file
  augeas { "profile_xcat::master::nfs::export: limit nfs export of '${mount_point}' to network '${network}'" :
    context => '/files/etc/exports',
    changes => $changes,
  }
}

#    # The above code will generate Puppet code like below
#    # $mount_point=/tftpboot
#    # $network=192.168.180.0/23
#    # $options=[ 'rw', 'no_root_squash', 'sync', 'no_subtree_check' ]
#    augeas { 'limit /tftpboot nfs export to mgmt net':
#        context => '/files/etc/exports',
#        changes => [
#            "defnode tgtdir dir[. = '/tftpboot'] /tftpboot",
#            "defnode client $tgtdir/client[. = '192.168.180.0/23'] 192.168.180.0/23",
#            "set $client/option[1] rw",
#            "set $client/option[2] no_root_squash",
#            "set $client/option[3] sync",
#            "set $client/option[4] no_subtree_check",
#        ],
#    }
#    # See also:
#    # https://puppet.com/docs/puppet/5.5/resources_augeas.html
