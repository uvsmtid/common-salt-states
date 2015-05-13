###############################################################################
#

system_features:

    # Initialize SSH seamless connections.
    # This feature makes sure that:
    # - All keys of "online" remote hosts (limited to those which enable
    #   `consider_online_for_remote_connections`) are accepted on all minions
    #   from `system_hosts` connected to Salt master so that no interractive
    #   prompt to accept these host keys is ever prompted again.
    # - Primary user from system hosts connected to Salt master can connect
    #   with public-key authentication (without password) to other primary
    #   users on other "online" system hosts.
    # The main idea is to eliminate all interractive steps and prepare
    # SSH to work automatically.
    #
    initialize_ssh_connections:
        feature_enabled: True

        # Location of public and private key for primary user.
        # TODO: Manage it through registered content item.
        #       Note that private key does not need to be in
        #       the same basket pointed by `URI_prefix`.
        #       Add ability to override `URI_prefix` for individual
        #       content item.
        # TODO: Manage keys via new credentials top-level pillar
        #       key which takes care of configuring accounts in
        #       every aspect of it.
        ssh_private_key_res_id: common_insecure_ssh_private_key.id_rsa
        ssh_public_key_res_id: common_insecure_ssh_public_key.id_rsa.pub

        # NOTE: The feature already enables all primary user to primary
        #       user connections (with some restrictions described above).
        #       The configuration below introduces additional sources
        #       and destinations which should be initialized.
        #
        # NOTE: Absolutely all authenticaion uses only one pair of
        #       private/public keys. Implementation relies on this fact
        #       (to limit number of connection combinations to loop throug).
        #       It is not designed for security, it is designed to avoid
        #       it and perform seamless automation, development and testing.

        extra_private_key_deployment_destinations:

            # TODO
            hosts_by_minion_id: {}
                #minion_id:
                #    username_item:
                #        username: username
                #        primary_group: username
                #        posix_user_home_dir: '/home/username'
                #        posix_user_home_dir_windows: 'C:\cygwin64\home\username'

            # DONE: Implemented.
            hosts_by_host_role:
                #controller-role:
                #    username_item:
                #        username: username
                #        primary_group: username
                #        posix_user_home_dir: '/home/username'
                #        posix_user_home_dir_windows: 'C:\cygwin64\home\username'
                jenkins-master-role:
                    jenkins:
                        username:                       jenkins
                        primary_group:                  jenkins
                        posix_user_home_dir:            '/var/lib/jenkins'
                        posix_user_home_dir_windows:    ~ # N/A

        # NOTE: Public key destinations will also be included in the list
        #       of hosts to automatically accept SSH host keys.
        extra_public_key_deployment_destinations:

            # DONE: Implemented.
            hosts_by_hostname:
                #hostname:
                #
                #    # Set `linux` or `windows` (see `system_hosts` why),
                #    # or empty string to assume current system type.
                #    os_type: linux
                #
                #    users:
                #        # Set user to empty string if SSH default should be
                #        # used (current local user or from `~/.ssh/config`).
                #        username_item:
                #            username: username
                #            passwrod: password

                # NOTE: Pushing SSH public key of current (primary) user to
                #       `localhost` is seemingly not required because other
                #       options cover this case.
                #       But this config is also used to accept SSH _host_ keys.
                #       And without having `localhost` option first attempt
                #       to connect to it will fail - so, it is required.
                localhost:
                    # Local OS type.
                    os_type: ''
                    user_configs:
                        current_user:
                            # Current local user.
                            username: ''
                            password: ''

            # TODO
            hosts_by_minion_id: {}
                #minion_id:
                #    username_item:
                #        username: username
                #        passwrod: password

            # DONE: Implemented.
            hosts_by_host_role: {}
                #controller-role:
                #    username_item:
                #        username: username
                #        passwrod: password

###############################################################################
# EOF
###############################################################################

