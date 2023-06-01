# @summary Configure xCAT master backups
#
# @example
#   include profile_xcat::master::backup
class profile_xcat::master::backup {
  if ( lookup('profile_backup::client::enabled') ) {
    include profile_backup::client

    profile_backup::client::add_job { 'profile_xcat':
      paths            => [
        '/etc/xcat',
        '/install/bin',
        '/install/custom',
        '/install/files',
        '/install/host_specific',
        '/install/postinstall',
        '/install/postscripts',
        '/root/imagebuilds',
        '/root/xcat-tools/conf',
        '/var/backups/xcat',
      ],
      prehook_commands => [
        '/root/xcat-tools/cron_scripts/backup-node_configs.sh',
        '/root/xcat-tools/cron_scripts/backup-xcat.sh',
      ],
    }
  }
}
