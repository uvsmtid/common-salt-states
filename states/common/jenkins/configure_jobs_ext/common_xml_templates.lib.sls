###############################################################################

###############################################################################
{% macro parameterized_job_triggers_macro(job_config, job_environ) %}

    {% if 'parameterized_job_triggers' in job_config %}
    <hudson.plugins.parameterizedtrigger.BuildTrigger plugin="parameterized-trigger@2.26">
      <configs>

    {% for trigger_config_name in job_config['parameterized_job_triggers'].keys() %}
    {% set trigger_config = job_config['parameterized_job_triggers'][trigger_config_name] %}
        <hudson.plugins.parameterizedtrigger.BuildTriggerConfig>
          <configs>
            <hudson.plugins.parameterizedtrigger.FileBuildParameters>
              <propertiesFile>{{ job_environ['jenkins_dir_path'] }}/build.properties</propertiesFile>
              <failTriggerOnMissing>false</failTriggerOnMissing>
              <useMatrixChild>false</useMatrixChild>
              <onlyExactRuns>false</onlyExactRuns>
            </hudson.plugins.parameterizedtrigger.FileBuildParameters>
          </configs>
          <projects>{{ trigger_config['trigger_jobs']|join(',') }}</projects>
          <condition>{{ trigger_config['condition'] }}</condition>
          <triggerWithNoParameters>true</triggerWithNoParameters>
        </hudson.plugins.parameterizedtrigger.BuildTriggerConfig>
    {% endfor %}

      </configs>
    </hudson.plugins.parameterizedtrigger.BuildTrigger>
    {% endif %}

{% endmacro %}

###############################################################################
{% macro job_scm_configuration(job_config, job_environ) %}
  <!--
      Git configuration.
  -->
{% set selected_repo_name = job_config['job_config_data']['repository_name'] %}
{% set selected_repo_type = pillar['system_features']['deploy_environment_sources']['source_repo_types'][selected_repo_name] %}

{% if selected_repo_type == 'git' %} <!-- SCM Git -->

{% set repo_config = pillar['system_features']['deploy_environment_sources']['source_repositories'][selected_repo_name][selected_repo_type] %}

