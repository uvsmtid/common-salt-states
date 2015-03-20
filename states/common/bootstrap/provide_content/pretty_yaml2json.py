#!/usr/bin/env python

# This script loads data in YAML format and pretty-prints it in JSON on STDOUT.
# The input file should be the 1st argument.

import sys
import yaml
import json

with open(sys.argv[1], 'r') as yaml_file:
    loaded_data = yaml.load(yaml_file)

print json.dumps(loaded_data, indent=4, sort_keys=True)

