
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
            # The value is a `secret_id` from `system_secrets`
            # to provide value in secure way.
            smtp_auth_password_secret_id: smtp_connection_settings_auth_password

###############################################################################
# EOF
###############################################################################

