<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                      http://maven.apache.org/xsd/settings-1.0.0.xsd">

{% set primary_maven_repository_manager_name = pillar['system_features']['maven_repository_manager_configuration']['primary_maven_repository_manager'] %}
{% set primary_maven_repository_manager_config = pillar['system_features']['maven_repository_manager_configuration']['maven_repository_managers'][primary_maven_repository_manager_name] %}

{% set nexus_url_scheme_part = primary_maven_repository_manager_config['maven_repo_url_scheme_part'] %}
{% set nexus_url_port_part = primary_maven_repository_manager_config['maven_repo_url_port_part'] %}
{% set nexus_url_releases_path_part = primary_maven_repository_manager_config['maven_repo_url_releases_path_part'] %}
{% set nexus_url_snapshots_path_part = primary_maven_repository_manager_config['maven_repo_url_snapshots_path_part'] %}

{% set nexus_releases_deployment_url = nexus_url_scheme_part + primary_maven_repository_manager_name + nexus_url_port_part + nexus_url_releases_path_part %}
{% set nexus_snapshots_deployment_url = nexus_url_scheme_part + primary_maven_repository_manager_name + nexus_url_port_part + nexus_url_snapshots_path_part %}

    <offline>false</offline>

    <pluginGroups>
        <pluginGroup>org.mortbay.jetty</pluginGroup>
    </pluginGroups>

    <!--
        TODO: Put hardcoded username/password in profile configuration.
        TODO: Should `nexus-releases` be renamed into `releaseDeployRepo`
              and `nexus-snapshots` be renamed into `snapshotDeployRepo`
              just like in `pom.xml` files?
    -->
    <servers>
		<server>
            <id>nexus-releases</id>
            <username>deployment</username>
            <password>deployment123</password>
      </server>
      <server>
            <id>nexus-snapshots</id>
            <username>deployment</username>
            <password>deployment123</password>
      </server>
    </servers>

    <!--
        TODO: Replace hard-coded URL with tamplate variable.
        TODO: Why there are instances of strings like
              `nexus-releases` and `nexus-snapshots` referenced in `mirrorOf`
              but there is nothing about `nexus-plugin-snapshots` in this
              file?
    -->
    <mirrors>
        <mirror>
            <id>nexus-mirror</id>
            <mirrorOf>*,!nexus-releases,!nexus-snapshots,!nexus-plugin-snapshots</mirrorOf>
            <name>Nexus repository manager</name>
            <url>http://nexus:8081/nexus/content/groups/public/</url>
        </mirror>

    </mirrors>

    <profiles>
        <!--
            These settings are used by Maven during builds to connect
            to Maven Repository Manager (like Nexus).
        -->
        <profile>
            <id>nexus-profile</id>
            <repositories>
                <repository>
                    <id>nexus-releases</id>
                    <name>Nexus Repository Manager</name>

                    <!-- Example
                    <url>http://nexus:8081/nexus/content/repositories/releases</url>
                    -->
                    <url>{{ nexus_releases_deployment_url }}</url>

                    <releases>
                        <enabled>true</enabled>
                        <updatePolicy>always</updatePolicy>
                    </releases>
                    <snapshots>
                        <enabled>false</enabled>
                        <updatePolicy>always</updatePolicy>
                    </snapshots>
                </repository>
                <repository>
                    <id>nexus-snapshots</id>
                    <name>Nexus Repository Manager</name>

                    <!-- Example
                    <url>http://nexus:8081/nexus/content/repositories/snapshots</url>
                    -->
                    <url>{{ nexus_snapshots_deployment_url }}</url>

                    <releases>
                        <enabled>false</enabled>
                        <updatePolicy>always</updatePolicy>
                    </releases>
                    <snapshots>
                        <enabled>true</enabled>
                        <updatePolicy>always</updatePolicy>
                    </snapshots>
                </repository>
            </repositories>
        </profile>

        <!--
            These properties are used in `pom.xml` files to provide
            Maven Release plugin with URL to publish projects in
            Maven Repository Manager (like Nexus).
        -->
        <profile>
            <id>properties-profile</id>
            <properties>

                <!-- Example
                <url-deploy-release-repo>http://nexus:8081/nexus/content/repositories/releases/</url-deploy-release-repo>
                <url-deploy-snapshot-repo>http://nexus:8081/nexus/content/repositories/releases/</url-deploy-snapshot-repo>
                -->
                <url-deploy-release-repo>{{ nexus_releases_deployment_url }}</url-deploy-release-repo>
                <url-deploy-snapshot-repo>{{ nexus_snapshots_deployment_url }}</url-deploy-snapshot-repo>

            </properties>
        </profile>

    </profiles>

    <!-- activeProfiles List of profiles that are active for all builds. -->
    <activeProfiles>
        <activeProfile>nexus-profile</activeProfile>
        <activeProfile>properties-profile</activeProfile>
    </activeProfiles>
</settings>

