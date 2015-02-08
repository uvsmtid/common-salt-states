
Each document under this directory provides documentation for corresponding
state under `common` project, for example:
* [File](docs/projects/common/states/common/jenkins/master.md) `common/jenkins/master.md` documents `common.jenkins.master` state.
* [File](docs/projects/common/states/common/jenkins/readme.md) `common/jenkins/readme.md` documents `common.jenkins` state.

Note that:
* Using `.md` extenstion corresponds to similar convention to translate "dot notation" of state name like `common.jenkins.master` to its Salt state file `common/jenkins/master.sls`.
* Using `readme.md` file in the directory corresponds to similar convention to translate "dot notation" of state name like `common.jenkins` to its Salt state file using `init.sls` in state's directory `common/jenkins`. Look for **SLS File Namespace** for explanation of `init.sls` files [here](http://docs.saltstack.com/en/latest/topics/tutorials/states_pt1.html).

