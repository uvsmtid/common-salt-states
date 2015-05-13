<?xml version='1.0' encoding='UTF-8'?>
<com.cloudbees.plugins.credentials.SystemCredentialsProvider plugin="credentials@1.22">
  <domainCredentialsMap class="hudson.util.CopyOnWriteMap$Hash">
    <entry>
      <com.cloudbees.plugins.credentials.domains.Domain>
        <specifications/>
      </com.cloudbees.plugins.credentials.domains.Domain>
      <java.util.concurrent.CopyOnWriteArrayList>
{% set jenkins_slaves =
    pillar['system_host_roles']['jenkins-linux-slave-role']['assigned_hosts']
    +
    pillar['system_host_roles']['jenkins_windows_slave_role']['assigned_hosts']
%}
{% for jenkins_slave_id in jenkins_slaves %}
{% set jenkins_slave_config = pillar['system_hosts'][jenkins_slave_id] %}
        <com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey plugin="ssh-credentials@1.10">
          <scope>GLOBAL</scope>
{% from 'common/jenkins/credentials.lib.sls' import get_jenkins_credentials_id_by_host_id with context %}
          <id>{{ get_jenkins_credentials_id_by_host_id(jenkins_slave_id) }}</id>
          <description>{{ get_jenkins_credentials_id_by_host_id(jenkins_slave_id) }}</description>
          <username>{{ jenkins_slave_config['primary_user']['username'] }}</username>
          <!-- Password is not required for SSH public key auth.
          <passphrase></passphrase>
          -->
          <privateKeySource class="com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey$UsersPrivateKeySource"/>
        </com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey>
{% endfor %}
      </java.util.concurrent.CopyOnWriteArrayList>
    </entry>
  </domainCredentialsMap>
</com.cloudbees.plugins.credentials.SystemCredentialsProvider>
