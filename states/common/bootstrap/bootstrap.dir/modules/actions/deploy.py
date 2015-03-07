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
        assert(use_case is not None)
        logging.debug("use_case = '" + use_case + "'")

        logging.debug("do step: init_ip_route")
        self.init_ip_route()

        logging.debug("do step: init_dns_server")
        self.init_dns_server()

        logging.debug("do step: make_salt_resolvable")
        self.make_salt_resolvable()

        logging.debug("do step: init_yum_repos")
        self.init_yum_repos()

        # Salt master is not installed for for all use cases.
        if use_case in [
            'initial-master',
        ]:
            logging.debug("do step: install_salt_master")
            self.install_salt_master()
        else:
            logging.debug("skip step: install_salt_master")

        # Salt minion is installed in all use cases.
        # The difference is only in its configuration.
        logging.debug("do step: install_salt_minion")
        self.install_salt_minion()

        # Artifacts are linked only on machines which have access to them.
        if use_case in [
            'initial-master',
            'standalone-minion',
        ]:
            logging.debug("do step: link_sources")
            self.link_sources()
            logging.debug("do step: link_resources")
            self.link_resources()
        else:
            logging.debug("skip step: link_sources")
            logging.debug("skip step: link_resources")

        if use_case in [
            'initial-master',
        ]:
            logging.debug("do step: activate_salt_master")
            self.activate_salt_master()
        else:
            logging.debug("skip step: activate_salt_master")

        # Note that Salt minion is not activated for `standalone-minion`.
        if use_case in [
            'initial-master',
            'online-minion',
        ]:
            logging.debug("do step: activate_salt_minion")
            self.activate_salt_minion()
        else:
            logging.debug("skip step: activate_salt_minion")

        logging.debug("do step: run_init_states")
        self.run_init_states()

        if use_case in [
            'standalone-minion',
        ]:
            logging.debug("do step: run_highstate")
            self.run_highstate()
        else:
            logging.debug("skip step: run_highstate")

###############################################################################
# EOF
###############################################################################

