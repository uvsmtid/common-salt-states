#!/bin/sh

# This is just a script to make development and testing of
# bootstrap script more convenient and faster.
#
# # Whish #
# In ideal short turnaround "change and test" cycle, one should be able
# to (1) change sources and (2) run them in just these two quick steps.
#
# # Problem #
# Writing all generated content under directories managed by SCM (i.e. Git,
# Subversion) polutes search results across sources and makes clean up
# attention-required process (to avoid mistakenly cleaning up important
# changes).
#
# # Solution #
# In order to separate sources from generated content while still
# keeping "change and test" cycle a two-command process, this script
# encapsulates all parameters and actions into a single command:
# * Loads repeatedly used set of arguments to boostrap script from
#   `run_bootstrap.args` file.
# * Sync remote host to run bootstrap script there.
#   First, sync content directory (with the lates generated content).
#   Then source directory on top of that (to use latest sources).
# * Run script on remote host.

set -e
set -u
set -x

# The arguments are:
# $1 - SSH address, for example: vagrant@192.168.50.101
# $2 - bootstrap action, for example: deploy
# $3 - bootstrap use case, for example: initial-master
# $4 - bootstrap target environment config file, relative to `bootstrap.dir`,
#      for example:
#        conf/examples/uvsmtid/centos-5.5-minimal.py
# $5 - (optional) override `bootstrap.dir` location (for everything
#      except sources) to specified location

# If no arguments, then they are supplied in the file.
if [ ${#} -eq 0 ]
then
    # Call itself.
    ./run_bootstrap.sh $(cat ./run_bootstrap.args)
    exit $?
fi

SSH_DST="${1}"
shift

# Determine override `bootstrap.dir` (or use default - no override).
CONTENT_DIR="${4:-'bootstrap.dir'}"

# Copy SSH public key right away (to avoid typing passwords ever).
ssh-copy-id "${SSH_DST}"

# Note the use of trailing slashes in path for rsync.
# 1. Sync content directory with destination.
rsync --progress -v -r "${CONTENT_DIR}/" "${SSH_DST}:bootstrap.dir/"
# 2. Sync sources directory with destination.
rsync --progress -v -r "./bootstrap.dir/" "${SSH_DST}:bootstrap.dir/"

# Run without argument which overrides `bootstrap.dir`.
# Script should run "production way" on remote host.
# Both latest sources and contnet have just been merged in two syncs above.
# Becides this, local overrides do not exist remotely.
# See:
#   http://stackoverflow.com/a/20401782/441652
# Use `python -m trace -t bootstrap/bootstrap.py` for extensive traces.
ssh "${SSH_DST}" "sudo python bootstrap.dir/bootstrap.py" "${@:1:${#}-1}"

###############################################################################
# EOF
###############################################################################

