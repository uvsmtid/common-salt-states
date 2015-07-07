
# This file was originally used to set specific environment variables
# for Vagrant. However, there were only `http_proxy` and `https_proxy`
# variables here. It turned out they are generic and used by many
# other tools (including `wget` and `dnf` - replacement of `yum`).
# So, they were moved to `common.custom.variables.sh` instead.
#
# Note that, unfortunately,  similar settings in Vagrantfile
# do not work (with trailing slash or without):
#   config.proxy.http     = "http://username:password@example.com:8000"
#   config.proxy.https    = 'http://username:password@example.com:8000"
#
# NOTE: You will still have to use `--insecure` option to download box:
#         vagrant box add uvsmtid/centos-7.0-minimal --insecure

# Add Vagrant-specific environment variables here.

