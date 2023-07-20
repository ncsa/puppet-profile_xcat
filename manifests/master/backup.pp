# @summary Configure xCAT master backups
#
# @param locations
#   files and directories that are to be backed up
#   include profile_xcat::master::backup
#
class profile_xcat::master::backup (
  Array[String]     $locations,
) {
  if ( lookup('profile_backup::client::enabled') ) {
    include profile_backup::client

    profile_backup::client::add_job { 'profile_xcat':
      paths            => $locations,
      prehook_commands => [
        '/root/xcat-tools/cron_scripts/backup-node_configs.sh',
        '/root/xcat-tools/cron_scripts/backup-xcat.sh',
      ],
    }
  }
}
