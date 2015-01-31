
TODO:
* Add more details and links to official docs.
* Templates
* Jobs

NOTE:
* Explain that Salt does things but doess not undo them (i.e. <tt>yum</tt> both does and undoes - installs and uninstalls packages). And add about important requirements to states to be re-run-able as well as limitations of the approach (i.e. need to look up what should be done to actually re-run installation - remove some files, delete some virtual networks, etc.).

## Master and Minions

Salt typically has two running software components:
* Single Salt *master*
* Multiple Salt *minions*

## Configuration input

There are only three terms anyone should be clear about when using Salt:

* [States](http://docs.saltstack.com/en/latest/topics/tutorials/starting_states.html)
* [Pillars](http://docs.saltstack.com/en/latest/topics/tutorials/pillar.html)
* [Grains](http://docs.saltstack.com/en/latest/topics/targeting/grains.html)

## YAML

All configuration files for States, Pillars and Grains are typically written in YAML.

YAML is simply a visually convenient text format to define data in lists and dictionaries (key-value associated arrays).




