#!/bin/sh
# This script works on Windows inside Cygwin and imports all environment
# variables into user session. This is only needed for SSH user session
# because SSH daemon strips environment of any unnecessary variables.

# Even though the following answer suggests that system environment is
# available in SSH session. Tests with restarted SSH daemon running in
# current user session did not confirm it - it simply didn't work:
#   http://superuser.com/a/547111/176657
# The script, howerver, works regardless of where variable is set.

# NOTE: After testing it was noticed that environment is additionally
#       affected by SSH depending whether or not tty is allocated.
#       If no tty is allocated, shell probably does not execute some
#       startup scripts.

# 2014-07-22:
# Force loading the variables to let CI platform access them.
# In Jenkins environment, SSH_TTY is undefined.
#if [ "$SSH_TTY" ]
if true
then
    pushd . 1> /dev/null

    for __dir in \
        '/proc/registry/HKEY_LOCAL_MACHINE/SYSTEM/CurrentControlSet/Control/Session Manager/Environment' \
        '/proc/registry/HKEY_CURRENT_USER/Environment' \

    do
        cd "$__dir"
        for __var in *
        do
            __var=`echo $__var | tr '[a-z]' '[A-Z]'`
            test -z "${!__var}" && export $__var="`cat $__var`" 1> /dev/null
        done
    done

    unset __dir
    unset __var

    popd 1> /dev/null
fi

