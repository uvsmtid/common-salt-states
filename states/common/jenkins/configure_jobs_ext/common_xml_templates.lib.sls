###############################################################################

###############################################################################
{% macro parameterized_job_triggers_macro(job_config, job_environ) %}

    {% if 'parameterized_job_triggers' in job_config %}
    <hudson.plugins.parameterizedtrigger.BuildTrigger plugin="parameterized-trigger@2.26">
      <configs>

    {% for trigger_config_name in job_config['parameterized_job_triggers'].keys() %}
    {% set trigger_config = job_config['parameterized_job_triggers'][trigger_config_name] %}
        <hudson.plugins.parameterizedtrigger.BuildTriggerConfig>
          #{# NOTE: By default `propagate_build_paramterers` is `False` #}#
          {% if 'propagate_build_paramterers' in job_config and not job_config['propagate_build_paramterers'] %}
          <configs class="empty-list"/>
          {% else %}
          <configs>
            <hudson.plugins.parameterizedtrigger.FileBuildParameters>
              <propertiesFile>{{ job_environ['jenkins_dir_path'] }}/build_pipeline/build.properties</propertiesFile>
              <failTriggerOnMissing>false</failTriggerOnMissing>
              <useMatrixChild>false</useMatrixChild>
              <onlyExactRuns>false</onlyExactRuns>
            </hudson.plugins.parameterizedtrigger.FileBuildParameters>
          </configs>
          {% endif %}
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
{% macro job_single_scm_configuration(job_config, job_environ) %}

{% set selected_repo_name = job_config['job_config_data']['repository_name'] %}
{% set selected_repo_type = pillar['system_features']['deploy_environment_sources']['source_repo_types'][selected_repo_name] %}

{% if selected_repo_type == 'git' %} <!-- SCM Git -->

{% set repo_config = pillar['system_features']['deploy_environment_sources']['source_repositories'][selected_repo_name][selected_repo_type] %}

