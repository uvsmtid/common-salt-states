
###############################################################################
#

# Load Fedora versions list.
{% set fedora_versions_list_path = profile_root.replace('.', '/') + '/common/system_platforms/fedora_versions_list.yaml' %}
{% import_yaml fedora_versions_list_path as fedora_versions_list %}

system_features:

    java_environments_configuration:
        java_environments:

            # Oracle Java.
            oracle_jdk-linux-x64:
                # Installation type:
                # - yum_repositories - pre-configured YUM repository.
                #     This option requires additional parameter `rpm_packages`.
                # - package_resources - list of content items package of various type.
                #     This option requires additional parameter `package_resources`.
                installation_type: package_resources

                package_resources:
                    oracle_jdk:
                        resource_type: rpm
                        resource_id: oracle_jdk-7u71-linux-x64.rpm
                        rpm_options: '--nosignature'

                # TODO: List of applicable platforms where this Java environment
                # can be installed with their configuratoin.
                os_platform_configs:

                    {% for system_platform_id in fedora_versions_list %}
                    {{ system_platform_id }}:
                    # NOTE: Reusing the same configuration for `fc21` by `fc24`.
                        JAVA_HOME: '/usr/java/jdk1.7.0_71/jre'
                        rpm_version: 'jdk-2000:1.7.0_71-fcs.x86_64'
                    {% endfor %}

                    rhel5:
                        JAVA_HOME: '/usr/java/jdk1.7.0_71/jre'
                        # `rpm_version` is used to check whether package is
                        # already installed.
                        rpm_version: 'jdk-1.7.0_71-fcs.x86_64'
                    rhel7:
                        JAVA_HOME: '/usr/java/jdk1.7.0_71/jre'
                        rpm_version: 'jdk-1.7.0_71-fcs.x86_64'

            # Default for fc21.
            java-1.8.0-openjdk:
                installation_type: yum_repositories

                rpm_packages:
                    - java-1.8.0-openjdk

                os_platform_configs:

                    {% for system_platform_id in fedora_versions_list %}
                    {{ system_platform_id }}:
                    # NOTE: Reusing the same configuration for `fc21` by `fc22`.
                        JAVA_HOME: '/usr/lib/jvm/java-1.8.0-openjdk/jre'
                    {% endfor %}

                    rhel7:
                        JAVA_HOME: '/usr/lib/jvm/java-1.8.0-openjdk/jre'
                    rhel5:
                        JAVA_HOME: '/usr/lib/jvm/java-1.8.0-openjdk/jre'

            # Default for RHEL 7.0.
            java-1.7.0-openjdk:
                installation_type: yum_repositories

                rpm_packages:
                    - java-1.7.0-openjdk

                os_platform_configs:

                    {% for system_platform_id in fedora_versions_list %}
                    {{ system_platform_id }}:
                    # NOTE: Reusing the same configuration for `fc21` by `fc22`.
                        JAVA_HOME: '/usr/lib/jvm/java-1.7.0-openjdk/jre'
                    {% endfor %}

                    rhel7:
                        JAVA_HOME: '/usr/lib/jvm/java-1.7.0-openjdk/jre'
                    rhel5:
                        JAVA_HOME: '/usr/lib/jvm/java-1.7.0-openjdk/jre'

            # Default for RHEL 5.5.
            java-gcj-compat:
                installation_type: yum_repositories

                rpm_packages:
                    - java-1.4.2-gcj-compat

                os_platform_configs:
                    rhel5:
                        JAVA_HOME: '/usr/lib/jvm/jre-1.4.2-gcj'

###############################################################################
# EOF
###############################################################################

