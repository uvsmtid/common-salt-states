
###############################################################################
#

system_platforms:

    {% for system_platform_id in [
            'fc21',
            'fc22',
            'fc23',
            'fc24',
        ]
    %}
    {{ system_platform_id }}:
        os_type: linux
    {% endfor %}

    rhel5:
        os_type: linux

    rhel7:
        os_type: linux

    win7:
        os_type: windows

###############################################################################
# EOF
###############################################################################

