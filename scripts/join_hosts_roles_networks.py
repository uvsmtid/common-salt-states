#!/usr/bin/env python

###############################################################################
#
# This script outputs a CSV table to STDOUT.
# It may use pre-saved YAML file with pillars or get current data by
# querying Salt (if the current host is a Salt minion):
#
#   # Use pre-saved file with pillars.
#   > ./join_hosts_roles_networks.py pillars.yaml > hosts_roles_networks.csv
#   # Query current pillars from Salt.
#   > ./join_hosts_roles_networks.py > hosts_roles_networks.csv
#
# The table is a join of the following objects from pillars:
# * `system_hosts`
# * `system_host_roles`
# * `system_networks`
#
# In other words, the original data from pillars
# is denormalized into CSV table.
#
# The script uses few transformations:
#   *   JSON loaded data to Python object.
#           See:
#               *   http://stackoverflow.com/q/1305532/441652
#   *   The Python objects are use SQLAlchemy Object-Relational Mapping (ORM)
#       to map their data into SQLite DB.
#           Install the following packages first:
#               python-sqlalchemy
#   *   The database is then queried to join all three tables.
#
###############################################################################

import os
import csv
import sys
import yaml
import pprint
import sqlite3
import logging
import datetime
import sqlalchemy

from sqlalchemy.ext.declarative import declarative_base

################################################################################
# Import non-standard modules.

# Determine path for additional modules to import.
start_path = sys.argv[0]
script_dir = os.path.dirname(start_path)
run_dir = os.getcwd()
if os.path.isabs(script_dir):
    modules_dir = os.path.join(
        script_dir,
        'modules',
    )
else:
    modules_dir = os.path.join(
        run_dir,
        script_dir,
        'modules',
    )
sys.path.append(
    modules_dir,
)

import utils.set_log
from utils.exec_command import call_subprocess

################################################################################
# Some globals.

# In-memory SQLite database.
engine = sqlalchemy.create_engine('sqlite://')

################################################################################
# Model for ORM mapping.

Base = declarative_base()

class host_roles_to_hosts_class(Base):

    __tablename__ = 'host_roles_to_hosts_table'

    host_role_id = sqlalchemy.Column(sqlalchemy.String, sqlalchemy.ForeignKey('host_roles_table.id'))
    host_id = sqlalchemy.Column(sqlalchemy.String, sqlalchemy.ForeignKey('hosts_table.id'))

    __table_args__ = (
        sqlalchemy.PrimaryKeyConstraint('host_role_id', 'host_id'),
        {},
    )

    # See: http://stackoverflow.com/a/38929089/441652
    def __init__(self, **entries):
        self.__dict__.update(entries)

class networks_to_hosts_class(Base):

    __tablename__ = 'networks_to_hosts_table'

    network_id = sqlalchemy.Column(sqlalchemy.String, sqlalchemy.ForeignKey('networks_table.id'))
    host_id = sqlalchemy.Column(sqlalchemy.String, sqlalchemy.ForeignKey('hosts_table.id'))

    __table_args__ = (
        sqlalchemy.PrimaryKeyConstraint('network_id', 'host_id'),
        {},
    )

    # See: http://stackoverflow.com/a/38929089/441652
    def __init__(self, **entries):
        self.__dict__.update(entries)

class hosts_class(Base):

    __tablename__ = 'hosts_table'

    id = sqlalchemy.Column(sqlalchemy.String, primary_key = True)
    hostname = sqlalchemy.Column(sqlalchemy.String)
    consider_online_for_remote_connections = sqlalchemy.Column(sqlalchemy.Boolean())

    host_roles_relationship = sqlalchemy.orm.relationship(
        'host_roles_class',
        secondary = 'host_roles_to_hosts_table',
        back_populates = 'hosts_relationship',
    )

    hosts_networks_relationship = sqlalchemy.orm.relationship(
        'networks_class',
        secondary = 'networks_to_hosts_table',
        back_populates = 'hosts_relationship',
    )

    # See: http://stackoverflow.com/a/38929089/441652
    def __init__(self, **entries):
        self.__dict__.update(entries)

class host_roles_class(Base):

    __tablename__ = 'host_roles_table'

    id = sqlalchemy.Column(sqlalchemy.String, primary_key = True)
    hostname = sqlalchemy.Column(sqlalchemy.String)

    hosts_relationship = sqlalchemy.orm.relationship(
        'hosts_class',
        secondary = 'host_roles_to_hosts_table',
        #back_populates = 'host_roles_relationship',
    )

    # See: http://stackoverflow.com/a/38929089/441652
    def __init__(self, **entries):
        self.__dict__.update(entries)

class networks_class(Base):

    __tablename__ = 'networks_table'

    id = sqlalchemy.Column(sqlalchemy.String, primary_key = True)
    broadcast = sqlalchemy.Column(sqlalchemy.String)
    gateway = sqlalchemy.Column(sqlalchemy.String)
    netmask = sqlalchemy.Column(sqlalchemy.String)
    netprefix = sqlalchemy.Column(sqlalchemy.String)
    subnet = sqlalchemy.Column(sqlalchemy.String)

    hosts_relationship = sqlalchemy.orm.relationship(
        'hosts_class',
        secondary = 'networks_to_hosts_table',
        back_populates = 'hosts_networks_relationship',
    )

    # See: http://stackoverflow.com/a/38929089/441652
    def __init__(self, **entries):
        self.__dict__.update(entries)

