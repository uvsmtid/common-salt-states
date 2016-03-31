
###############################################################################
#

system_resources:

    # WildFly JEE application server.
    # Downloadable from:
    #   http://wildfly.org/downloads/
    # Direct link:
    #   http://download.jboss.org/wildfly/10.0.0.Final/wildfly-10.0.0.Final.zip
    wildfly_application_server_distribution_zip:
        resource_repository: banyan-resources
        bootstrap_use_cases: False
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: wildfly
        item_base_name: wildfly-10.0.0.Final.zip
        item_content_hash: md5=bbef420f1f3b3c463cf8c0b171d2a8c5

###############################################################################
# EOF
###############################################################################

