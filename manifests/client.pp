# @summary Setup access from xcat master to xcat client
#
# Setup access from xcat master to xcat client
#
# @example
#   include profile_xcat::client
class profile_xcat::client {
  include profile_xcat::client::ssh
}
