
TODO:
* This is not a document where conventions are all fully described.
* Add sectons with explanation why specific convention is needed and link it to the location where it is detailed.

For example:
* Conventions for documenting states: [docs/states/readme.md][docs/states/readme.md]
* Conventions for documenting pillars: [docs/pillars/common/readme.md][docs/pillars/common/readme.md]

TODO:
* Move `docs/pillars/common/readme.md` to `docs/pillars/readme.md` to make general conventions for pillars consistent with location of general conventions for states `docs/states/readme.md`.


## Any other (non-state) files accessible through `salt://` ##

Files under the state tree (under `states` directory) which are not states
should not have `.sls` extention.

Otherwise, each such files is expected to have documentation by replacing
`.sls` extention with `.md`.

TODO: All files with external `macros` which are not supposed to be called
as states directly should have extention `.slslib`.


TODO: Fix discrepancy if such exists.


