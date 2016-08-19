
###############################################################################
#

system_tasks:

    jenkins_tasks:

        {% set job_template_id = 'promotion-bootstrap_package_approved' %}
        P-__-{{ job_template_id }}:

            enabled: True

            is_promotion: True

            restrict_to_system_role:
                - salt_master_role

            condition_type: manual_approval
            promotion_icon: star-orange-e

            job_config_function_source: 'common/jenkins/configure_jobs_ext/promotable_xml_template_job.sls'
            job_config_data:
                xml_config_template: 'common/jenkins/configure_jobs_ext/promotion-template.xml'

###############################################################################
# EOF
###############################################################################

