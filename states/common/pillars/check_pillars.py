import sys
import yaml
import json
import jsonschema
import logging

yaml_schema = open(sys.argv[1])
logging.warning('yaml_schema = ' + str(yaml_schema))
schema = yaml.load(yaml_schema)

json_pillars = open(sys.argv[2])
logging.warning('json_pillars = ' + str(json_pillars))
pillars = json.load(json_pillars)

jsonschema.validate(pillars, schema)

logging.warning("SUCCESS")

