#!/bin/sh

# This is just a script to speed up testing of bootstrap script:
# * Sync current directory with destination.
# * Run script on remote host.

set -e
set -u
set -x

# The arguments are:
# $1 - SSH address, for example: vagrant@192.168.50.101
# $2 - bootstrap action, for example: deploy
# $3 - bootstrap use case, for example: initial-master
# $4 - bootstrap target environment, for example: examples/uvsmtid/centos-5.5-minimal

# If no arguments, then they are supplied in the file.
if [ $# -eq 0 ]
then
    # Call itself.
    ./run_bootstrap.sh $(cat ./run_bootstrap.args)
    exit $?
fi

SSH_DST="${1}"
shift

# Copy SSH public key right away .
ssh-copy-id "${SSH_DST}"

# Sync current directory with destination.
rsync --progress -v -r ./ "${SSH_DST}:bootstrap/"

# Use `python -m trace -t bootstrap/bootstrap.py` for extensive traces.
ssh "${SSH_DST}" "sudo python bootstrap/bootstrap.py" "$@"

###############################################################################
# EOF
###############################################################################