{# Call marco `define_git_repo_uri` to define variable `git_repo_uri`. #}
{% from 'common/git/git_uri.lib.sls' import define_git_repo_uri with context %}
{% set git_repo_uri = define_git_repo_uri(selected_repo_name) %}

{% set remote_branch_name = pillar['system_features']['configure_jenkins']['build_branch_name'] %}

  <scm class="hudson.plugins.git.GitSCM" plugin="git@2.3.4">
    <configVersion>2</configVersion>
    <userRemoteConfigs>
      <hudson.plugins.git.UserRemoteConfig>
        <!--
        <url>username@hostname:path/to/repo.git</url>
        -->
        <!--
            TODO: Figure out how to define credentials per repository
                  when repository is identified by a string (no reliable
                  easy to use hostname or minion id) and the ids for
                  credentials which exists are all IDs generated (not
                  configured.
        -->
        <url>{{ git_repo_uri }}</url>

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


{% if selected_repo_type != 'git' %} <!-- Another SCM -->
    <!--
        TODO: Implement SVN configuration.
              Refer to non-existing variable to fail template instantiation.
    -->
    {{ FAIL_this_template_instantiation_unsupported_SCM }}

{% endif %} <!-- Another SCM -->

{% endmacro %}

###############################################################################
# Multipe SCM Plugin configuration with Git
# future implementation.
# NOTE:
# *   Checkout all repos in a single job.
# *   Disabling processing of submodules.
#     Parent is checked out and handled independently of children.
# *   Parameterized branch name.
# *   LIMITIATION: At the moment Jenkins Git plugin itself
#     does not allow checking out into absolute path.
#     Instead, it requires different approaches based on job type.
#     See:
#        https://issues.jenkins-ci.org/browse/JENKINS-30210
#        https://issues.jenkins-ci.org/browse/JENKINS-13576
{% macro job_multiple_scm_configuration(job_config, job_environ) %}

{% if 'track_scm_changes' in job_config and job_config['track_scm_changes'] %}

{% from 'common/libs/repo_config_queries.lib.sls' import get_repository_id_by_role with context %}
{% set build_history_repo_id = get_repository_id_by_role('build_history_role') %}

  <scm class="org.jenkinsci.plugins.multiplescms.MultiSCM" plugin="multiple-scms@0.5">
    <scms>

{% for selected_repo_name in pillar['system_features']['deploy_environment_sources']['source_repositories'] %}

{% if selected_repo_name != build_history_repo_id %}

{% set selected_repo_type = pillar['system_features']['deploy_environment_sources']['source_repo_types'][selected_repo_name] %}

{% if selected_repo_type == 'git' %} <!-- SCM Git -->

{% set repo_config = pillar['system_features']['deploy_environment_sources']['source_repositories'][selected_repo_name][selected_repo_type] %}

{# Call marco `define_git_repo_uri` to define variable `git_repo_uri`. #}
{% from 'common/git/git_uri.lib.sls' import define_git_repo_uri with context %}
{% set git_repo_uri = define_git_repo_uri(selected_repo_name) %}

{% set remote_branch_name = pillar['system_features']['configure_jenkins']['build_branch_name'] %}

      <hudson.plugins.git.GitSCM plugin="git@2.3.4">
        <configVersion>2</configVersion>

        <userRemoteConfigs>
          <hudson.plugins.git.UserRemoteConfig>

            <!--
            <url>username@hostname:path/to/repo.git</url>
            -->
            <!--
                TODO: Figure out how to define credentials per repository
                      when repository is identified by a string (no reliable
                      easy to use hostname or minion id) and the ids for
                      credentials which exists are all IDs generated (not
                      configured.
            -->
            <url>{{ git_repo_uri }}</url>

{% from 'common/jenkins/credentials.lib.sls' import get_jenkins_credentials_id_by_host_id with context %}

            <credentialsId>{{ get_jenkins_credentials_id_by_host_id(repo_config['source_system_host']) }}</credentialsId>

          </hudson.plugins.git.UserRemoteConfig>
        </userRemoteConfigs>

        <branches>
          <hudson.plugins.git.BranchSpec>
            <name>refs/heads/{{ remote_branch_name }}</name>
          </hudson.plugins.git.BranchSpec>
        </branches>

        <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>

        <submoduleCfg class="list"/>

        <extensions>

          <hudson.plugins.git.extensions.impl.ScmName>
            <name>{{ selected_repo_name }}</name>
          </hudson.plugins.git.extensions.impl.ScmName>

          <hudson.plugins.git.extensions.impl.RelativeTargetDirectory>
            <relativeTargetDir>{{ selected_repo_name }}</relativeTargetDir>
          </hudson.plugins.git.extensions.impl.RelativeTargetDirectory>

        </extensions>

      </hudson.plugins.git.GitSCM>

{% endif %} <!-- SCM Git -->


{% if selected_repo_type != 'git' %} <!-- Another SCM -->
    <!--
        TODO: Implement SVN configuration.
              Refer to non-existing variable to fail template instantiation.
    -->
    {{ FAIL_this_template_instantiation_unsupported_SCM }}

{% endif %} <!-- Another Git -->

{% endif %}

{% endfor %}

    </scms>
  </scm>

{% endif %}

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
          <defaultValue>{{ param_config['parameter_value']|e }}</defaultValue>
        </hudson.model.BooleanParameterDefinition>

        {% elif param_type == 'choice' %}

        <hudson.model.ChoiceParameterDefinition>
          <name>{{ param_name }}</name>
          <description>{{ param_config['parameter_description'] }}</description>
          <choices class="java.util.Arrays$ArrayList">
            <a class="string-array">
              {% for param_value in param_config['parameter_value'] %}
              <string>{{ param_value|e }}</string>
              {% endfor %}
            </a>
          </choices>
        </hudson.model.ChoiceParameterDefinition>

        {% elif param_type == 'string' %}

        <hudson.model.StringParameterDefinition>
          <name>{{ param_name }}</name>
          <description>{{ param_config['parameter_description'] }}</description>
          <defaultValue>{{ param_config['parameter_value']|e }}</defaultValue>
        </hudson.model.StringParameterDefinition>

        {% elif param_type == 'text' %}

        <hudson.model.TextParameterDefinition>
          <name>{{ param_name }}</name>
          <description>{{ param_config['parameter_description'] }}</description>
          <defaultValue>{{ param_config['parameter_value']|e }}</defaultValue>
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


    <!-- build blocker -->
    {% if 'block_build' in job_config %}
    <hudson.plugins.buildblocker.BuildBlockerProperty plugin="build-blocker-plugin@1.7.1">
      <useBuildBlocker>true</useBuildBlocker>
      <!--
        NOTE: Make sure to be blocked globally (not per slave node).
      -->
      <blockLevel>GLOBAL</blockLevel>
      <!--
        NOTE: Make sure all job statuses are considered for blocking
              (not just BUILDABLE, but WAITING and others) - see:
                https://issues.jenkins-ci.org/browse/JENKINS-32266?focusedCommentId=246354&page=com.atlassian.jira.plugin.system.issuetabpanels:comment-tabpanel#comment-246354
              Otherwise, the job may jump into build while there is
              a pipeline job queueing (this will disrupt the pipeline).
      -->
      <scanQueueFor>ALL</scanQueueFor>
      <blockingJobs>
{{ job_config['block_build'] }}
      </blockingJobs>
    </hudson.plugins.buildblocker.BuildBlockerProperty>
    {% endif %}

    <jenkins.advancedqueue.jobinclusion.strategy.JobInclusionJobProperty plugin="PrioritySorter@3.4">
      <useJobGroup>true</useJobGroup>
      {% if 'job_group_name' in job_config and job_config['job_group_name'] %}
      <jobGroupName>{{ job_config['job_group_name'] }}</jobGroupName>
      {% else %}
      <jobGroupName>default_group</jobGroupName>
      {% endif %}
    </jenkins.advancedqueue.jobinclusion.strategy.JobInclusionJobProperty>

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

    {% if 'scm_poll_timer_spec' in job_config %}
    {% if job_config['scm_poll_timer_spec'] %}
    <hudson.triggers.SCMTrigger>
      <spec>{{ job_config['scm_poll_timer_spec'] }}</spec>
      <ignorePostCommitHooks>false</ignorePostCommitHooks>
    </hudson.triggers.SCMTrigger>
    {% endif %}
    {% endif %}

  </triggers>

{% endmacro %}

###############################################################################
{% macro archive_artifacts(job_config, job_environ) %}

{% if 'archive_artifacts' in job_config %}

    <!--
        Archive and Fingerprint.
        For example, archiving initial build descriptor is only needed to
        trace jobs of the same pipeline execution.
    -->
    <hudson.tasks.ArtifactArchiver>
      <artifacts>{{ job_config['archive_artifacts']|join(',') }}</artifacts>
      <allowEmptyArchive>false</allowEmptyArchive>
      <onlyIfSuccessful>true</onlyIfSuccessful>
      <fingerprint>true</fingerprint>
      <defaultExcludes>true</defaultExcludes>
    </hudson.tasks.ArtifactArchiver>

{% endif %}

{% endmacro %}

###############################################################################
{% macro send_email_notifications(job_config, job_environ) %}

    #{#
    # NOTE: By default, without explicit `send_email_notifications`
    #       notifications are ENABLED.
    #}#
    {% if 'send_email_notifications' not in job_config or job_config['send_email_notifications'] %}
    <hudson.tasks.Mailer plugin="mailer@1.11">
      <recipients>{{ pillar['system_features']['email_notifications_lists']['jenkins']|join(' ') }}</recipients>
      <dontNotifyEveryUnstableBuild>false</dontNotifyEveryUnstableBuild>
      <sendToIndividuals>false</sendToIndividuals>
    </hudson.tasks.Mailer>
    {% endif %}

{% endmacro %}

###############################################################################
{% macro copy_artifacts(job_config, job_environ) %}

    <!--
        Copy fingerprinted and archived artifact just for the sake
        of reliably linking this job to the initial one in the pipeline.
    -->
    {% if 'input_fingerprinted_artifacts' in job_config %}
    {% for job_id in job_config['input_fingerprinted_artifacts'].keys() %}
    <hudson.plugins.copyartifact.CopyArtifact plugin="copyartifact@1.35.2">
      <project>{{ job_id }}</project>
      <filter>{{ job_config['input_fingerprinted_artifacts'][job_id] }}</filter>
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
    {% endfor %}
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

# Get key prefix to allow unique keys.
key_prefix = ''
if len(sys.argv) >= 3:
    key_prefix = sys.argv[2]

# Capture environment variables as dict structure.
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
{% macro locate_repository_dynamic_build_descriptor(job_config, job_environ, check_repo_dyn_build_desc = True) %}

{% from 'common/libs/host_config_queries.sls' import get_system_host_primary_user_posix_home with context %}

# Location of dynamic build descriptor in `build_history_role` repository.
# The purpose of this file is peristence.
# This is the location where the latest dynamic build descriptor
# is checked in at the end of each job.
{% from 'common/libs/repo_config_queries.lib.sls' import get_repository_id_by_role with context %}
{% set repo_id = get_repository_id_by_role('build_history_role') %}
{% set repo_config = pillar['system_features']['deploy_environment_sources']['source_repositories'][repo_id]['git'] %}
export REPO_DYN_BUILD_DESC_REPO_PATH="{{ get_system_host_primary_user_posix_home(repo_config['source_system_host']) }}/{{ repo_config['origin_uri_ssh_path'] }}"
export REPO_DYN_BUILD_DESC_PATH="${REPO_DYN_BUILD_DESC_REPO_PATH}/${BUILD_TITLE}/dynamic_build_descriptor.yaml"
{% if check_repo_dyn_build_desc %}
# Make sure it exists.
ls -lrt "${REPO_DYN_BUILD_DESC_PATH}"
{% endif %}

{% endmacro %}

###############################################################################
{% macro locate_dynamic_build_descriptor(job_config, job_environ, check_init_dyn_build_desc = True) %}

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

# Location of the parent build descriptor.
PARENT_DYN_BUILD_DESC_PATH='{{ job_environ['jenkins_dir_path'] }}/build_pipeline/parent.dynamic_build_descriptor.yaml'

# Let job continue from the latest.
cp "${LATEST_DYN_BUILD_DESC_PATH}" "${JOB_DYN_BUILD_DESC_PATH}"

{% endmacro %}

###############################################################################
{% macro update_dynamic_build_descriptor(job_config, job_environ) %}

{% from 'common/libs/host_config_queries.sls' import get_system_host_primary_user_posix_home with context %}
{% from 'common/libs/repo_config_queries.lib.sls' import get_repository_id_by_role with context %}
{% set repo_id = get_repository_id_by_role('build_history_role') %}
{% set repo_config = pillar['system_features']['deploy_environment_sources']['source_repositories'][repo_id]['git'] %}
REPO_PATH="{{ get_system_host_primary_user_posix_home(repo_config['source_system_host']) }}/{{ repo_config['origin_uri_ssh_path'] }}"

{% from 'common/jenkins/configure_jobs_ext/common_xml_templates.lib.sls' import locate_repository_dynamic_build_descriptor with context %}
{{ locate_repository_dynamic_build_descriptor(job_config, job_environ) }}

# Record `latest_commit_ids` in build history unless it is read-only restore.
if [ "${RESTORE_PARENT_BUILD_ONLY}" != "true" ]
then
    cd "${REPO_PATH}"
    CURRENT_COMMIT_ID="$(git rev-parse --verify HEAD)"
    echo "${CURRENT_COMMIT_ID}" | python "${KEY_SETTER_PYTHON_SCRIPT}" "${JOB_DYN_BUILD_DESC_PATH}" "latest_commit_ids:{{ repo_id }}"
    cd -
fi

# Update the latest dynamic build desciptor by
# the one generated for this during job.
cp "${JOB_DYN_BUILD_DESC_PATH}" "${LATEST_DYN_BUILD_DESC_PATH}"

# NOTE: In case of `RESTORE_PARENT_BUILD_ONLY`,
#       do not keep track of dynamic build descriptor in history.
if [ "${RESTORE_PARENT_BUILD_ONLY}" != "true" ]
then
    cp "${JOB_DYN_BUILD_DESC_PATH}" "${REPO_DYN_BUILD_DESC_PATH}"
fi

export JOB_NAME="{{ job_environ['job_name'] }}"

cd "${REPO_PATH}"

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
# HEAD value means that repository is at detached head.
test "${CURRENT_BRANCH}" != "HEAD"

BUILD_BRANCH="$(python ${KEY_GETTER_PYTHON_SCRIPT} ${JOB_DYN_BUILD_DESC_PATH} "build_branches:{{ repo_id }}")"
test "${CURRENT_BRANCH}" == "${BUILD_BRANCH}"

# NOTE: Without `add --all` `diff-index` will not notice untracked files.
git add --all

# Display status.
git status

# NOTE: In case of `RESTORE_PARENT_BUILD_ONLY`,
#       there are supposed to be no changes to commit.
if [ "${RESTORE_PARENT_BUILD_ONLY}" != "true" ]
then

    # NOTE: If commit is made to `build_history_role`, there will new changes
    #       (for example, new `latest_commit_ids`) for `build_history_role`
    #       inside to-be-updated dyn build desc and for top level repository
    #       as new commits were made.
    #       These changes are ignored as they do not bear information which
    #       has to be restored from parent dyn build desc.
    git commit --author "${AUTO_COMMIT_GIT_AUTHOR_EMAIL}" -m "Auto-commit: dynamic build descriptor at ${JOB_NAME}"

else
    # Fail if there are any changes.
    git diff-index --ignore-submodules=all --exit-code HEAD
fi

git reset
git status

cd -

{% endmacro %}

###############################################################################
{% macro get_JENKINS_CLI_TOOL_INVOKE_STRING(job_config, job_environ) %}
{% set jenkins_http_port = pillar['system_features']['configure_jenkins']['jenkins_http_port'] %}
{% set config_temp_dir = pillar['posix_config_temp_dir'] %}
{% set jenkins_master_hostname = pillar['system_hosts'][pillar['system_host_roles']['jenkins_master_role']['assigned_hosts'][0]]['hostname'] %}
JENKINS_CLI_TOOL_INVOKE_STRING='java -jar jenkins-cli.jar -s "http://{{ jenkins_master_hostname }}:{{ jenkins_http_port }}/"'

# Download Jenkins CLI tool.
wget http://{{ jenkins_master_hostname }}:{{ jenkins_http_port }}/jnlpJars/jenkins-cli.jar -O jenkins-cli.jar
{% endmacro %}

###############################################################################
{% macro common_build_script_header(job_config, job_environ) %}

# Fail on non-zero exit code.
set -e
# Fail on undefined variables.
set -u
# Profide better debug output.
set -x
PS4='+${LINENO}: '
# Also print every line as in script (including comments).
set -v
# Return last non-zero exit code from piped command.
# See: http://unix.stackexchange.com/a/14282/23886
set -o pipefail

# Set minimal job duration.
# Otherwise, if there are short jobs in the queue, the build history
# shows them started at the same time (confusing during analysis).
sleep 2

# Unset proxy variables.
# By default, there is no need to access Internet the way when these
# variables get used.
unset http_proxy
unset https_proxy

env

{% if 'skip_script_execution' in job_config and job_config['skip_script_execution'] %}
# Skip execution because `skip_script_execution` is `True`.
exit 0
{% endif %}

{% if 'skip_if_true' in job_config %}
if [ "${{ '{' }}{{ job_config['skip_if_true'] }}:-false}" == "true" ]
then
    exit 0
fi
{% endif %}

# The higher the status the more severe the problem.
JOB_STATUS='0'

{% from 'common/jenkins/configure_jobs_ext/common_xml_templates.lib.sls' import get_JENKINS_CLI_TOOL_INVOKE_STRING with context %}
{{ get_JENKINS_CLI_TOOL_INVOKE_STRING(job_config, job_environ) }}

#######################################################################
# In-place Python script which captures stdin data under
# specified key in destination dict.

KEY_SETTER_PYTHON_SCRIPT=$(mktemp)
cat &lt;&lt;HEREDOC_MARKER &gt; ${KEY_SETTER_PYTHON_SCRIPT}
{{ key_setter_python_script(job_config, job_environ) }}
HEREDOC_MARKER

#######################################################################
# In-place Python script which returns data under
# specified key in destination dict on stdout.

KEY_GETTER_PYTHON_SCRIPT=$(mktemp)
cat &lt;&lt;HEREDOC_MARKER &gt; ${KEY_GETTER_PYTHON_SCRIPT}
{{ key_getter_python_script(job_config, job_environ) }}
HEREDOC_MARKER

{% endmacro %}

###############################################################################
{% macro common_build_script_footer(job_config, job_environ) %}

# Report status of the execution.
case "${JOB_STATUS}" in
0)
    exit 0
;;
1)
    # Set build unstable.
    # See: http://stackoverflow.com/a/8822743/441652
    eval "${JENKINS_CLI_TOOL_INVOKE_STRING} set-build-result unstable"
;;
*)
    # If not stable or unstable, fail the job.
    exit 1
;;
esac

{% endmacro %}

###############################################################################
{% macro add_job_environment_variables(job_config, job_environ) %}

    <!--
        NOTE: Inject both `job_environment_variables` and `preset_build_parameters`.
        In fact, they have the same purpose.
        The only difference is that `preset_build_parameters` are _also_
        propagated from the first job in the pipepline to others through
        dedicated shared properties file which is given to current job
        from previous job via Parameterized Trigger Plugin
        (rather than EnvInject Plugin).
    -->

    {% if 'job_environment_variables' in job_config or 'preset_build_parameters' in job_config %}

    <EnvInjectBuilder plugin="envinject@1.91.3">
      <info>
        <propertiesFilePath>{{ job_environ['jenkins_dir_path'] }}/job_env_vars.{{ job_environ['job_name'] }}.properties</propertiesFilePath>
      </info>
    </EnvInjectBuilder>

    {% endif %}

{% endmacro %}

###############################################################################
# EOF
###############################################################################

