###############################################################################
#

system_features:

    # HTTP proxy.
    # This configuration can be used for: YUM, Cygwin installer, browsers, etc.
    external_http_proxy:
        # If not enabled, no proxy configuration is enforced.
        feature_enabled: False

        auto_config_url: http://proxy.example.com/autoconf/proxy.pac

        # In order to form full URL, the following lines are concatenated as:
        #   [proxy_url_schema][proxy_url_hostname]:[proxy_url_port]/
        # If authentication info is required to be embedded inside URL itself,
        # the following concatenation is uses:
        #   [proxy_url_schema][username]:[password]@[proxy_url_hostname]:[proxy_url_port]/
        proxy_url_schema: http://
        proxy_url_hostname: proxy.example.com
        proxy_url_port: 8000

        proxy_username: username
        # TODO: Use `secret_id` from `system_secrets` for `password_value`.
        proxy_password: password_value

###############################################################################
# EOF
###############################################################################

