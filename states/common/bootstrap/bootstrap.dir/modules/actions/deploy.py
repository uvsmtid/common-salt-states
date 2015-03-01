from context import action_context

class deploy_template_method (action_context):

    def do_action(
        self,
    ):
        self.init_ip_route()
        self.init_dns_server()
        self.init_yum_repos()
        self.install_salt_master()
        self.install_salt_minion()

