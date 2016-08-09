#!/usr/bin/env python

###############################################################################

import os
import sys
import yaml
import json
import logging
import jsonschema

###############################################################################

def convert_YAML_to_JSON(
    YAML_base_dir_path,
    JSON_base_dir_path,
    curr_rel_dir_path,
):
    # Each directory is expected to have single `schema.json.yaml` file
    # to be converted into `schema.json` file.

    loaded_data = None
    # Open input YAML file.
    with open(
        os.path.join(
            YAML_base_dir_path,
            curr_rel_dir_path,
            'schema.json.yaml',
        ),
        'r',
    ) as yaml_data_file:
        logging.debug('yaml_data_file = ' + str(yaml_data_file))
        loaded_data = yaml.load(yaml_data_file)
    # Create all directories in path.
    dst_dir_path = os.path.join(
        JSON_base_dir_path,
        curr_rel_dir_path,
    )
    if not os.path.exists(dst_dir_path):
        os.makedirs(dst_dir_path)
    # Open output JSON file.
    with open(
        os.path.join(
            dst_dir_path,
            'schema.json',
        ),
        'w',
    ) as json_data_file:
        json.dump(loaded_data, json_data_file, sort_keys=True, indent=4)

    # Get list of directories in under current directory.
    curr_dir_path = os.path.join(
        YAML_base_dir_path,
        curr_rel_dir_path,
    )
    dirs = [ d for d in os.listdir(curr_dir_path) if os.path.isdir(os.path.join(curr_dir_path, d))]

    # Recursively convert files in other directories.
    for dir in dirs:
        convert_YAML_to_JSON(
            YAML_base_dir_path,
            JSON_base_dir_path,
            os.path.join(
                curr_rel_dir_path,
                dir,
            ),
        )

###############################################################################

def main():

    # Load pillars to validate schema.
    pillars_data = None
    with open(
        sys.argv[1],
        'r',
    ) as yaml_pillars_file:
        logging.warning('yaml_pillars_file = ' + str(yaml_pillars_file))
        pillars_data = yaml.load(yaml_pillars_file)

    # Convert all YAML files into JSON.
    convert_YAML_to_JSON(
        'pillars.schema.json.yaml',
        'pillars.schema.json',
        '.',
    )

    # Load JSON schema.
    # NOTE: We only load initial file, all references to other external
    #       files composing full schema are epxected to be loaded by validator.
    schema_data = None
    with open(
        os.path.join(
            'pillars.schema.json',
            'schema.json',
        ),
        'r',
    ) as json_schema_file:
        logging.warning('json_schema_file = ' + str(json_schema_file))
        schema_data = json.load(json_schema_file)

    # Change directory for relative references to work.
    #os.chdir('pillars.schema.json')

    # See: https://github.com/EclecticIQ/TAXII-JSON-schemas/blob/master/validate.py#L30
    # See: http://stackoverflow.com/a/33124971/441652
    schema_dir_abs_path = os.path.realpath('pillars.schema.json')
    base_uri = 'file://' + schema_dir_abs_path + '/'
    logging.warning("base_uri: " + str(base_uri))
    resolver = jsonschema.RefResolver(
        referrer = schema_data,
        base_uri = base_uri,
    )

    # Validate pillars data against the schema.
    jsonschema.validate(
        pillars_data,
        schema_data,
        resolver = resolver,
    )

    logging.warning("SUCCESS")

###############################################################################
# MAIN

# Execute further only if this file is executed as a script
# (not imported as a module).
if __name__ == '__main__':
    main()

###############################################################################
# EOF
###############################################################################

