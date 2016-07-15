
# Versioning #

The versioning scheme adheres to [Semantic Versioning][1]:

```
Given a version number MAJOR.MINOR.PATCH, increment the:
1.  MAJOR version when you make incompatible API changes,
2.  MINOR version when you add functionality in a backwards-compatible manner, and
3.  PATCH version when you make backwards-compatible bug fixes.
Additional labels for pre-release and build metadata are available as extensions to the MAJOR.MINOR.PATCH format.
```

See also [branching][4] document.

# Note on applicability of Semantic Versioning #

Public API in case of this framework is too wide
(too many items are exposed for any other `project_name` to rely on).
This makes it less practical to separate incompatible and compatible changes.
Effectively, any refactoring degenerate into `MAJOR` version
(as incompatible changes to public API become very likely).

Nevertheless, Semantic Versioning sill make sense
if there a chance to indicate backwards-compatible changes.

# Public API #

Public API of the framework are the following components:

*   Compiled pillar structure accessed by common Salt states.

    Because the entire framework relies on the data schema in pillars.

*   State ids like [`dummy_state`][3].

    Because are global for Salt and references to individual state ids
    (e.g. as dependencies) would break on rename.

*   Paths to files under [`states`][2] directory.

    Because references (e.g. as dependencies) to common states
    (which depend on their location on the file system) or any
    references to actual files as in `salt://common/dummy/init.sls`
    break on rename.

*   Paths to files under [`pillars`][4] directory.

    Because efficient use and maintenance of pillars requires
    use of defaults and overrides which depend on file path overlaps.

Technically, even key values (as opposed to key name) provided as
defaults in [`pillars`][4] directory may cause problems for
some `project_name`s (as it affects state execution logic).
Again, this highlights the difficulty of tracking such cases explained above.
Such cases are simply ignored (by this definition of public API).

# Examples of version number changes #

*   Examples when `MAJOR` version changes:

    *   Changing pillar structure (changing parent key of any key).

    *   Making any key in pillar structure required by any state.

    *   Redefining meaning of any key (even without changing its name).

    *   Moving, renaming or deleting any file under `states` directory.

    *   Removing or renaming any state id.

    These are incompartible API changes as anyone with exiting pillar
    won't be able to reuse it with newly released common Salt states.

*   Examples when `MINOR` version changes:

    *   Adding new pillar to the structure together with new features
        without making it mandatory.

    *   Adding new file under `states` directory.

    *   Adding new state ids.

    This may add new functionality without affecting existing deployments.

*   Examples when `PATCH` version changes:

    *   Fixing common Salt states without changing pillar structure.

    *   Changing content of any file under `states` directory without
        changing what is defined as public API and without repurpusing file.

# Clarifications #

## Choice of repository ##

Any pillars repository (`*-salt-pillars`) is specific to deployment and
cannot be part of framework release.

Any `project_name` states (`*-salt-states`) repository is specific to
`project_name` and cannot be part of framework release.

Therefore, logically, the framework is `common-salt-states` source code
which may be common for both multiple `project_name`s and multiple deployments.

## Choice of release name ##

Framework release must be reffered to by a tag within `common-salt-states`
repository. The tag must be named as `vMAJOR.MINOR.PATCH`
where `MAJOR`, `MINOR`, `PATCH` are numbers described above.

Any other tags are not supposed to be called "release".

# [footer] #

[1]: http://semver.org/
[2]: /states
[3]: https://github.com/uvsmtid/common-salt-states/blob/a39f21eb3b8dd10cb41d39bd8762e39d6ed27c4d/states/common/dummy/init.sls#L4
[4]: /docs/branching.md
[5]: /pillars

