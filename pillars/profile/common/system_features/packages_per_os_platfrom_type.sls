
###############################################################################
#

system_features:

    # Each key in this sub-dictionary specifies test
    # against `os_platform_type` grain using `startswith` function.
    # For example,
    #   if grains['os_platform_type'].startswith('rhel5')
    # If test passes, the packages will be installed on destination minion.

    # NOTE: Packages are installed without any post-configuration.
    #       If any additonal configuration required, use other means -
    #       the most flexible approach is to create special state (`*.sls`).
    packages_per_os_platfrom_type:

        # Packages common for all RHEL versions.
        'rhel':
            - nmap

            - dos2unix

        # Packages common for all Fedora versions
        'fc':
            - nmap

            - dos2unix

            # This is used by `invoke.py` script from `git-group`.
            # Before fc25:
            #- python-lxml
            # After fc25:
            - python2-lxml

            # This is used by `join_hosts_roles_networks.py` script.
            - python-sqlalchemy

###############################################################################
# EOF
###############################################################################

