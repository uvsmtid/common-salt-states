import os

def do(conf):

    # TODO: Configure DNS by copying pre-generated `/etc/resolv.conf`.

    os.system("echo nameserver " + conf['dns_server_ip'])
    os.system("ping -c 3 " + conf['remote_hostname'])


