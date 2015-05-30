
# Versioning #

Public API of the framework are the following components
*   compiled pillar structure accessed by common Salt states;
*   state ids like [`dummy_state`][3] which are global for Salt;
*   paths to files under [`states`][2] directory.

The versioning scheme adheres to [Semantic Versioning][1]:
```
Given a version number MAJOR.MINOR.PATCH, increment the:
1.  MAJOR version when you make incompatible API changes,
2.  MINOR version when you add functionality in a backwards-compatible manner, and
3.  PATCH version when you make backwards-compatible bug fixes.
Additional labels for pre-release and build metadata are available as extensions to the MAJOR.MINOR.PATCH format.
```

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

Any project_name states (`*-salt-states`) repository is specific to project_name and
cannot be part of framework release.

Therefore, the framework logically is `common-salt-states` source code
which may be common for both multiple project_names and multiple deployments.

## Choice of release name ##

Framework release must be reffered to by a tag within `common-salt-states`
repository. The tag must be named as `vMAJOR.MINOR.PATCH`
where `MAJOR`, `MINOR`, `PATCH` are numbers described above.

Any other tags are not supposed to be called "release".

## Choice of public API ##

Becides required pillar structure, any user of the framework may also
be dependent on common Salt states. For example, user may:
*   extend a Salt state;
*   include macros for Jinja template engine and use them;
*   etc.

At the moment, public API definition is limited to pillar structure only
ignoring any dependency user may have on common Salt states.

If practice causes frequent problems, it may change.

# [footer] #

[1]: http://semver.org/
[2]: /states
[3]: https://github.com/uvsmtid/common-salt-states/blob/a39f21eb3b8dd10cb41d39bd8762e39d6ed27c4d/states/common/dummy/init.sls#L4

