
###############################################################################
#

system_features:

    # NOTE: There could be weird security requirements
    #       like disabling SMTP auth completely
    #       and use correct "Sender" address.
    #       In that case old Jenkins version
    #       lists this option directly under SMPT configuration.
    #       The new version of Jenkins used by Observer
    #       has it under "Jenkins Location" - see this SO answer:
    #           http://stackoverflow.com/questions/9693526/how-can-i-set-the-senders-address-in-jenkins

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

