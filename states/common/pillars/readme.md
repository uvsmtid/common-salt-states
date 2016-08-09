
The `check_pillars.py` script uses JSON schema expressed in YAML
under `pillars.schema.json.yaml` directory.

See: http://json-schema.org/

YAML is used to add comments and relax syntax rules for convenience.
JSON schema validator tool expects references to files within JSON schema
to be of JSON format. This is why all YAML files under
`pillars.schema.json.yaml` directory are first converted into JSON files
under `pillars.schema.json` directory` so that validator can load
referenced files as JSON.

Note that YAML syntax is a superset for JSON, in other words, any valid
JSON document is also valid YAML document (_not_ vice versa).

In order to test this schema on Fedora 21, run these commands:

*   Install Python module for JSON schema validation:

    ```
    sudo yum install -y python-jsonschema PyYAML
    ```

*   Get pillars content in a file:

    ```
    sudo salt-call --out=yaml pillar.items > pillars.yaml
    ```

*   Run this command to validate pillars:

    ```
    python check_pillars.py pillars.yaml
    ```

