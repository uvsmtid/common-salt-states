<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                      http://maven.apache.org/xsd/settings-1.0.0.xsd">

{% if pillar['system_features']['maven_repository_manager_configuration']['primary_maven_repository_manager'] %} <!-- primary_maven_repository_manager -->

{% set primary_maven_repository_manager_role_id = pillar['system_features']['maven_repository_manager_configuration']['primary_maven_repository_manager'] %}
{% set primary_maven_repository_manager_role_hostname = pillar['system_host_roles'][primary_maven_repository_manager_role_id]['hostname'] %}
{% set primary_maven_repository_manager_config = pillar['system_features']['maven_repository_manager_configuration']['maven_repository_managers'][primary_maven_repository_manager_role_id] %}

{% set nexus_url_scheme_part = primary_maven_repository_manager_config['maven_repo_url_scheme_part'] %}
{% set nexus_url_port_part = primary_maven_repository_manager_config['maven_repo_url_port_part'] %}
{% set nexus_url_releases_path_part = primary_maven_repository_manager_config['maven_repo_url_releases_path_part'] %}
{% set nexus_url_snapshots_path_part = primary_maven_repository_manager_config['maven_repo_url_snapshots_path_part'] %}

{% set define_deployment_url = True %}
{% set nexus_releases_deployment_url = nexus_url_scheme_part + primary_maven_repository_manager_role_hostname + nexus_url_port_part + nexus_url_releases_path_part %}
{% set nexus_snapshots_deployment_url = nexus_url_scheme_part + primary_maven_repository_manager_role_hostname + nexus_url_port_part + nexus_url_snapshots_path_part %}

{% else %} <!-- primary_maven_repository_manager -->

{% set define_deployment_url = False %}

{% endif %} <!-- primary_maven_repository_manager -->

    <offline>false</offline>

    <!--
        TODO: What is this and why it is needed?
    -->
    <pluginGroups>
        <pluginGroup>org.mortbay.jetty</pluginGroup>
        
        <!-- SonarQube -->
        <pluginGroup>org.sonarsource.scanner.maven</pluginGroup> 
    </pluginGroups>

    <!--
        TODO: Put hardcoded `username`/`password_value` in pillar.
    -->
    <servers>
		<server>
            <id>releaseDeployRepo</id>
            <username>deployment</username>
            <!-- TODO: Use `secret_id` from `system_secrets` for `password_value`. -->
            <password>deployment123</password>
      </server>
      <server>
            <id>snapshotDeployRepo</id>
            <username>deployment</username>
            <!-- TODO: Use `secret_id` from `system_secrets` for `password_value`. -->
            <password>deployment123</password>
      </server>
    </servers>

{% if pillar['system_features']['maven_repository_manager_configuration']['proxy_maven_repository_manager'] %}

{% set proxy_maven_repository_manager_role_id = pillar['system_features']['maven_repository_manager_configuration']['proxy_maven_repository_manager'] %}
{% set proxy_maven_repository_manager_role_hostname = pillar['system_host_roles'][proxy_maven_repository_manager_role_id]['hostname'] %}
{% set proxy_maven_repository_manager_config = pillar['system_features']['maven_repository_manager_configuration']['maven_repository_managers'][proxy_maven_repository_manager_role_id] %}

{% set proxy_maven_repository_manager_url_scheme_part = proxy_maven_repository_manager_config['maven_repo_url_scheme_part'] %}
{% set proxy_maven_repository_manager_url_port_part = proxy_maven_repository_manager_config['maven_repo_url_port_part'] %}
{% set proxy_maven_repository_manager_url_public_path_part = proxy_maven_repository_manager_config['maven_repo_url_public_path_part'] %}

{% set proxy_maven_repository_manager_url = proxy_maven_repository_manager_url_scheme_part + proxy_maven_repository_manager_role_hostname + proxy_maven_repository_manager_url_port_part + proxy_maven_repository_manager_url_public_path_part %}

    <mirrors>
        <mirror>
            <!-- This sends everything else to /public of upstream repository. -->
            <id>nexus-mirror</id>
            <mirrorOf>*,!releaseDeployRepo,!snapshotDeployRepo</mirrorOf>
            <url>{{ proxy_maven_repository_manager_url }}</url>
        </mirror>

    </mirrors>
{% endif %}

    <profiles>
        <!--
            These settings are used by Maven during builds to connect
            to Maven Repository Manager (like Nexus).
        -->
        <profile>
            <id>nexus-profile</id>
{% if define_deployment_url %}
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
{% endif %}
        </profile>

        <!--
            These properties are used in `pom.xml` files to provide
            Maven Release plugin with URL to publish artifacts in
            Maven Repository Manager (like Nexus).
        -->
        <profile>
            <id>properties-profile</id>
            <properties>

                <!-- Example
                <url-deploy-release-repo>http://nexus:8081/nexus/content/repositories/releases/</url-deploy-release-repo>
                <url-deploy-snapshot-repo>http://nexus:8081/nexus/content/repositories/releases/</url-deploy-snapshot-repo>
                -->
{% if define_deployment_url %}
                <url-deploy-release-repo>{{ nexus_releases_deployment_url }}</url-deploy-release-repo>
                <url-deploy-snapshot-repo>{{ nexus_snapshots_deployment_url }}</url-deploy-snapshot-repo>
{% endif %}

{% for selected_repo_name in pillar['system_features']['deploy_environment_sources']['source_repositories'].keys() %}

{% set selected_repo_type = pillar['system_features']['deploy_environment_sources']['source_repo_types'][selected_repo_name] %}

{% if selected_repo_type == 'git' %}

{# Call marco `define_git_repo_uri_maven` to define variable `git_repo_uri_maven`. #}
{% from 'common/git/git_uri.lib.sls' import define_git_repo_uri_maven with context %}
{% set git_repo_uri_maven = define_git_repo_uri_maven(selected_repo_name) %}

                <{{ selected_repo_name }}-scm_connection_url>{{ git_repo_uri_maven }}</{{ selected_repo_name }}-scm_connection_url>

{% else %}

            <!--
                TODO: Add support for other repository types.
                      At the moment, refer to non-existing `git_repo_uri_maven` to fail.
            -->
                <{{ selected_repo_name }}-scm_connection_url>{{ git_repo_uri_maven }}</{{ selected_repo_name }}-scm_connection_url>

{% endif %}


{% endfor %}

            </properties>
        </profile>

    <!-- SonarQube -->
    <profile>
            <id>sonar</id>
            <activation>
                <activeByDefault>true</activeByDefault>
            </activation>
            <properties>
                <!-- Optional URL to server. Default value is http://localhost:9000 -->
                <sonar.host.url>
                  http://localhost:9000
                </sonar.host.url>
                <sonar.jdbc.url>
                  jdbc:mysql://localhost:3306/sonar?useUnicode=true&amp;characterEncoding=utf8
                </sonar.jdbc.url>
                <sonar.jdbc.username>sonar</sonar.jdbc.username>
                <sonar.jdbc.password></sonar.jdbc.password>
            </properties>
        </profile> 
    </profiles>

    <!-- activeProfiles List of profiles that are active for all builds. -->
    <activeProfiles>
        <activeProfile>nexus-profile</activeProfile>
        <activeProfile>properties-profile</activeProfile>
    </activeProfiles>
</settings>

