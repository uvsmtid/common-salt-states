# Disable any power savings on Windows.
#
# Otherwise on KVM/libvirtd, if it goes to sleep, it cannot wakeup.
# See also:
#   http://stackoverflow.com/a/258777/441652
# And even if this is not a problem anymore, there is another one -
# VM simply keeps switching off due to idle state right during
# a remote SSH session.

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

# Nothing to do.

{% endif %}
# >>>
###############################################################################

###############################################################################
# [[[
{% if grains['os_platform_type'].startswith('win') %}

disable_monitor_timeout_ac:
    cmd.run:
        - name: 'C:\Windows\System32\cmd.exe /c powercfg.exe -change -monitor-timeout-ac 0'

disable_disk_timeout_ac:
    cmd.run:
        - name: 'C:\Windows\System32\cmd.exe /c powercfg.exe -change -disk-timeout-ac 0'

disable_standby_timeout_ac:
    cmd.run:
        - name: 'C:\Windows\System32\cmd.exe /c powercfg.exe -change -standby-timeout-ac 0'

disable_hibernate_timeout_ac:
    cmd.run:
        - name: 'C:\Windows\System32\cmd.exe /c powercfg.exe -change -hibernate-timeout-ac 0'

{% endif %}
# ]]]
###############################################################################


