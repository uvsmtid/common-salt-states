# Branching #

This repository follows branching model
similar to [Vincent Driessen's document][1].

Release tags are named as described in [versioning document][2].

## Branch names ##

*   _Permanent_ branches:

    *   `develop`

        All branches are eventually merged into this branch unless
        these branches were abandoned features.

    *   ~~`master`~~

        This branch is not necessarily maintained
        but it is reserved for its purpose (stable _"production ready_" code).

        The _"production ready"_ code is maintained on release branches.

*   _Release_ branches:

    *   `release-vMAJOR.MINOR.PATCH`

        The release branch is created before
        tag `vMAJOR.MINOR.PATCH` is made.

    *   ~~`hotfix-vMAJOR.MINOR.PATCH`~~

        These branches are not maintained.

        Any _"critical bug in a production version"_ is managed through
        new `PATCH`-level `release-vMAJOR.MINOR.PATCH+1` branch.

*   _Task_ branches:

    *   `*`

        Any other branches are considered a task branch.

## Rules ##

Some [quotes from original doc][1] and amendments:

*   _When the source code in the `develop` branch reaches a stable point and is ready to be released,_
    ~~_all of the changes should be merged back into master somehow and then tagged with a release number."_~~
    release branch is supposed to be created.

*   _"All features targeted at future releases_
    ~~_may not - they must wait until after the release branch is branched off."_~~
    are simply merged into `develop` branch if accepted.

    Release branch is created from an agreed commit in the history
    of `develop` branch.

    Release branch cherry-picks merges of any missing features from `develop`
    made after the commit it was branched off.

*   _"It is exactly at the start of a release branch that the upcoming_
    _release gets assigned a version number—not any earlier."_

    In other words, we don't know release version number
    until this branch is created.

Additional rules:

*   A task branch is merged back into the branch it was branched off.

*   Fixes as `PATCH` in `vMAJOR.MINOR.PATCH` are done on `release-*` branch.

    All pathces are made in the release branches like
    `release-vMAJOR.MINOR.PATCH+1` which is branched off the version release
    tags like `vMAJOR.MINOR.PATCH` where the bug was confirmed.

    Technically, the pach is not applicable to any other version releases
    until corresponding bug is also confirmed there.

*   Features as `MINOR` in `vMAJOR.MINOR.PATCH` are done on either
    `release-*` or `develop` branch.

*   Features as `MAJOR` in `vMAJOR.MINOR.PATCH` are by their definition
    always done in `develop` branch.

*   If the same MINOR feature or PATCH fix is required in other
    `release-*` branches, they may be cherry-picked there.

    Note that cherry-picking from `release-*` branch into `develop`
    does not make sense because all branches are supposed to
    eventually merge into `develop` anyway.

# [footer] #

[1]: http://nvie.com/posts/a-successful-git-branching-model/
[2]: /docs/versioning.md