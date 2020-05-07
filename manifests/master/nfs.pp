# @summary Harden NFS settings on xcat-master
#
# Harden NFS settings on xcat-master
#
# Allow exports only on the mgmt network
#
# Automatically included by profile_xcat::master
class profile_xcat::master::nfs {

    $mgmt_network = lookup( 'profile_xcat::mgmt_net_cidr', String[11] )

    $common_options = [ 'rw', 'no_root_squash', 'sync', 'no_subtree_check' ]

    $mount_points = { '/tftpboot' => $common_options,
                      '/install'  => $common_options,
                    }

    #
    # Create a list of change strings for each mount point
    $changes_map = $mount_points.reduce({}) |$memo, $tuple| {
        $mount = $tuple[0]
        $dir = "set dir[. = '${mount}'] ${mount}"
        $from = "set dir[. = '${mount}']/client ${mgmt_network}"
        $opts_list = $tuple[1]
        # loop through options list, create a list of change strings for augeas
        $opts_changes = $opts_list.reduce([]) |$ary, $opt| {
            # Augeas /etc/exports options are 1-based
            $i = length( $ary ) + 1
            $new_change = "set dir[. = '${mount}']/client/option[${i}] ${opt}"
            # return merge of ary and new change string
            $ary + [ $new_change ]
        }
        # merge all change strings into a single array
        $changes = [ $dir ] + [ $from ] + $opts_changes
        # return merge of memo with new hash key and value
        $memo + { $mount => $changes }
    }

    # Loop through mountpoints and apply changes (options) for each
    $changes_map.each |$mount, $changes| {
        augeas { "profile_xcat master: limit nfs export of '${mount}' to mgmt network '${mgmt_network}'" :
            context => '/files/etc/exports',
            changes => $changes,
        }
    }

#    # The above code will generate Puppet code like below,
#    # for each mount_point
#    augeas { 'limit /tftpboot nfs export to mgmt net':
#        context => '/files/etc/exports',
#        changes => [
#            "set dir[. = '/tftpboot'] /tftpboot",
#            "set dir[. = '/tftpboot']/client ${mgmt_network}",
#            "set dir[. = '/tftpboot']/client/option[1] rw",
#            "set dir[. = '/tftpboot']/client/option[2] no_root_squash",
#            "set dir[. = '/tftpboot']/client/option[3] sync",
#            "set dir[. = '/tftpboot']/client/option[4] no_subtree_check",
#        ],
#    }
    # See also:
    # https://puppet.com/docs/puppet/5.5/resources_augeas.html
}
