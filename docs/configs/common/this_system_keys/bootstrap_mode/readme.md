
Key `bootstrap_mode` indicates how Salt master or standalone minion
were set up.

This information is required for some of the states. Majority of states
were originally designed to be run in Salt setup with central master server.
Later it became important to support standalone installation where many
states depend on role assingments. However, in standalone installation
each node is set up independently and plays roles like `control_role`
without assignments. In particular, standalone minion behaves essentially
as Salt master.

