
## Conventions to locate documentation for files under `states` directory ##

Each document under this directory provides documentation for corresponding
file under a given project.

The file in `states` directory and its documentation file matching one-to-one.
For example in `common` project:
* [File](docs/states/common/jenkins/master.sls.md) `common/jenkins/master.sls.md` documents `common.jenkins.master` state file.
* [File](docs/states/common/jenkins/init.sls.md) `common/jenkins/init.sls.md` documents `common.jenkins` state file.
* [File](docs/states/common/jenkins/credentials.lib.sls.md) `common/jenkins/credentials.lib.sls.md` documents `credentials.lib.sls.md` _template file_ (not a state).

Note that:
* Documentation file for each file under `states` directory can simply be found in corresponding directory under `docs` by adding `.md` extention.
* There is no special treatment for `init.sls` files as, for example, in conversion from state file `common/jenkins/init.sls` to dot notation `common.jenkins` (in particular, documentation file for `init.sls` does not become simply `readme.rd`).
* The `readme.rd` file for each directory is optional and may contain any documentation related to this directory as a whole.
* This is different convention compared to ["pillars" directory convention](docs/pillars/readme.md) where each document file one-to-one corresponds to a _pillar item_ (not a _file_).

