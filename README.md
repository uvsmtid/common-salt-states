
Start from [documentation](docs/main.md) tailored for these sources.

## What are these sources?

It's Infrastructure as Code implemented using [Salt framework](http://saltstack.com/).

Using these sources together with external resources it is possible to
automatically deploy:
* developer environments
* continuous integration platforms
* production systems

Salt framework simplifies dealing with:
* consistent identical deployment across multiple hosts
* various stages of software cycles: development, testing, production, etc.
* heterogeneous platforms: Linux, Windows, etc.

In order to instantiate a system, in addition to the content of this
repository some external resource may also be required:
* content of local file system or remote file servers
* YUM, Maven, and other package repositories
* Subversion, Git and other source control repositories

The [official Salt documentation](http://docs.saltstack.com/en/latest/) provides
detailed information of all Salt aspects.

## Contents of the top directory:

* `docs`
All documentation materials.
* `pillars`
Salt static configuration data (consumed by `states`).
* `states`
Salt states executable data to define require system configuration.
* `resources`
Additional files which are NOT supposed to be under source control.
* `TODO`
Chaotic information about things to be done (miserable replacement for issue tracking system).
* `*`
Other undescribed files add no particular value at the moment.

