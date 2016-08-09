#!/bin/sh

# This script wraps `vagrant` command into proper environment.
#
# There are various valid and invalid issues using `vagrant` with
# `http_proxy` and `https_proxy` environment variables set, for example:
#     https://github.com/WinRb/WinRM/issues/208#issuecomment-234143484
# And trivial case is that some connections should be established
# directly (not via proxy), for example, when private Vagrant box hosting
# is used.
#
# This script is generated based on system configuration to either leave
# or set `http_proxy` and `https_proxy` environment variables.
#
# It passess all arguments to `vagrant` directly without modification.
#

set -e
set -u

{% if pillar['properties']['use_local_vagrant_box_publisher'] %}
unset http_proxy
unset https_proxy
{% endif %}

vagrant "${@}"

