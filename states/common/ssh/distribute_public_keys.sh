#!/bin/sh

set -e
set -u
set -x

HOSTNAME="$1"
USERNAME="$2"
OS_TYPE="$3"


CURRENT_USERNAME="$(whoami)"
CURRENT_HOSTNAME="$(hostname)"

if [ -z "${SSHPASS+SOME_STRING}" ]
then
    # If SSHPASS is unset, nothing is substitued - the whole string is empty ("").
    echo "SSHPASS is unset" 1>&2
else
    # If SSHPASS is set, "SOME_STRING" is substitued - the whole string is not empty.
    echo "SSHPASS is set" 1>&2
fi

# Allow using default user (current local username or from `~/.ssh/config).
# If username is empty string, no '@' is used.
SEPARATOR=""
if [ -n "$USERNAME" ]
then
    SEPARATOR="@"
fi

# Allow default OS_TYPE based on current one.
if [ -z "$OS_TYPE" ]
then
    # Only `windows` requires special treatement at the moment.
    case "$(uname)" in
        CYGWIN*)
            OS_TYPE="windows"
        ;;
        *)
            OS_TYPE="linux"
        ;;
    esac
fi

if ping -c 1 "$HOSTNAME"
then

    # Distribute by authenticating with `password_value`:
    sshpass -e ssh-copy-id \
        -o "StrictHostKeyChecking no" \
        -o "PreferredAuthentications password,publickey" \
        "${USERNAME}${SEPARATOR}${HOSTNAME}"

    # This step is required on Windows (otherwise the owner is set to
    # `Administrator` and SSH server denies public key authentication), but
    # there is nothing wrong to run it for every host:
    if [ "$OS_TYPE" == "windows" ]
    then
        sshpass -e ssh \
            -x \
            -o "StrictHostKeyChecking no" \
            -o "PreferredAuthentications password,publickey" \
            "${USERNAME}${SEPARATOR}${HOSTNAME}" \
            "chown -R $USERNAME .ssh"
    fi

    # Test with public key:
    ssh \
        -x \
        -o "StrictHostKeyChecking no" \
        -o "PreferredAuthentications publickey" \
        "${USERNAME}${SEPARATOR}${HOSTNAME}" \
        "echo CONNECTION SUCCESSFUL"

else

    echo "$HOSTNAME: offline" 1>&2
    exit 1

fi

