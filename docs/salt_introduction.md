
TODO:
* Add more details and links to official docs.
* Templates
* Jobs

NOTE:
* Explain that Salt does things but doess not undo them (i.e. `yum` both does and undoes - installs and uninstalls packages). And add about important requirements to states to be re-run-able as well as limitations of the approach (i.e. need to look up what should be done to actually re-run installation - remove some files, delete some virtual networks, etc.).

## Master and Minions ##

Salt typically has two running software components:
* Single Salt *master*
* Multiple Salt *minions*

## Configuration input ##

There are only three terms anyone should be clear about when using Salt:

* [States](http://docs.saltstack.com/en/latest/topics/tutorials/starting_states.html)
* [Pillars](http://docs.saltstack.com/en/latest/topics/tutorials/pillar.html)
* [Grains](http://docs.saltstack.com/en/latest/topics/targeting/grains.html)

## YAML ##

All configuration files for States, Pillars and Grains are typically written in YAML.

YAML is simply a visually convenient text format to define data in lists and dictionaries (key-value associated arrays).

## External macros ##

TODO: Examples of external "libraries" with macros:
* `states/common/jenkins/install_plugin.sls`
* `states/common/jenkins/configure_jobs_ext/simple_xml_template_job.sls`
TODO: Add links to both their documentation and files with implementation.
TODO: Add links to states (both docs and implementation) where they are used, for example:
* `install_plugin.sls` is used in `states/common/jenkins/cygwin/init.sls`, `states/common/jenkins/git/init.sls`, `states/common/jenkins/maven/init.sls`
* `simple_xml_template_job.sls` is used for pillar data like `pillar['system_hosts']['configure_jenkins'][_id]['job_configs'][_id]['job_config_function_source']`
TODO: Mention `orchestration` in a similar way when finished.


