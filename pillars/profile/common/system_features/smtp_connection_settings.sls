
###############################################################################
#

system_features:

    smtp_connection_settings:
        smtp_server_hostname: example.com
        smtp_server_port: 25
        sender_address: username@example.com
        smtp_authentication:
            enabled: False
            smtp_auth_username: username
            # TODO: Move password to `system_secrets`.
            smtp_auth_password: password

###############################################################################
# EOF
###############################################################################

