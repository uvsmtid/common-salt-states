
Start from [this document](docs/readme.md) for custom setups.

# What are these sources? #

The sources provide _Infrastructure as Code_
implemented using [Salt framework](http://saltstack.com/).

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

# Contents of the top directory: #

* `docs`
   All documentation materials.
* `states`
   Salt states executable data to define require system configuration.
* `scripts`
   Support scripts for various purposes.
   These scripts are normally not supposed to be used by Salt states
   (in `states` directory) because files under `scripts` directory are not
   easily accessible through `salt://` URI scheme.

