
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
*   heterogeneous platforms: Linux, Windows, Mac, etc.

In order to instantiate a system, in addition to the content of this
repository, some external resource may also be required:
*   COTS software installers on local file system or remote file servers
*   YUM, Maven, and other package repositories
*   Subversion, Git and other source control repositories

See also [official Salt documentation](http://docs.saltstack.com/en/latest/).

# Offline Bootstrap #

One distinctive feature of this framework is generation of
[offline bootstrap package](docs/bootstrap) to bring up
entire systems on hosts from clean OS.

# Get Started #

*   [Salt Installation](docs/salt_installation.md)
    provides every detail to get Salt up and running
    on RHEL-based system.

*   [Salt Configuration](docs/salt_configuration.md)
    enables [this framework](docs/framework.md).

*   [Salt Runtime](docs/salt_runtime.md)
    introduces steps to automate deployment.

# Documentation #

*   [Features](docs/features.md)
    describe architecture to simplify definition of complex systems.

*   [`docs`](docs/readme.md)
    directory structure explains how to navigate documentation.

*   [Versioning](docs/versioning.md) explains rules for
    development and maintenance.

