#!/usr/bin/env python

import subprocess as sub
import yaml
import re

distrib_pom_path = '/home/uvsmtid/Works/maritime-singapore.git/clearsea-distribution/pom.xml'

# Resolve (download) all dependencies locally so that next command
# can work offline.
sub.check_call(
    [
        'mvn',
        '-f',
        distrib_pom_path,
        'dependency:resolve',
    ],
)

# Get list of all dependencies. 
p = sub.Popen(
    [
        'mvn',
        '-f',
        distrib_pom_path,
        'dependency:list',
    ],
    stdout = sub.PIPE,
)

# Select lines with dependency items.
artifact_regex = re.compile(')
for line in p.stdout:
     
