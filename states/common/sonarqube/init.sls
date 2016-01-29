# Default SonarQube installation

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('fc') or grains['os_platform_type'].startswith('rhel7') %}

sonar_package:
    pkg.installed:
        - name: sonar
        - skip_verify: True
        - aggregate: True

deploy_sonar_configuration_file:
    file.managed:
        - name: '/opt/sonar/conf/sonar.properties'
        - source: 'salt://common/sonarqube/sonar.properties'
        - template: jinja
        - makedirs: True
        - dir_mode: 755
        - mode: 755
        - require:
            - pkg: sonar_package

deploy_sonar_init_file:                                                
    file.managed:                                                               
        - name: '/etc/init.d/sonar'    
        - source: 'salt://common/sonarqube/sonar'
        - template: jinja                                                       
        - makedirs: True                                                        
        - dir_mode: 755                                                         
        - mode: 755                                                             
        - require:                                                              
            - pkg: sonar_package

# Deploy plugins       
deploy_sonar_plugin_checkstyle:                                                
    file.managed:                                                               
        - name: '/opt/sonar/extensions/plugins/sonar-checkstyle-plugin-2.4.jar'                              
        - resource_repository: common-resources
        - item_parent_dir_path: common/sonarqube
        - item_base_name: sonar-checkstyle-plugin-2.4.jar
        - require:                                                              
            - pkg: sonar_package

deploy_sonar_plugin_findbugs:
    file.managed:                                                               
        - name: '/opt/sonar/extensions/plugins/sonar-findbugs-plugin-3.3.jar'
        - resource_repository: common-resources
        - item_parent_dir_path: common/sonarqube
        - item_base_name: sonar-findbugs-plugin-3.3.jar
        - require:
            - pkg: sonar_package

deploy_sonar_plugin_java:                                                 
    file.managed:                                                               
        - name: '/opt/sonar/extensions/plugins/sonar-java-plugin-3.9.jar' 
        - resource_repository: common-resources                                 
        - item_parent_dir_path: common/sonarqube                                
        - item_base_name: sonar-java-plugin-3.9.jar
        - require:                                                              
            - pkg: sonar_package 

deploy_sonar_plugin_pdf_report:                             
    file.managed:                                                               
        - name: '/opt/sonar/extensions/plugins/sonar-pdfreport-plugin-1.4.jar'
        - resource_repository: common-resources                                 
        - item_parent_dir_path: common/sonarqube                                
        - item_base_name: sonar-pdfreport-plugin-1.4.jar
        - require:                                                              
            - pkg: sonar_package 

deploy_sonar_plugin_pmd:
    file.managed:                                                               
        - name: '/opt/sonar/extensions/plugins/sonar-pmd-plugin-2.5.jar'
        - resource_repository: common-resources                                 
        - item_parent_dir_path: common/sonarqube                                
        - item_base_name: sonar-pmd-plugin-2.5.jar
        - require:                                                              
            - pkg: sonar_package 



# Start sonarqube service.
sonar_service:
    service.running:
        - name: sonar
        - enable: True
        - require:
            - pkg: sonar_package
            - file: deploy_sonar_configuration_file
            - file: deploy_sonar_plugin_checkstyle
            - file: deploy_sonar_plugin_findbugs
            - file: deploy_sonar_plugin_java
            - file: deploy_sonar_plugin_pdf_report
            - file: deploy_sonar_plugin_pmd
        
{% endif %}
# >>>
###############################################################################


