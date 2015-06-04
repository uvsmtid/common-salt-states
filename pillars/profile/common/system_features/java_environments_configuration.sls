
###############################################################################
#

system_features:

    java_environments_configuration:
        java_environments:

            # Oracle Java.
            oracle_jdk-linux-x64:
                # Installation type:
                # - yum_repositories - pre-configured YUM repository.
                #     This option requires additional parameter `rpm_packages`.
                # - rpm_sources - list of content items with RPM packages.
                #     This option requires additional parameter `rpm_sources`.
                installation_type: rpm_sources

                rpm_sources:
                    oracle_jdk:
                        source_type: rpm
                        resource_id: oracle_jdk-7u71-linux-x64.rpm
                        rpm_options: '--nosignature'

                # TODO: List of applicable platforms where this Java environment
                # can be installed with their configuratoin.
                os_platform_configs:
                    fc21:
                        JAVA_HOME: '/usr/java/jdk1.7.0_71/jre'
                        rpm_version: 'jdk-2000:1.7.0_71-fcs.x86_64'
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
                    fc21:
                        JAVA_HOME: '/usr/lib/jvm/java-1.8.0-openjdk/jre'
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
                    fc21:
                        JAVA_HOME: '/usr/lib/jvm/java-1.7.0-openjdk/jre'
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

