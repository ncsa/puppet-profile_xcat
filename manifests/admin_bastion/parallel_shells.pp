# @summary Install and configure parallel shells with config synced from the xCAT node.
#
# Install and configure parallel shells with config synced from the xCAT node.
#
# Automatically included by profile_xcat::admin_bastion
#
# @param cron_data
#   Hash of data to configure the cron to run sync scripts.
#
# @param cron_enable
#   Enable/disable running scripts via cron.
#
# @param file_config_genders
#   Location of genders config file.
#
# @param packages_clustershell
#   Packages required for clustershell (clush).
#
# @param packages_genders
#   Packages required for genders.
#
# @param packages_pdsh
#   Packages required for pdsh.
#
# @param script_install_configs
#   Path to script to install configs that have been synced from the master node.
#
# @param script_sync_configs
#   Path to script to sync configs from master node.
#
class profile_xcat::admin_bastion::parallel_shells (
  Hash          $cron_data,
  Boolean       $cron_enable,
  String        $file_config_genders,
  Array[String] $packages_clustershell,
  Array[String] $packages_genders,
  Array[String] $packages_pdsh,
  String        $script_install_configs,
  String        $script_sync_configs,
) {
  # Install packages
  Package {
    ensure => installed,
  }
  ensure_packages( $packages_clustershell )
  ensure_packages( $packages_genders )
  ensure_packages( $packages_pdsh )

  # Manage scripts.
  File {
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
  }
  $master_node_hostname = lookup ( 'profile_xcat::master_node_hostname' )
  $temp_config_genders = lookup ( 'profile_xcat::master::group_export::temp_config_genders' )
  file { $script_sync_configs:
    content => template('profile_xcat/script_sync_parallel_shell_configs.erb'),
    require => File['/root/cron_scripts'],
  }
  file { $script_install_configs:
    content => template('profile_xcat/script_install_parallel_shell_configs.erb'),
    require => File['/root/cron_scripts'],
  }

  # Manage cron
  if ($cron_enable) {
    $ensure_parm = 'present'
  } else {
    $ensure_parm = 'absent'
  }

  cron { 'profile_xcat-admin_bastion-parallel_shells_sync':
    ensure  => $ensure_parm,
    command => "${script_sync_configs} && ${script_install_configs}",
    *       => $cron_data,
  }

  # Manage static parallel shell config files

  ## clustershell / clush
  $config_dir = '/root/.config'
  $clustershell_config_dir = "${config_dir}/clustershell"
  file { $config_dir:
    ensure => directory,
  }

  ensure_resource('file', $config_dir, { ensure => directory })
  ensure_resource('file', $clustershell_config_dir, { ensure => directory })
  file { "${clustershell_config_dir}/groups.conf":
    source => "puppet:///modules/${module_name}/groups.conf",
  }

  ## pdsh
  file { '/etc/profile.d/pdsh.sh':
    mode   => '0644',
    source => "puppet:///modules/${module_name}/pdsh.sh",
  }
}
