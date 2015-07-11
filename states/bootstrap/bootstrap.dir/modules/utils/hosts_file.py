#!/usr/bin/python
#
# Description:
#   This script is used to verify consistency and patch (destination) /etc/hosts
#   file based on some sample (source) file.
#
#   It supports two operations:
#   - diff  - show missing, unexpected and modified entries
#   - patch - append missing entries
#
# Added by:
#   Alexey Pakseykin
# Added on:
#   2013-06-11
#

import os
import sys
import re
import shutil
import tempfile
import optparse
import tempfile
import filecmp
from datetime import datetime

default_src_path = None
default_dst_path = "/etc/hosts"

###############################################################################
# Print error message

def print_err(err_message):
    print >> sys.stderr, err_message

###############################################################################
# Create backup for the source file

def do_backup(dst_path, dst_dir_path = None):

    # If destination backup directory is not specified, use temporay one.
    # NOTE: Another default option could be basedir of `dst_path`.
    if not dst_dir_path:
        dst_dir_path = tempfile.gettempdir()

    assert(os.path.isdir(dst_dir_path))

    # Name destination backup file
    backup_dst_path = os.path.join(
        dst_dir_path,
        os.path.basename(dst_path) + ".backup." + datetime.now().strftime("%Y-%m-%dT%H-%M-%S"),
    )

    # Check if `*.backup.last` exists and has the same checksum.
    # If yes & yes, backup is not required.
    last_backup_dst_path = os.path.join(
        dst_dir_path,
        os.path.basename(dst_path) + ".backup." + "last"
    )
    if os.path.exists(last_backup_dst_path):
        if filecmp.cmp(dst_path, last_backup_dst_path, shallow = False):
            print_err("Skip backup - file \"" + last_backup_dst_path + "\" is the same")
            return

    # Copy file
    print_err("Backing up \"" + dst_path + "\" host to \"" + backup_dst_path + "\"")
    shutil.copyfile(dst_path, backup_dst_path)

    # Create last backup.
    shutil.copyfile(backup_dst_path, last_backup_dst_path)

###############################################################################
# Map each host name into its IP address

def do_map(filepath):

    stripr = '^\s*(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+([^#]*).*$'
    hosts_map = {}

    hosts = open(filepath, 'r')

    try:

        for line in hosts:

            # Select only lines which matter and strip comments
            m = re.match(stripr, line)
            if m:
                ipaddress = m.group(1)
                hostnames = m.group(2)
                # Map hosts into its address
                for hostname in hostnames.split():
                    hostname = hostname.strip()
                    if hostname in hosts_map.keys():
                        print_err("Warning: ignoring duplicated hostname \"" + hostname + "\" in \"" + filepath + "\"")
                        # Note that if the same hostname is mentioned later in /etc/hosts, only the first entry is used.
                        continue
                    else:
                        hosts_map[hostname] = ipaddress

    finally:
        hosts.close()

    return hosts_map

###############################################################################
#

def test_case():

    # Create source
    src = """
    127.0.0.1 host1 host2
    127.0.0.2 host3
    #127.0.0.3 host 4

    """

    # Create destination
    dst = """"
    127.0.0.3 host3 host1
    127.0.0.4 host4
    """

    # Prepare files
    src_desc, src_path = tempfile.mkstemp()
    dst_desc, dst_path = tempfile.mkstemp()
    os.write(src_desc, src)
    os.write(dst_desc, dst)
    os.fdopen(src_desc).close()
    os.fdopen(dst_desc).close()

    # Run
    # - get orig data "diff" and "patch" will use
    src_map = do_map(src_path)
    dst_map = do_map(dst_path)
    # - note that there are missing hosts
    orig_missing_keys = list(set(src_map.keys()) - set(dst_map.keys()))
    assert len(orig_missing_keys) != 0
    # - note that there are unexpected hosts
    orig_unexpected_keys = list(set(dst_map.keys()) - set(src_map.keys()))
    assert len(orig_unexpected_keys) != 0
    # - run "diff" to show output
    do_diff(src_path, dst_path)
    # - run "patch"
    do_patch(src_path, dst_path)
    # - get patched data "diff" and "patch" will use
    src_map = do_map(src_path)
    dst_map = do_map(dst_path)
    # - note that there are no missing hosts
    patched_missing_keys = list(set(src_map.keys()) - set(dst_map.keys()))
    assert len(patched_missing_keys) == 0
    # - note that there are still the same unexpected hosts
    patched_unexpected_keys = list(set(dst_map.keys()) - set(src_map.keys()))
    assert len(patched_unexpected_keys) == len(orig_unexpected_keys)
    for map_key in orig_unexpected_keys:
        assert map_key in patched_unexpected_keys

