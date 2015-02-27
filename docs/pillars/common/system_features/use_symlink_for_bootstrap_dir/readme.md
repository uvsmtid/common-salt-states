
Key `use_symlink_for_bootstrap_dir` specifies whether bootstrap directory
is a symlink to working copy of repository.

If `use_symlink_for_bootstrap_dir` is set to `False`, a copy of bootstrap
directory will be deployed.

The symlink is preferred when bootstrap scripts are being developed and
tested. This makes it quick to modify them in the source without running
deployment through Salt to update the copy.

