import os

def do(action_context):

    # TODO: Configure DNS by copying pre-generated `/etc/resolv.conf`.

    os.system("echo nameserver " + action_context.conf_m.init_dns_server['dns_server_ip'])
    os.system("ping -c 3 " + action_context.conf_m.init_dns_server['remote_hostname'])


