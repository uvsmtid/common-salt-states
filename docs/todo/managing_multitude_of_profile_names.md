TODO

This document is about maintaining pillar data of each profile_name in a
separate Git branch. [Another related document][1] is about having a
common template with recommended pillar files/dirs layout in the
filesystem with examples.

# Problem #

Every time any state changes require changes in pillar data (structure),
current approach of maintaining pillar files for all environments incurs
burden of updating them all.

# Proposal #

What if there is no more multiple pillars? Instead, each environment is
simply in a different branch of Git repository.

Benefits:

*   When two branches are merged, there is automatic detection of cuncurrent
    changes and conflict resolution.

*   Merging of two branches will automatically apply patches to profile
    pillars. No need to do merge explicitly for each pillar.
    The work of merging pillars
    is distributed among people responsible for different system instances
    and  it is only done when needed for specific system instance and actually
    testable on this system (not like pillars for multipe system instances
    under the same branch which have to be merged for all environments even
    though testing cannot be done at all).

*   Multiple pillar files per system instance (not those multiple profile
    pillars for multiple instances) can be created where each type of
    information is under its own separate pillar file. Without maintaining
    multipe system profile_names under the same branch, thid does not result
    in multiplication of pillar files.

Not so good:

*   Unwanted changes taken on merge from pillar will need to be finally fixed.
    If unwanted changes fixed in separate commits (not in the original merge
    commit), next merge of commits from this branch will make this fixes
    will likely result in unwanted changes in another branch, and so on.

*   Working on a long-coming featrue may require working on different system
    instances. This may require continuous merges of this feature branch
    from one profile_name branch into another profile_name branch which will polute
    history. Which branch has to be used in order to take latest changes
    for this feature?

*   How to deal with bootstrap? How to build bootstrap packages for other
    deployments?

    Current approach relies on loading additional profile_name pillar files.

    This is required to generate configuration for bootstrap script and
    download resources defined in this profile_names.

    In addition to bootstrap configuration, the target pillar is also
    rewritten to change location of sources and resources.
    Technically, this rewrite does not represent exact profile_name anymore
    and can be avoided to use pillar files verbatim from specific
    branch.

    So, how to solve the problem of generating bootstrap configuration
    and download resources based on the pillars from another Git branch?

    The only option is to load this pillar.
    Then, how to load pillar from another Git branch under
    different pillar key?

    The solution could be loading some pillars under different key
    from filesystem location which is pointed through symlinks to
    Git clones checked out at specific branches.
    We cannot load pillar data through pillar top files (of different
    branches), but we can require certain structure to load other
    data from other branches _similarily_.

    Or maybe the best approach is to be able to check out any branch
    and build bootstrap package on any master which was used
    for another profile_name? This requires that build procedure depend
    on nothing different in two profile_names (which makes it counter-intuitive
    as profile_names are ment to be different). For example, it is impossible
    to build bootstrap package when resources are in different location
    between two profile_names (resource download will fail).

# [footer] #

[1]: /docs/todo/profile_pillars_template.md

