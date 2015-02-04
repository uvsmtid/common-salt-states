<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                      http://maven.apache.org/xsd/settings-1.0.0.xsd">
    <offline>false</offline>

    <pluginGroups>
        <pluginGroup>org.mortbay.jetty</pluginGroup>
    </pluginGroups>

    <servers>
		<server>
            <id>nexus</id>
            <username>deployment</username>
            <password>deployment123</password>
      </server>
      <server>
            <id>nexus-snapshots</id>
            <username>deployment</username>
            <password>deployment123</password>
      </server>
    </servers>

    <mirrors>
        <mirror>
            <id>nexus-mirror</id>
            <mirrorOf>*,!nexus,!nexus-snapshots,!nexus-plugin-snapshots</mirrorOf>
            <name>Nexus repository manager</name>
            <url>http://nexus:8081/nexus/content/groups/public/</url>
        </mirror>
		
    </mirrors>

    <profiles>
        <profile>
            <id>nexus-profile</id>
            <repositories>
                <repository>
                    <id>nexus</id>
                    <name>Nexus Repository Manager</name>
                    <!--
                    <url>http://nexus:8081/nexus/content/repositories/releases</url>
                    -->
                    <url>http://maven_repository_manager_role:8081/nexus/content/repositories/releases</url>
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
                    <!--
                    <url>http://nexus:8081/nexus/content/repositories/snapshots</url>
                    -->
                    <url>http://maven_repository_manager_role:8081/nexus/content/repositories/snapshots</url>
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
        <profile>
            <id>properties-profile</id>
            <properties>
                <url-deploy-repo>http://nexus:8081/nexus/content/repositories/releases/</url-deploy-repo>
                <url-deploy-snapshot-repo>http://nexus:8081/nexus/content/repositories/releases/</url-deploy-snapshot-repo>
                <url-deploy-repo>http://maven_repository_manager_role:8081/nexus/content/repositories/releases/</url-deploy-repo>
                <url-deploy-snapshot-repo>http://maven_repository_manager_role:8081/nexus/content/repositories/snapshots/</url-deploy-snapshot-repo>
            </properties>
        </profile>
        -->

    </profiles>

    <!-- activeProfiles List of profiles that are active for all builds. -->
    <activeProfiles>
        <activeProfile>nexus-profile</activeProfile>
        <!--
        <activeProfile>properties-profile</activeProfile>
        -->
    </activeProfiles>
</settings>

