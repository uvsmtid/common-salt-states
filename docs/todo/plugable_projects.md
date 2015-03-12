
# Requirements #

* TODO: Split common and projects into separate git repositories.
  However, in order to make them plugable to with each other, there are
  several requirements to fulfil:
  * If a project is plugged in, there is no need to change any of its sources.
    The only thing which could be done is changed Salt configuration file.
  * Links in documentation should be valid (browsable) through projects
    repositories (i.e. on GitLab).
  * Pillar should be automatically accessible if Salt configuration file
    indicates that this project is plugged in.
  * The `/srv/pillars` and `/srv/states` should only be symlinked to
    the `common` repository. A project is plugged in by adding symlinks
    from within `common` repository to the plugged project.
  * The best part whould be ability to put entire source code of
    plugable repository under single directory of `common` repository
    so that they can be developed as single entity via Git submodules.

* TODO: There should be a script to run which automatcailly adjusts symlinks
  to plugable project repository within `common` repository, for example:
  ```
  scripts/plug_project_repo.sh project_name /abs/path/to/project/repo
  ```

* TODO: There should be a script to run on salt master to make sure that all
  minions listed in `salt-key` (or accessed through `salt '*' test.ping) are
  actually defined in the project `system_hosts`.

* TODO: There could be a mechanisim defeloped which allows Salt master to
  automatically accept minions defined in specific project.
  Whether minions can spoof it or not - this is another question.
  At the moment no spoof-proof authentication needs to be done - just
  automate.

# Proposal #

Plug in projects as additional entry in `file_roots` in Salt config.

At the moment there are two entries: for main sources pointing to
salt states (`states`) and addditional pointing to source code repositories
which may be used in setup (`sources`).
```
file_roots:
    base:
        - /srv/states
        - /srv/sources
```
What if remove `/srv/sources` and rename `/srv/states` to `/srv/artifacts`?
We can generalize management of "projects", "sources" and "resources".
All of them are managed under the same pillar key (i.e.) named
`artifacts_configuration`. For the moment let's leave
"sources" and "resources".

## Mechanics ##

Let's say project `common` is represented as the following symlink:
```
/srv/artifacts/common => /path/to/repository/common.git/states/common
```
Such symlinks are automatically created based keys under
`artifacts_configuration`.

Note how the path from repository root is `states/common` - this is current
path for all `common` states.
All other projects are simply represented by a similar symlink:
```
/srv/artifacts/project_A => /path/to/repository/project_A.git/states/project_A
```

## Renames ##

This even allows several project to be under the same root (for example,
until they are split):
```
/srv/artifacts/project_B => /path/to/repository/project_A.git/states/project_B
```
It's also possible to represent all states in the `project_A` as `project_C`
```
/srv/artifacts/project_C => /path/to/repository/project_A.git/states/project_A
```

## Renames are possible but discauraged ##

If the name of the symlink under `/srv/artifacts` directory corresponds to
the project name, it obvious that no changes required to the references:
```
common.git => "/srv/artifacts"/"common"/"git" => ...
"/path/to/repository/common.git/states/common"/"git"/init.sls
```
In fact, renames should not be used. They only create confusion. They will
also break if `project_A.state_x` reference within the same renamed `project_A`
point to this same project - reference will be broken because the project
is renamed into `project_B`.

## Other artifacts ##

Now let's come back to other types of artifacts: "sources" and "resources".

In fact, "projects" is just a "source" artifact without no additional
meaning to this framework. Only the fact that there can be some Salt states
makes it a "project", but requires no additional implementation for
the framework as long as "sources" are well managed.

The "resources" are actually just another `type` of artifacts. And just
like with "projects", if all supported types of artifacts are managed well,
there is no difference.

In other words, all "projects", "sources" and "resources" are managed by
abstract concept of "artifacts".

## Conclusion ##

Let's review how we met requirements:
* MET: System state can be split into multiple repositories depending on
  the project.
* MET: If a project is plugged in, there is no need to change any
  of its sources. The only thing which could be done is changed Salt
  configuration file.
  * Even configuration file does not need to be changed - there is a static
    reference to `/srv/artifacts`.
* MET: Links in documentation should be valid (browsable) through projects
  repositories (i.e. on GitLab).
  * If projects do not change current structure, and named correspondingly,
    the links won't be broken.
* MET: Pillar should be automatically accessible if Salt configuration file
  indicates that this project is plugged in.
  * This simply requires the same approach for `pillar_roots`:
    ```
    /srv/pillars/common => path/to/repository/common.git/pillars/common
    ```
* MET: The `/srv/pillars` and `/srv/states` should only be symlinked to
  the `common` repository. A project is plugged in by adding symlinks
  from within `common` repository to the plugged project.
  * But why is this important? It's important only to use single directory
    for all changes in all plugged in projects.
    But it is still possible to add symlinks (i.e.) from `common` to
    `project_A` like this symlink:
    ```
    /path/to/repository/common.git/states/project_A => /path/to/repository/project_A.git/states/project_A
    ```
    The intent behind requirement is met.
* MET: The best part whould be ability to put entire source code of
  plugable repository under single directory of `common` repository.
  * Already discussed above.

# [footer] #

