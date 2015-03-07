import logging

from context import action_context

###############################################################################
#
class deploy_template_method (action_context):

    ###########################################################################
    #
    def do_action(
        self,
    ):

        use_case = self.run_case
        logging.debug("use_case = '" + use_case + "'")

        self.init_ip_route()

        self.init_dns_server()

        self.make_salt_resolvable()

        self.init_yum_repos()

        self.install_salt_master()
        self.install_salt_minion()

        self.link_sources()

        self.link_resources()

        self.activate_salt_master()
        self.activate_salt_minion()

        self.run_init_states()

        self.run_highstate()

