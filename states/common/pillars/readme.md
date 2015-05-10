In order to test this schema on Fedora 21, run these commands:

*   Install Python module for JSON schema validation:
    ```
    sudo yum install -y python-jsonschema PyYAML
    ```

*   Get pillars content in a file:
    ```
    sudo salt-call --out=json pillar.items > pillar.items.output.json
    ```

*   Run this command to validate pillars:
    ```
    python check_pillars.py pillars-json-schema.yaml pillar.items.output.json
    ```

