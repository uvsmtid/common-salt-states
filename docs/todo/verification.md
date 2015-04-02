TODO

* TODO: Add a framework which runs "unit tests" for pillar config.
  This is to verify that configuration conforms to some rules.
  For example, all hostnames and host roles ids must not contain
  `_` because this violates hostname rules (use `-` instead).
  There can be many different "unit tests" added (especially when
  certain types of configuratoin errors happen often).

