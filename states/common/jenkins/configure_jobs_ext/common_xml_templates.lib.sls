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
              <propertiesFile>{{ job_environ['jenkins_dir_path'] }}/build_pipeline/build.properties</propertiesFile>
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

{% macro join_downstream_jobs_macro(job_config, job_environ) %}

{% if 'trigger_jobs_on_downstream_join' in job_config %}

    <join.JoinTrigger plugin="join@1.16">
      <joinProjects>{{ job_config['trigger_jobs_on_downstream_join']|join(',') }}</joinProjects>
      <joinPublishers/>
      <evenIfDownstreamUnstable>true</evenIfDownstreamUnstable>
    </join.JoinTrigger>

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

  {% if 'discard_old_builds' in job_config %}
  <logRotator class="hudson.tasks.LogRotator">
    <daysToKeep>{{ job_config['discard_old_builds']['build_days'] }}</daysToKeep>
    <numToKeep>{{ job_config['discard_old_builds']['build_num'] }}</numToKeep>
    <artifactDaysToKeep>-1</artifactDaysToKeep>
    <artifactNumToKeep>-1</artifactNumToKeep>
  </logRotator>
  {% endif %}

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
        {% for promotion_name in job_config['use_promotions'] %}
        <string>{{ promotion_name }}</string>
        {% endfor %}
      </activeProcessNames>
    </hudson.plugins.promoted__builds.JobPropertyImpl>

    {% endif %}

  </properties>

  {% if 'force_jenkins_master' in job_config and job_config['force_jenkins_master'] %}
  <assignedNode>master</assignedNode>
  {% else %}
  <assignedNode>{{ job_environ['job_assigned_host'] }}</assignedNode>
  {% endif %}

  <keepDependencies>true</keepDependencies>

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

{% if not 'is_standalone' in job_config or not job_config['is_standalone'] %}

    <!--
        Copy fingerprinted and archived artifact just for the sake
        of reliably linking this job to the initial one in the pipeline.
    -->
    <hudson.plugins.copyartifact.CopyArtifact plugin="copyartifact@1.35.2">
      <project>init_pipeline.start_new_build</project>
      <filter>initial.dynamic_build_descriptor.yaml</filter>
      <target></target>
      <excludes></excludes>
      <selector class="hudson.plugins.copyartifact.TriggeredBuildSelector">
        <!--
            Falling back to the latest allows rebuilding jobs
            without restarting entire pipelined build.
        -->
        <fallbackToLastSuccessful>true</fallbackToLastSuccessful>
        <upstreamFilterStrategy>UseGlobalSetting</upstreamFilterStrategy>
      </selector>
      <doNotFingerprintArtifacts>false</doNotFingerprintArtifacts>
    </hudson.plugins.copyartifact.CopyArtifact>

{% endif %}

{% endmacro %}

###############################################################################
{% macro key_setter_python_script(job_config, job_environ) %}
import os
import sys
import yaml

# Load data from dynamic descriptor.
with open(sys.argv[1], 'r') as yaml_file:
    loaded_data = yaml.load(yaml_file)

# If file was empty, its data is None, but we need a dict.
if loaded_data is None:
    loaded_data = {}

# Parse specification of the key provided on command line.
# The format should be 'parent-key:child-key:...:sub-key'
key_spec = sys.argv[2]
key_list = key_spec.split(':')
last_sub_key = key_list[-1]
curr_value = loaded_data
# Walk down to the last dictionary where 'last_sub_key' is.
for curr_key in key_list[:-1]:
    if curr_key not in curr_value:
        curr_value[curr_key] = {}
    curr_value = curr_value[curr_key]
    assert(isinstance(curr_value, dict))

# Assign content of STDIN to the specified key.
curr_value[last_sub_key] = sys.stdin.read().strip()

# Save dynamic build descriptor.
with open(sys.argv[1], 'w') as yaml_file:
    yaml.dump(
        loaded_data,
        yaml_file,
        default_flow_style = False,
        indent = 4,
    )

{% endmacro %}

###############################################################################
{% macro key_getter_python_script(job_config, job_environ) %}

import os
import sys
import yaml

# Load data from dynamic descriptor.
with open(sys.argv[1], 'r') as yaml_file:
    loaded_data = yaml.load(yaml_file)

# If file was empty, its data is None, but we need a dict.
if loaded_data is None:
    loaded_data = {}

# Parse specification of the key provided on command line.
# The format should be 'parent-key:child-key:...:sub-key'
key_spec = sys.argv[2]
key_list = key_spec.split(':')

# If key does not exists, use default (if provided).
is_default_value_available = False
default_value = None
if len(sys.argv) >= 4:
    is_default_value_available = True
    default_value = sys.argv[3]

