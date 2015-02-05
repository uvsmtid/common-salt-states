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
    -->
    <servers>
		<server>
            <id>releaseDeployRepo</id>
            <username>deployment</username>
            <password>deployment123</password>
      </server>
      <server>
            <id>snapshotDeployRepo</id>
            <username>deployment</username>
            <password>deployment123</password>
      </server>
    </servers>

    <!--
        TODO: Replace hard-coded URL with template variable.
        TODO: Why there are instances of strings like
              `nexus-releases` and `nexus-snapshots` referenced in `mirrorOf`
              but there is nothing about `nexus-plugin-snapshots` in this
              file?
    -->
    <mirrors>
        <mirror>
            <id>nexus-mirror</id>
            <mirrorOf>*,!releaseDeployRepo,!snapshotDeployRepo,!nexus-plugin-snapshots</mirrorOf>
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
                    <id>releaseDeployRepo</id>
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
                    <id>snapshotDeployRepo</id>
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

{% for selected_repo_name in pillar['system_features']['deploy_environment_sources']['source_repositories'].keys() %}

{% set selected_repo_type = pillar['system_features']['deploy_environment_sources']['source_repo_types'][selected_repo_name] %}
{% set repo_config = pillar['system_features']['deploy_environment_sources']['source_repositories'][selected_repo_name][selected_repo_type] %}

{# Compose repository_url #}
{% set origin_url_ssh_path = repo_config['origin_url_ssh_path'] %}
{% if repo_config['origin_url_ssh_username'] %}
{% set ssh_address = repo_config['origin_url_ssh_username'] + '@' + repo_config['origin_url_ssh_hostname'] %}
{% else %}
{% set ssh_address = repo_config['origin_url_ssh_hostname'] %}
{% endif %}
{% set repository_url = ssh_address + ':' + origin_url_ssh_path %}

{# This is an attempt to reformat normal SSH-like URL to some weird format accoring to http://maven.apache.org/scm/git.html #}
{% if origin_url_ssh_path|first == '/' %}
{% set maven_repository_url = 'scm:git:ssh://' + ssh_address + ':22' + origin_url_ssh_path %}
{% else %}
{% set maven_repository_url = 'scm:git:ssh://' + ssh_address + ':22' + '/~/' + origin_url_ssh_path %}
{% endif %}
                <{{ selected_repo_name }}-scm_connection_url>{{ maven_repository_url }}</{{ selected_repo_name }}-scm_connection_url>

{% endfor %}

            </properties>
        </profile>

    </profiles>

    <!-- activeProfiles List of profiles that are active for all builds. -->
    <activeProfiles>
        <activeProfile>nexus-profile</activeProfile>
        <activeProfile>properties-profile</activeProfile>
    </activeProfiles>
</settings>

