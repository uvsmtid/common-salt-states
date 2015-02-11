
State `common.jenkins.maven` installs and configures Maven-related plugins for Jenkins:
* [Maven Project Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Maven+Project+Plugin)
* [M2 Release Plugin](https://wiki.jenkins-ci.org/display/JENKINS/M2+Release+Plugin)

Note that for some reason Maven configuration enabled by "Maven Project Plugin" is
provided for entire Jenkins (rather than per individual Jenkins slave node).
This confustion is [explained here](http://stackoverflow.com/q/28387142/441652).
It could be that Jenkins tries Maven configuration on slave until one of them works.

