
File `states/common/jenkins/credentials.lib.sls` is a library with marcos for
jinja template (not a state on its own).

It was created to follow [one definition rule](https://en.wikipedia.org/wiki/One_Definition_Rule) approach
to provide single place where Jenkins credentials id is defined.

There is only single marco `get_jenkins_credentials_id_by_host_id`
at the moment which is used in:
* Jenkins master (server) `credentials.xml` file to store all configured credentials.
* Jenkins node configuration which requires credentials to connect slaves.
* Jenkins job configuration with Git plugin which requires gredentials to access remote repository.