{# Call marco `define_git_repo_uri` to define variable `git_repo_uri`. #}
{% from 'common/git/git_uri.lib.sls' import define_git_repo_uri with context %}
{% set git_repo_uri = define_git_repo_uri(selected_repo_name) %}

{% set remote_branch_name = repo_config['branch_name'] %}

  <scm class="hudson.plugins.git.GitSCM" plugin="git@2.3.4">
    <configVersion>2</configVersion>
    <userRemoteConfigs>
      <hudson.plugins.git.UserRemoteConfig>
        <!--
        <url>username@hostname:path/to/repo.git</url>
        -->
        <url>{{ git_repo_uri }}</url>
        <!--
            TODO: Figure out how to define credentials per repository
                  when repository is identified by a string (no reliable
                  easy to use hostname or minion id) and the ids for
                  credentials which exists are all IDs generated (not
                  configured.
        -->
{% from 'common/jenkins/credentials.lib.sls' import get_jenkins_credentials_id_by_host_id with context %}
        <credentialsId>{{ get_jenkins_credentials_id_by_host_id(repo_config['source_system_host']) }}</credentialsId>
      </hudson.plugins.git.UserRemoteConfig>
    </userRemoteConfigs>
    <branches>
      <hudson.plugins.git.BranchSpec>
        <!--
        <name>*/master</name>
        -->
        <name>refs/remotes/origin/{{ remote_branch_name }}</name>
      </hudson.plugins.git.BranchSpec>
    </branches>
    <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
    <submoduleCfg class="list"/>
    <extensions/>
  </scm>
{% endif %} <!-- SCM Git -->


{% if selected_repo_type != 'git' %} <!-- SCM Git -->
    <!--
        TODO: Implement SVN configuration.
              Refer to non-existing variable to fail template instantiation.
    -->
    {{ FAIL_this_template_instantiation_unsupported_SCM }}

{% endif %} <!-- SCM Git -->

{% endmacro %}

###############################################################################
{% macro common_job_configuration(job_config, job_environ) %}

  <actions>
  </actions>

  <description>{{ job_environ['job_description'] }}</description>

  <properties>

    <!-- build_parameters -->
    {% if 'build_parameters' in job_config %}

    <hudson.model.ParametersDefinitionProperty>
      <parameterDefinitions>

        {% for param_name in job_config['build_parameters'].keys() %}

        {% set param_config = job_config['build_parameters'][param_name] %}
        {% set param_type = param_config['parameter_type'] %}

        {% if not param_type %}

        {% elif param_type == 'boolean' %}

        <hudson.model.BooleanParameterDefinition>
          <name>{{ param_name }}</name>
          <description>{{ param_config['parameter_description'] }}</description>
          <defaultValue>{{ param_config['parameter_value'] }}</defaultValue>
        </hudson.model.BooleanParameterDefinition>

        {% elif param_type == 'choice' %}

        <hudson.model.ChoiceParameterDefinition>
          <name>{{ param_name }}</name>
          <description>{{ param_config['parameter_description'] }}</description>
          <choices class="java.util.Arrays$ArrayList">
            <a class="string-array">
              {% for param_value in param_config['parameter_value'] %}
              <string>{{ param_value }}</string>
              {% endfor %}
            </a>
          </choices>
        </hudson.model.ChoiceParameterDefinition>

        {% elif param_type == 'string' %}

        <hudson.model.StringParameterDefinition>
          <name>{{ param_name }}</name>
          <description>{{ param_config['parameter_description'] }}</description>
          <defaultValue>{{ param_config['parameter_value'] }}</defaultValue>
        </hudson.model.StringParameterDefinition>

        {% elif param_type == 'text' %}

        <hudson.model.TextParameterDefinition>
          <name>{{ param_name }}</name>
          <description>{{ param_config['parameter_description'] }}</description>
          <defaultValue>{{ param_config['parameter_value'] }}</defaultValue>
        </hudson.model.TextParameterDefinition>

        {% endif %}

        {% endfor %}

        {% if False %}
        <!-- Examples of other parameters which can be implemented. -->
        <hudson.model.ParametersDefinitionProperty>
          <parameterDefinitions>
            <hudson.model.FileParameterDefinition>
              <name>FILE_PARAMETER</name>
              <description></description>
            </hudson.model.FileParameterDefinition>
            <hudson.model.PasswordParameterDefinition>
              <name>PASSWORD_PARAMETER</name>
              <description></description>
              <defaultValue>Y/ZTS27PlsnmKDKqz2Cn1g==</defaultValue>
            </hudson.model.PasswordParameterDefinition>
          </parameterDefinitions>
        </hudson.model.ParametersDefinitionProperty>
        {% endif %}

      </parameterDefinitions>
    </hudson.model.ParametersDefinitionProperty>

    {% endif %}

    <!-- use_promotions -->
    {% if 'use_promotions' in job_config %}

    <hudson.plugins.promoted__builds.JobPropertyImpl plugin="promoted-builds@2.21">
      <activeProcessNames>
        <string>{{ job_config['use_promotions']|join(', ') }}</string>
      </activeProcessNames>
    </hudson.plugins.promoted__builds.JobPropertyImpl>

    {% endif %}

  </properties>

  <assignedNode>{{ job_environ['job_assigned_host'] }}</assignedNode>

  <keepDependencies>false</keepDependencies>

  <canRoam>false</canRoam>

  <disabled>false</disabled>

  <concurrentBuild>false</concurrentBuild>

  <scm class="hudson.scm.NullSCM"/>

  <!-- NOTE: Maintains single active/running pipeline at a time. -->
  <blockBuildWhenDownstreamBuilding>true</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>true</blockBuildWhenUpstreamBuilding>

  <triggers>

    {% if 'timer_spec' in job_config %}
    {% if job_config['timer_spec'] %}
    <hudson.triggers.TimerTrigger>
      <spec>{{ job_config['timer_spec'] }}</spec>
    </hudson.triggers.TimerTrigger>
    {% endif %}
    {% endif %}

  </triggers>

{% endmacro %}

###############################################################################
{% macro copy_artifacts(job_config, job_environ) %}

    <!--
        Copy fingerprinted and archived artifact just for the sake
        of reliably linking this job to the initial one in the pipeline.
    -->
    <hudson.plugins.copyartifact.CopyArtifact plugin="copyartifact@1.35.2">
      <project>build_pipeline.init_dynamic_build_descriptor</project>
      <filter>dynamic_build_descriptor.yaml</filter>
      <target></target>
      <excludes></excludes>
      <selector class="hudson.plugins.copyartifact.TriggeredBuildSelector">
        <upstreamFilterStrategy>UseGlobalSetting</upstreamFilterStrategy>
      </selector>
      <doNotFingerprintArtifacts>false</doNotFingerprintArtifacts>
    </hudson.plugins.copyartifact.CopyArtifact>

{% endmacro %}

###############################################################################
# EOF
###############################################################################

