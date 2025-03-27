# @summary Export groups from xCAT and construct config files for other parallel shells.
#
# Export groups from xCAT and construct config files for other parallel shells
#
# @param cron_data
#   Hash of data to configure the cron to run the group export script.
#
# @param cron_enable
#   Enable/disable running scripts via cron.
#
# @param script_build_genders
#   Path for script to generate genders config.
#
# @param script_export_xcat
#   Path for script to export data from xCAT.
#
# @param temp_config_genders
#   Path for temporary generated genders config (not directly used by genders).
#
# @param temp_export_xcat
#   Path for temporary file that will contain exported info from xCAT.
#
class profile_xcat::master::group_export (
  Hash    $cron_data,
  Boolean $cron_enable,
  String  $script_build_genders,
  String  $script_export_xcat,
  String  $temp_config_genders,
  String  $temp_export_xcat,
) {
  # Manage scripts.
  File {
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    require => File['/root/cron_scripts'],
  }
  file { $script_export_xcat:
    content => template('profile_xcat/script_export_xcat.erb'),
  }
  file { $script_build_genders:
    content => template('profile_xcat/script_build_genders.erb'),
  }

  # Set cron.
  if ($cron_enable) {
    $ensure_parm = 'present'
  } else {
    $ensure_parm = 'absent'
  }

  # Config cron
  cron { 'profile_xcat-group_export':
    ensure  => $ensure_parm,
    command => "${script_export_xcat} && ${script_build_genders}",
    *       => $cron_data,
  }
}
