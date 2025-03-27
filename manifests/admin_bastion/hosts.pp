# @summary Sync /etc/hosts from the xCAT master node.
#
# Sync /etc/hosts from the xCAT master node.
#
# Automatically included by profile_xcat::admin_bastion
#
# @param cron_data
#   Hash of data to configure the cron to run the hosts sync script.
#
# @param cron_enable
#   Enable/disable running script via cron.
#
# @param script_sync_hosts
#   Path to script to sync /etc/hosts from the xCAT master.
#
class profile_xcat::admin_bastion::hosts (
  Hash    $cron_data,
  Boolean $cron_enable,
  String  $script_sync_hosts,
) {
  # Config cron

  $master_node_hostname = lookup ( 'profile_xcat::master_node_hostname' )

  # Manage scripts.
  File {
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    require => File['/root/cron_scripts'],
  }

  file { $script_sync_hosts:
    content => template('profile_xcat/script_sync_hosts.erb'),
  }

  if ($cron_enable) {
    $ensure_parm = 'present'
  } else {
    $ensure_parm = 'absent'
  }

  cron { 'profile_xcat-admin_bastion-hosts':
    ensure  => $ensure_parm,
    command => $script_sync_hosts,
    *       => $cron_data,
  }
}
