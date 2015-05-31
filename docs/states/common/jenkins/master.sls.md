
State `common.jenkins.master` installs Jenkins Master (server).

Normally, Jenkins Master is only installed if a minion
is assigned [jenkins_master_role][1].

## Credentials ##

This state also configures Jenkins credentials to be used in Jenkins Slave
authentication. Each credential uses id composed using
[username][2] and [hostname][3]. This is different from UUID which can be
seen if `credentials.xml` file is modified
by Jenkins itself when credentials are configured through web UI.

At the moment entire `credentials.xml` file is overwritten every time
Jenkins master state is re-applied. So, do not add any other credentials
manually to avoid loosing this configuration.

## See also ##

*   [common.jenkins.maven][4]

[1]: /docs/pillars/common/system_host_roles/jenkins_master_role/readme.md
[2]: /docs/pillars/common/system_hosts/_id/primary_user/username/reame.md
[3]: /docs/pillars/common/system_hosts/_id/hostname/readme.md
[4]: /docs/states/common/jenkins/maven/init.sls.md

