# @summary Configure an admin bastion node.
#
# Configure an admin bastion node.
#
# Includes all subordinate classes.
class profile_xcat::admin_bastion {
  include profile_xcat::admin_bastion::hosts
  include profile_xcat::admin_bastion::parallel_shells
  include profile_xcat::admin_bastion::ssh
}
