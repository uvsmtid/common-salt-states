
State `common.jenkins.configure_jobs` is designed to provide generic framework
for Jenkins job configuration.

TODO:
* Explain `job_config_function_source` field in pillar used by this state to access external macros.
* Add links to explanation about this `job_config_function_source` pillar key (when ready).

At the moment there is only one type of job used for all `job_config_function_source` values:
* `common/jenkins/configure_jobs_ext/simple_xml_template_job.sls`


TODO: Examples of job template XMLs for `xml_config_template` used with `common/jenkins/configure_jobs_ext/simple_xml_template_job.sls`:
* `common/jenkins/configure_jobs_ext/maven_project_job.xml` - new and generic for all Maven jobs.

