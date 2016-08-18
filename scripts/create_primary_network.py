#!/usr/bin/env python

# This script creates virtual network `primary_network` defined in
# provided `properties.xml` using `virsh` (`libvrit`).
# NOTE: The script has to be executed under `root` (with `sudo`).

import os
import sys
import imp
import yaml
import logging
import tempfile

# See answer:
#     http://stackoverflow.com/a/5540864/441652
from lxml import etree
from lxml import builder

from subprocess import call

# Example XML output for existing network:
#    > virsh net-dumpxml primary_network
#    <network ipv6='yes'>
#      <name>primary_network</name>
#      <uuid>ce04a4a5-400c-4e89-ac78-e6b933393914</uuid>
#      <forward mode='nat'>
#        <nat>
#          <port start='1024' end='65535'/>
#        </nat>
#      </forward>
#      <bridge name='virbr3' stp='on' delay='0'/>
#      <mac address='52:54:00:cd:ff:e0'/>
#      <ip address='192.168.40.1' netmask='255.255.255.0'>
#        <dhcp>
#          <range start='192.168.40.1' end='192.168.40.254'/>
#        </dhcp>
#      </ip>
#    </network>
#

# NOTE: It is possible to specify minimum parameters.
#       The XML file created for this script is minimal.
# TODO: It is assumed that detailed configuration is provided by Vagrant
#       (which overwrites initial specified here).
#    <network>
#      <name>primary_network</name>
#      <forward mode='nat'/>
#      <ip address='192.168.40.1' netmask='255.255.255.0'>
#    </networ>

def main():

    # Get specified path to `properties.yaml`.
    start_path = sys.argv[0]
    properties_file_path = sys.argv[1]
    logging.info('properties_file_path = ' + properties_file_path)

    # Load properties.
    props_file = None
    props = None
    try:
        props_file = open(properties_file_path, 'r')
    except:
        try:
            props_file.close()
        except:
            pass
        raise
    try:
        props = yaml.load(props_file)
    finally:
        props_file.close()

    # Compose data for XML file.
    em = builder.ElementMaker()
    network_e = em.network
    name_e = em.name
    forward_e = em.forward
    ip_e = em.ip

    xml = network_e(
        name_e('primary_network'),
        forward_e(mode = 'nat'),
        ip_e(address = props['primary_network']['network_ip_gateway'], netmask = props['primary_network']['network_ip_netmask']),
    )

    # Write XML file.
    et = etree.ElementTree(xml)
    xml_desc, xml_path = tempfile.mkstemp()
    os.close(xml_desc)
    logging.info('xml_path = ' + xml_path)
    with open(xml_path, 'w') as xml_file:
        et.write(xml_file, pretty_print=True)

    # Not sure what is the best command, so run both.
    call(['virsh', 'net-create', xml_path])
    call(['virsh', 'net-define', xml_path])

    # NOTE: It may happen that network is already created.
    #       Make sure it is started.
    call(['virsh', 'net-start', 'primary_network'])

###############################################################################
#
if __name__ == '__main__':
    main()

###############################################################################
# EOF
###############################################################################

