
## What is orchestration?

Orchestration allows executing coordinated chain of actions across multiple
hosts with Salt minions controlled by Salt master.

Functions executed on Salt minion (i.e. `state.highstate`) are run non-stop
without any chance to coordinate with other minions. For example, if one
minion provides network file server and another downloads resources from it,
executing `state.highstate` on both of the minions results in race condition.
It is possible that the files can be tried to download before file server is
up and running.

In order to execute deployment in stages with cross-host inter-dependencies
between resources, orchestration should be used.

## Implementation

TODO