################################################################################
#

def load_database(pillars):

    Base.metadata.create_all(engine)

    DBSession = sqlalchemy.orm.sessionmaker(bind = engine)
    session = DBSession()

    for host_id in pillars['system_hosts'].keys():
        logging.info('host_id: ' + host_id)
        host_d = pillars['system_hosts'][host_id]
        host_d['id'] = host_id
        host_o = hosts_class(**host_d)
        session.add(host_o)
        for network_id in host_d['host_networks']:
            logging.info('host_id:network_id: ' + host_id + ':' + network_id)
            network_to_host_d = {}
            network_to_host_d['network_id'] = network_id
            network_to_host_d['host_id'] = host_id
            network_to_host_o = networks_to_hosts_class(**network_to_host_d)
            session.add(network_to_host_o)

    for host_role_id in pillars['system_host_roles'].keys():
        logging.info('host_role_id: ' + host_role_id)
        host_role_d = pillars['system_host_roles'][host_role_id]
        host_role_d['id'] = host_role_id
        host_role_o = host_roles_class(**host_role_d)
        session.add(host_role_o)
        for host_id in host_role_d['assigned_hosts']:
            logging.info('host_role_id:host_id: ' + host_role_id + ':' + host_id)
            host_role_to_host_d = {}
            host_role_to_host_d['host_role_id'] = host_role_id
            host_role_to_host_d['host_id'] = host_id
            host_role_to_host_o = host_roles_to_hosts_class(**host_role_to_host_d)
            session.add(host_role_to_host_o)

    for network_id in pillars['system_networks'].keys():
        logging.info('network_id: ' + network_id)
        network_d = pillars['system_networks'][network_id]
        network_d['id'] = network_id
        network_o = networks_class(**network_d)
        session.add(network_o)

    session.commit()

    return session

################################################################################
#

def query_database(session):

    # Because the same table is used in different context,
    # we are forced to use aliases.
    a_hosts_class = sqlalchemy.orm.aliased(hosts_class)
    b_hosts_class = sqlalchemy.orm.aliased(hosts_class)

    query = (
        session.query(
            a_hosts_class,
            b_hosts_class,
            host_roles_class,
            networks_class,
        )
        .join(a_hosts_class, host_roles_class.hosts_relationship)
        .join(b_hosts_class, networks_class.hosts_relationship)
        # Not sure how to join `a_hosts_class` and `b_hosts_class` -
        # there are conflicting columns ids - `filter` does the job.
        .filter(a_hosts_class.id == b_hosts_class.id)
        .with_entities(
            # Reduce number of identical columns by selecting only
            # one aliased entity.
            a_hosts_class,
            host_roles_class,
            networks_class,
        )
    )

    return query

################################################################################
#

def write_query_to_csv(query):

    writer = csv.writer(sys.stdout)

    # Get list of columns for header.
    column_names = []
    for desc in query.column_descriptions:
        column_names += [
            desc['type'].__table__.name + '.' + c
            for c in desc['type'].__table__.columns.keys()
        ]

    # Write header to CSV file.
    writer.writerow(column_names)

    # Write all rows to CSV file.
    for row in query:
        values = []
        for item in row:
            for col in item.__table__.columns:
                values.append(item.__dict__[col.name])

        writer.writerow(values)

################################################################################
#

def load_pillars(
    file_path = None,
):

    salt_output = None

    if file_path is None:

        logging.info("File path with pillars is not specified - getting pillars from Salt.")

        # Run Salt's `pillar.items` and captrue its output.
        command_args = [
            'sudo',
            'salt-call',
            '--out=yaml',
            'pillar.items',
        ]
        process_output = call_subprocess(
            command_args,
            capture_stdout = True,
        )

        # Parse profile pillars content.
        salt_output = process_output['stdout']

    else:

        with open(file_path, 'r') as data_file:
            salt_output = data_file.read()

    pillars = yaml.load(salt_output)

    # Return profile pillars loaded in memory.
    # NOTE: Output of `salt-call` contain first-level key `local`.
    return pillars['local']

################################################################################
#

def print_yaml(data):

    yaml.dump(
        data,
        sys.stdout,
        default_flow_style = False,
        indent = 4,
    )

################################################################################
#

def main():

    # Set log level.
    utils.set_log.setLoggingLevel('debug')

    # Debug SQL.
    logging.basicConfig()
    logging.getLogger('sqlalchemy.engine').setLevel(logging.INFO)

    # Pillars can be supplied inside file (Salt output for `pillar.items`)
    # or not (script will get pillars from Salt).
    pillars = None
    if len(sys.argv) >= 2:
        pillars = load_pillars(sys.argv[1])
    else:
        pillars = load_pillars()

    session = load_database(pillars)
    query = query_database(session)
    write_query_to_csv(query)
    session.close()

###############################################################################
# MAIN

# Execute further only if this file is executed as a script
# (not imported as a module).
if __name__ == '__main__':
    main()

###############################################################################
# EOF
###############################################################################

