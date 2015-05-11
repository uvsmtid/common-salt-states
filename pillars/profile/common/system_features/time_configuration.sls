###############################################################################
#

system_features:

    # Time configuration: NTP, timezone, etc.
    time_configuration:
        # On Linux, this is append to the tail of this path:
        #   /usr/share/zoneinfo/
        # In other words, whatever is specified here should exists under
        # the `zoneinfo` directory above.
        timezone: Asia/Singapore

        # TODO: add NTP configuration.

###############################################################################
# EOF
###############################################################################