###############################################################################
# Produce difference between source and destination

def do_diff(
    src_path,
    dst_path,
    check_missing = True,
    check_unexpected = True,
    check_modified = True,
):

    src_map = do_map(src_path)
    dst_map = do_map(dst_path)

    # Check requested check found differences (True) or not (False)
    return_code = False

    # Show missing hosts in destination
    if check_missing:
        print
        print "########################################"
        print "# Hosts missing in \"" + dst_path + "\":"
        missing_keys = set(src_map.keys()) - set(dst_map.keys())
        for map_key in missing_keys:
            print src_map[map_key] + " " + map_key
            return_code = True

    # Show unexpected hosts in destination
    if check_unexpected:
        print
        print "########################################"
        print "# Hosts unexpected in \"" + dst_path + "\":"
        unexpected_keys = set(dst_map.keys()) - set(src_map.keys())
        for map_key in unexpected_keys:
            print dst_map[map_key] + " " + map_key
            return_code = True

    # Show hosts with different IP address in destination
    if check_modified:
        common_keys = set(src_map.keys()) & set(dst_map.keys())
        print
        print "########################################"
        print "# Hosts modified in \"" + dst_path + "\":"
        for map_key in common_keys:
            if dst_map[map_key] != src_map[map_key]:
               print dst_map[map_key] + " " + map_key + " # <= current address in \"" + dst_path + "\", expected as in \"" + src_path + "\": " + src_map[map_key]
               return_code = True

    if check_missing or check_unexpected or check_modified:
        print
        print "########################################"

    return return_code

###############################################################################
# Patch destination by adding missing entries from source

def do_patch(src_path, dst_path):

    src_map = do_map(src_path)
    dst_map = do_map(dst_path)

    # Backup destination first
    do_backup(dst_path)

    # Append to destination
    dst_file = open(dst_path, 'a')

    try:

        missing_keys = set(src_map.keys()) - set(dst_map.keys())
        for map_key in missing_keys:
            print_err("Appending \"" + map_key + "\" host to \"" + dst_path + "\"")
            print >> dst_file, ""
            print >> dst_file, "# \"" + map_key +"\" added automatically from \"" + src_path + "\":"
            print >> dst_file, src_map[map_key] + " " + map_key

    finally:
        dst_file.close()

###############################################################################
# MAIN

# Execute futher only if this file is executed as a script (not imported
# as a module).
if __name__ == '__main__':

    # Parser to provide help
    optparser = optparse.OptionParser(
        "usage: %prog {patch, diff} [options]"
    )
    optparser.add_option(
        "-s",
        "--src",
        dest="src-path",
        help = "Source host file (lists \"officially\" expected hosts), default = " + str(default_src_path),
        metavar = "src",
        default = default_src_path,
    )
    optparser.add_option(
        "-d",
        "--dst",
        dest="dst-path",
        help = "Destination host file (lists currently configured hosts), default = " + str(default_dst_path),
        metavar = "dst",
        default = default_dst_path,
    )
    optparser.add_option(
        "--missing",
        help = "Ask explicitly to review missing hosts in destination",
        action="store_true",
        default=False,
    )
    optparser.add_option(
        "--unexpected",
        help = "Ask explicitly to review unexpected hosts in destination",
        action="store_true",
        default=False,
    )
    optparser.add_option(
        "--modified",
        help = "Ask explicitly to review modified hosts in destination",
        action="store_true",
        default=False,
    )
    (options, args) = optparser.parse_args()

    if len(args) == 1:
        command = sys.argv.pop(1).strip()
    else:
        optparser.error("Single argument (command) is expected")

    # If none of the options related to discrepancies is specified, assume all
    if (not options.missing) and (not options.unexpected) and (not options.modified):
        options.missing = True
        options.unexpected = True
        options.modified = True

    if command == "test":

        test_case()

    elif command == "diff":

        if do_diff(
            options.src_path,
            options.dst_path,
            check_missing = options.missing,
            check_unexpected = options.unexpected,
            check_modified = options.modified,
        ):
            # Some differences exist
            sys.exit(1)
        else:
            # No differences found
            sys.exit(0)

    elif command == "patch":

        do_patch(options.src_path, options.dst_path)

    elif command == "map":

        print str(do_map(options.dst_path))

    else:
        optparser.error("Unknown command \"" + command + "\"")

###############################################################################
# EOF
###############################################################################

