###############################################################################

###############################################################################
{% macro parameterized_job_triggers_macro(job_config, jenkins_dir_path) %}

    {% if 'parameterized_job_triggers' in job_config %}
    <hudson.plugins.parameterizedtrigger.BuildTrigger plugin="parameterized-trigger@2.26">
      <configs>

    {% for trigger_config_name in job_config['parameterized_job_triggers'].keys() %}
    {% set trigger_config = job_config['parameterized_job_triggers'][trigger_config_name] %}
        <hudson.plugins.parameterizedtrigger.BuildTriggerConfig>
          <configs>
            <hudson.plugins.parameterizedtrigger.FileBuildParameters>
              <propertiesFile>{{ jenkins_dir_path }}/build.properties</propertiesFile>
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
# EOF
###############################################################################

