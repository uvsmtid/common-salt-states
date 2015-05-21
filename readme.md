
Start from [this document](docs/readme.md) for custom setups.

# What are these sources? #

The sources provide _"Infrastructure as Code"_
framework on top of [Salt](http://saltstack.com/).

The sources serve as common framework for other projects to
automatically deploy:
*   developer environments
*   continuous integration platforms
*   production systems

Salt framework simplifies dealing with:
*   consistent identical deployment across multiple hosts
*   various stages of software cycles: development, testing, production, etc.
*   heterogeneous platforms: Linux, Windows, etc.

In order to instantiate a system, in addition to the content of this
repository, some external resource may also be required:
*   COTS software installers on local file system or remote file servers
*   YUM, Maven, and other package repositories
*   Subversion, Git and other source control repositories

See also [official Salt documentation](http://docs.saltstack.com/en/latest/).

# Contents of this top directory #

*   `docs`

    All documentation for this common framework.

*   `states`

    Salt states executable data to define require system configuration.

*   `scripts`

    Support scripts for various purposes.

    These scripts are those which are not supposed to be used by Salt states
    (under `states` directory) because files under `scripts` directory are not
    easily accessible through `salt://` URI scheme.

*   `pillars`

    Salt pillars which can be cloned to configure system profile for
    individual deployment.

