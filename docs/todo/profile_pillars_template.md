TODO

This document is similar (related) to [managing multitude of profiles][1]
with changed focus from (A) managing profiles in separate Git branches to
(2) the idea that there should be a template in `common-salt-states` to
be able to diff existing pillars against the structure of template.

# Requirements #

*   Directory structure should be diff-able between any project_name/profile.
    Pillar data common to two project_name/profile should be defined in similar
    directories and even files.

*   There are some special files in pillars which should be accessible
    in the target environment but not loadable as profile data.
    For example, [bootstrap target environments][2] are not supposed to be
    loaded as system profile - they are only loaded when bootstrap is
    generation is requied (and enabled) on the source system.

    In other words, pillar top should be able to load special pillar
    data, and there should be clearly a profile pillar data (which is
    actually what bootstrap consumes for its target environments).

*   There should be separation of pillars consumed by states
    in different project_names (common, or project_name-specific pillars) so
    that it is clear in each diff what changes should be considered
    and what should not.

*   Requirement to support multiple profiles in the same Git branch
    can be dropped. In other words, there may be nothing in the
    files/dirs structure which indicates what profile is checked out
    without looking at branch name in Git.

    In fact, it's already the case with the use of `this_system`
    directory. Because this directory always there, there is probably
    no need for this additional directory. Currently, it is simply
    separating "this system profile" from profiles for all other
    target environements of bootstrap. Bootstrap target environments
    should probably be moved under `boostrap` instead.

*   Pillars should still be under `pillars` directory in the root of
    Git repository. This is to make it clear where is required data
    and where is everything else (docs, some supporting scripts, etc.).
    It also makes this repository theoretically mergable with states
    (while this is not recommmended).

# Solutions #

*   Entire profile will be simply in `pillars/profile` sub-directory.

*   Pillars are split into common and project_name specific right under
    `pillars/profile` directory as
    *   `pillars/profile/common` - common pillar data
    *   `pillars/profile/[project_name] - project_name-specific pillar data
    This will allow at least common part be diff-able with common
    part of pillars for another project_name.

*   Top file loads additional special stuff from other subdirectories
    of top `pillars` directory in root of Git repo.

    For example, bootstrap profiles will be under
    `pillars/bootstrap/profiles/[profile-name]`.
    Note that this way bootstrap will only be able to access profile
    data from other environments (not special additional one they
    possibly load from their top file).

# [footer] #

[1]: docs/todo/managing_multitude_of_profiles.md
[2]: docs/bootstrap.md

