
* Split common and projects into separate git repositories.
  However, in order to make them plugable to with each other, there are
  several requirements to fulfil:
  * If a project is plugged in, there is no need to change any of its sources.
    The only thing shich should be done is changed Salt configuration file.
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

* There should be a script to run which automatcailly adjusts symlinks
  to plugable project repository within `common` repository, for example:
  ```
  scripts/plug_project_repo.sh project_name /abs/path/to/project/repo
  ```

* There should be a script to run on salt master to make sure that all
  minions listed in `salt-key` (or accessed through `salt '*' test.ping) are
  actually defined in the project `system_hosts`.

* There could be a mechanisim defeloped which allows Salt master to
  automatically accept minions defined in specific project.
  Whether minions can spoof it or not - this is another question.
  At the moment no spoof-proof authentication needs to be done - just
  automate.

