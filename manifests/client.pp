# @summary Setup access from xcat master to xcat client
#
# @example
#   include profile_xcat::client
class profile_xcat::client {
    include ::xcat::client::ssh
}
