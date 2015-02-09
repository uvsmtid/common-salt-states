
This dictionary defines various external content used by states.

Because each content item is defined using the same data structure, it is
possible to process such items automatically in various cases:
* verify that item can be downloaded using specified URL;
* verify integrity of the item against specified checksum;
* install item using standard state;
* etc.

For example, macros defined in `salt://common/jenkins/install_plugin.sls` [documented here](docs/projects/common/states/common/jenkins/install_plugin.md)
install Jenkins plugins automatically.

TODO:
* Add more detailed explanation of why.
* Add links to docs about other related pillars.

