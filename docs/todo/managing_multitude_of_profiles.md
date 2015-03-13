
# Problem #

Every time state changes require pillar data (structure) changes, current
approach of maintaining pillar files for all environments incurs burden
of updating them all.

# Proposal #

What if there is no more multiple pillars? Instead, each environment is
simply in a different branch in Git repository.

Benefits:
* When two branches are merged, there is automatic detection of cuncurrent
  changes and conflict resolution.
* Merging of two branches will automatically apply patches to profile pillars.
  No need to do merge explicitly for each pillar. The work of merging pillars
  is distributed among people responsible for different system instances and
  it is only done when needed for specific system instance and actually
  testable on this system (not like pillars for multipe system instances
  under the same branch which have to be merged for all environments even
  though testing cannot be done at all).
* Multiple pillar files per system instance (not those multiple profile
  pillars for multiple instances) can be created where each type of
  information is under its own separate pillar file. Without maintaining
  multipe system profiles under the same branch, thid does not result
  in multiplication of pillar files.

Not so good:
* Unwanted changes taken on merge from pillar will need to be finally fixed.
  If unwanted changes fixed in separate commits (not in the original merge
  commit), next merge of commits from this branch will make this fixes
  will likely result in unwanted changes in another branch, and so on.
* Working on a long-coming featrue may require working on different system
  instances. This may require continuous merges from one profile branch into
  another profile branch which will polute history. Which branch has to be
  used in order to take latest changes for this feature?

# [footer] #

