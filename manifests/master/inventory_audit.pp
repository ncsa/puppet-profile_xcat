# @summary Control/configure audits for xcat booted nodes
#   Audits will collect information about the nodes, and save them to a directory locally on the xcat server.
#
#   Optionally, audits can be setup to run via  cron, and a difference report from the last audit can then
#   be emailed
#
# @param cfg_audit_script
#   Path to script used to generate audit (script expected to be on the host(s) being audited
#
# @param cfg_cluster
#   Name for the Cluster, used in the subject when email reports are enabled
#
# @param cfg_mail_to
#   Address to email results of audit comparisons
#
# @param cfg_module_dirs
#   List of directories to search for module files
#
#   File globs recognized by 'find' are allowed, Ex: /sw/apps/private/*/modules/
#
# @param cfg_module_host
#   Hostname to perform the module listing from
#
# @param cfg_nodes_to_audit
#   List of nodes to include in audit (nodes in excludenodes from xcat site table are automatically ignored)
#
#   Can list xcat groups, individual nodes, or individual node ranges.
#   Syntax for a range should match what you'd pass to nodels, ex: node[1-4]
#    
# @param cfg_nodes_to_ignore
#   List of nodes to ignore from audit (nodes in excludenodes from xcat site table are automatically ignored)
#
#   Can list xcat groups, individual nodes, or individual node ranges.
#   Syntax for a range should match what you'd pass to nodels, ex: node[1-4]
#
# @param cron_audit_args
#   Arguments to use when running the inventory_audit via cron. These args can enable/disable emailing the results
#   of comparisons, as well as enable/disable auditing the list of modules installed
#
# @param cron_enable
#   Enable/disable running the inventory_audit via cron
#
# @param cron_hour
#   Hour to run inventory_audit cron
#
# @param cron_minute
#   Minute to run inventory_audit cron
#
# @param cron_month
#   Month to run inventory_audit cron
#
# @param cron_monthday
#   Monthday to run inventory_audit cron
#
# @param cron_weekday
#   Weekday to run inventory_audit cron
#
# @example
#   include profile_xcat::master::inventory_audit
class profile_xcat::master::inventory_audit (
  String        $cfg_audit_script,
  String        $cfg_cluster,
  String        $cfg_mail_to,
  Array[String] $cfg_module_dirs,
  String        $cfg_module_host,
  Array[String] $cfg_nodes_to_audit,
  Array[String] $cfg_nodes_to_ignore,
  String        $cron_audit_args,
  Boolean       $cron_enable,
  String        $cron_hour,
  String        $cron_minute,
  String        $cron_month,
  String        $cron_monthday,
  String        $cron_weekday,
) {
  # Setup directory
  $audit_dir = '/root/inventory_audit'
  $dir_defaults = {
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0700',
  }
  ensure_resource( 'file', $audit_dir, $dir_defaults)

  $file_defaults = {
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0750',
    require => File[$audit_dir],
  }

  # Audit script
  file { "${audit_dir}/audit.sh":
    source => "puppet:///modules/${module_name}/audit.sh",
    *      => $file_defaults,
  }

  # Add a - in front of each item in $cfg_nodes_to_ignore
  $audit_ignore_list = $cfg_nodes_to_ignore.map |$n| { "-${n}" }

  $cfg_audit_node_string = ($cfg_nodes_to_audit + $audit_ignore_list).join(',')

  # Audit config file
  $audit_conf = {
    cfg_audit_dir         => $audit_dir,
    cfg_audit_node_string => $cfg_audit_node_string,
    cfg_audit_script      => $cfg_audit_script,
    cfg_cluster           => $cfg_cluster,
    cfg_mail_to           => $cfg_mail_to,
    cfg_module_dirs       => $cfg_module_dirs,
    cfg_module_host       => $cfg_module_host,
  }
  file { "${audit_dir}/audit.conf":
    content => epp("${module_name}/audit.conf.epp", $audit_conf),
    *       => $file_defaults,
  }

  # Compare script
  file { "${audit_dir}/compare_audit.sh":
    source => "puppet:///modules/${module_name}/compare_audit.sh",
    *      => $file_defaults,
  }

  if ($cron_enable) {
    $ensure_parm = 'present'
  } else {
    $ensure_parm = 'absent'
  }

  # Config cron
  cron { 'inventory_audit':
    ensure      => $ensure_parm,
    user        => 'root',
    hour        => $cron_hour,
    minute      => $cron_minute,
    month       => $cron_month,
    monthday    => $cron_monthday,
    weekday     => $cron_weekday,
    environment => ['SHELL=/bin/sh',],
    command     => "${audit_dir}/audit.sh ${cron_audit_args}",
  }
}
