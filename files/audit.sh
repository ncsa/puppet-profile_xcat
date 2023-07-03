#!/bin/bash
#set -x

# This file is managed by Puppet

source "$(dirname "$0")/audit.conf"

show_help() {
    cat <<ENDHELP
Usage:

  If no CLI options are given, run an audit tied to your user account (extracted from SUDO_USER
  environment variable), and tar up the results to be copied elseware (normally pasted into slack)

  [-a|--automated]     Automated mode. Reports will be recorded as the root user
                       instead of by a specific admin. This mode is required if
                       you want to run a compare against past automated audit and
                       email the results

  [-m|--module_audit]  Audit the modules installed in addition to everything else

  [-e|--email_compare] Run audit and automatically compare the results against the previous audit
                       and email the results. Only compares audits ran in automated mode so
                       the -a|--automated flag is required for this to do anything, if left off
                       -e will be a noop

  [-v|--verbose]       Print more info

  [-h|--help]          Print this help message
ENDHELP
exit
}

croak() {
    echo "ERROR - $*"
    exit 99
}

# Usage:
# $1 : String to append to email subject line (brief status info)
# All other arguments past 1st : Arguments to print in email body, each string argument will
# get its own line, can pass "" to print an empty line
email_and_exit() {
    subject_status="${1}"
    shift
    email_message=("$@") # Feed all other arguments into array

    if [[ $verbose ]]; then
        echo -e "${subject_status} \n $(for i in "${email_message[@]}";do echo "$i"; done)"

        if lsdef  -t site -i excludenodes | grep -q excludenodes; then
            email_message=("${email_message[@]}" "" "Nodes excluded because they are in excludenodes set in site table:" "$(lsdef  -t site -i excludenodes | grep excludenodes)")
        fi

	email_message=("${email_message[@]}" "nodels argument used to build nodes to audit:" "$AUDIT_NODE_STRING") 
    fi

cat << EOF | mail -s "${MAIL_SUBJECT} - ${subject_status}" "${MAIL_TO}"
$(for i in "${email_message[@]}";do echo "$i"; done)
EOF

exit
}

# Get CLI options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -a|--automated) automated=0 ;;
        -m|--module_audit) module_audit=0 ;;
        -e|--email_compare) email_compare=0 ;;
        -v|--verbose) verbose=0 ;;
        -h|--help) show_help ;;
        *) echo "Unknown parameter passed: $1"; show_help;;
    esac
    shift
done

# Sanity checks
[[ $EUID -ne 0 ]] && croak "This script should be ran as root via sudo"
[[ -z "${SUDO_USER}" && ! $automated ]] && croak "Could not determine SUDO_USER, this script should be ran via sudo"
[[ -z "$AUDIT_SCRIPT" ]] && croak "AUDIT_SCRIPT not defined in config file"
[[ $email_compare ]] && [[ -z "$MAIL_TO" ]] && croak "Email requested but MAIL_TO not defined in config file"
if [[ $module_audit ]]; then
    [[ -z "$MODULE_HOST" ]] && croak "Module audit requested but MODULE_HOST is not defined in config file"
    [[ -z "$MODULE_DIRS" ]] && croak "Module audit requested but MODULE_DIRS is not defined in config file"
fi

mapfile -t NODES < <(/opt/xcat/bin/nodels "$AUDIT_NODE_STRING")

if [[ $automated ]]; then
    AUDIT_USER="root"
    REPORT_DST="$AUTOMATED_REPORT_DST/$DATETIME"
else
    AUDIT_USER="${SUDO_USER}"
    REPORT_DST="$BASE_REPORT_DST/$DATETIME-$AUDIT_USER"
fi


if [ ! -d "$REPORT_DST" ]
then
   echo "Saving reports to $REPORT_DST"
   mkdir -p "$REPORT_DST"
fi

if [[ $verbose ]]; then
    if lsdef  -t site -i excludenodes | grep -q excludenodes; then
        echo "Nodes ignored by being in excludenodes site table:"
        lsdef  -t site -i excludenodes | grep excludenodes
    fi

    echo "nodels argument used to build nodes to audit: $AUDIT_NODE_STRING"
fi

# List of nodes comma delimited
NODES_CSV=$(IFS=, ; echo "${NODES[*]}")
# Run audit script
/opt/xcat/bin/xdsh "${NODES_CSV}" -t 30 "$AUDIT_SCRIPT $AUDIT_USER $AUDIT_ID"

# Run module audit if requested
if [[ $module_audit ]]; then
    ssh "$MODULE_HOST" "find ${MODULE_DIRS} -type f" > "$REPORT_DST/audit-MODULES"
fi

# Not as fast as xdcp, but gets us the filenames we need
for n in "${NODES[@]}";
do
   scp "$n:/tmp/audit-${n}-${AUDIT_ID}" "$REPORT_DST/audit-${n}"
done

if [[ $automated ]]; then
    # Update symlink pointers to keep track of previous audit and current audit
    if [[ -h $AUTOMATED_REPORT_DST/current ]]; then
        [[ -h $AUTOMATED_REPORT_DST/previous ]] && unlink "$AUTOMATED_REPORT_DST/previous"
        ln -s "$(readlink -f $AUTOMATED_REPORT_DST/current)" "$AUTOMATED_REPORT_DST/previous"
        unlink "$AUTOMATED_REPORT_DST"/current
    fi
    ln -s "$REPORT_DST" "$AUTOMATED_REPORT_DST/current"

    if [[ $email_compare ]]; then
        prev=$(readlink -f "$AUTOMATED_REPORT_DST"/previous)
        curr=$(readlink -f "$AUTOMATED_REPORT_DST"/current)

        # Test if dirs exist
        [[ ! -d ${prev} || ! -d ${curr} ]] && email_and_exit "ERROR" "ERROR: One or both of these dirs did not exist when trying to compare:" "${prev}" "${curr}"

        # Run compare and save output
        COMPARE_OUTPUT=$(${COMPARE_SCRIPT} "${prev}" "${curr}") || email_and_exit "ERROR" "ERROR (exit code $?) while running:" "${COMPARE_SCRIPT} ${prev} ${curr}"

        # Test if there is no difference found
        [[ -z $COMPARE_OUTPUT ]] && email_and_exit "No Diff" "No differences detected between these audits:" "${prev}" "${curr}"

        # If we make it this far the audit ran ok and there was a difference in the audits
        email_and_exit "Diff Detected" "There was a difference detected between these audits:" "${prev}" "${curr}" "" "Difference is:" "" "${COMPARE_OUTPUT}"
    fi

else
    # Run manually, so tar up results and stash in /tmp for an admin to copy somewhere else
    HOST=$(hostname -s)
    tar -czvf "/tmp/${DATETIME}-${AUDIT_USER}_${HOST}.tgz" "$REPORT_DST"
    chown "$AUDIT_USER" "/tmp/${DATETIME}-${AUDIT_USER}_${HOST}.tgz"
    echo "A tar'd up report was saved to : /tmp/${DATETIME}-${AUDIT_USER}_${HOST}.tgz"
fi
