
If field `use_pillars_from_states_repo` is true, Salt is set up
to load pillars from states repository instead of pillars.
The profile stored inside pillars of states repository is called generic
(because it cannot be specific to individual system when the same
states repository is used in multiple locations).

Normally, it should be false (pillars should be in separate repository).