# Walk down to the value.
curr_value = loaded_data
for curr_key in key_list:
    if curr_key in curr_value:
        curr_value = curr_value[curr_key]
    else:
        assert(is_default_value_available)
        curr_value = default_value
        break

# Print content of the value to STDOUT.
print curr_value

{% endmacro %}

###############################################################################
{% macro store_environment_python_script(job_config, job_environ) %}

import os
import sys
import yaml

# Load data from dynamic descriptor.
with open(sys.argv[1], 'r') as yaml_file:
    loaded_data = yaml.load(yaml_file)

# If file was empty, its data is None, but we need a dict.
if loaded_data is None:
    loaded_data = {}

# Capture environment variables in two formats:
# - Save environment variables as text with shell code.
loaded_data['environ_text'] = sys.stdin.read()
# - Save environment variables as dict structure.
loaded_data['environ'] = os.environ.copy()

# Save dynamic build descriptor.
with open(sys.argv[1], 'w') as yaml_file:
    yaml.dump(
        loaded_data,
        yaml_file,
        default_flow_style = False,
        indent = 4,
    )

{% endmacro %}

###############################################################################
{% macro locate_dynamic_build_descriptor(job_config, job_environ, check_init_dyn_build_desc = True) %}

{% from 'common/libs/host_config_queries.sls' import get_system_host_primary_user_posix_home with context %}

# Location of dynamic build descriptor in pillar repository.
# The purpose of this file is peristence.
# This is the location where the latest dynamic build descriptor
# is checked in at the end of each job.
{% set project_name = pillar['project_name'] %}
{% if pillar['is_generic_profile'] %}
{% set repo_config = pillar['system_features']['deploy_environment_sources']['source_repositories'][project_name + '-salt-states']['git'] %}
{% else %}
{% set repo_config = pillar['system_features']['deploy_environment_sources']['source_repositories'][project_name + '-salt-pillars']['git'] %}
{% endif %}
REPO_DYN_BUILD_DESC_PATH='{{ get_system_host_primary_user_posix_home(repo_config['source_system_host']) }}/{{ repo_config['origin_uri_ssh_path'] }}/pillars/profile/dynamic_build_descriptor.yaml'
# Make sure it exists.
ls -lrt "${REPO_DYN_BUILD_DESC_PATH}"

# Location of the initial build descriptor used to set fingerprints
# for all related jobs.
INIT_DYN_BUILD_DESC_PATH='{{ job_environ['jenkins_dir_path'] }}/build_pipeline/initial.dynamic_build_descriptor.yaml'
{% if check_init_dyn_build_desc %}
# Make sure it exists.
ls -lrt "${INIT_DYN_BUILD_DESC_PATH}"
# The file should also match the one provided by Copy Artifact plugin.
MD5SUM_LEFT="$(md5sum 'initial.dynamic_build_descriptor.yaml' | cut -d' ' -f1 )"
MD5SUM_RIGH="$(md5sum "${INIT_DYN_BUILD_DESC_PATH}"   | cut -d' ' -f1 )"
test "${MD5SUM_LEFT}" == "${MD5SUM_RIGH}"
{% endif  %}

# Location of the job dynamic build descriptor.
# The purpose of this file is to have working copy of
# dynamic build descriptor for this job.
JOB_DYN_BUILD_DESC_PATH='{{ job_environ['jenkins_dir_path'] }}/build_pipeline/{{ job_environ['job_name'] }}.dynamic_build_descriptor.yaml'

# Location of the latest dynamic build descriptor.
# The purpose of this file is to let next job continue
# the relay of updating dynamic build descriptor.
LATEST_DYN_BUILD_DESC_PATH='{{ job_environ['jenkins_dir_path'] }}/build_pipeline/latest.dynamic_build_descriptor.yaml'
mkdir -p "$(dirname "${LATEST_DYN_BUILD_DESC_PATH}")"
touch "${LATEST_DYN_BUILD_DESC_PATH}"

# Location of the dynamic build descriptor of the previous build.
# The purpose of this file is to indicate what was the build descriptor
# in the previous build (to recover conditions if pipeline failed).
RECOVERY_DYN_BUILD_DESC_PATH='{{ job_environ['jenkins_dir_path'] }}/build_pipeline/recovery.dynamic_build_descriptor.yaml'

# Let job continue from the latest.
cp "${LATEST_DYN_BUILD_DESC_PATH}" "${JOB_DYN_BUILD_DESC_PATH}"

{% endmacro %}

###############################################################################
{% macro update_dynamic_build_descriptor(job_config, job_environ) %}

# Update the latest dynamic build desciptor by
# the one generated for this during job.
cp "${JOB_DYN_BUILD_DESC_PATH}" "${LATEST_DYN_BUILD_DESC_PATH}"

{% endmacro %}

###############################################################################
# EOF
###############################################################################

