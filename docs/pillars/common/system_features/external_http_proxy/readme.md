
Key `external_http_proxy` configures HTTP/HTTPS proxy settings.

This configuration can be used for:
YUM,
Cygwin installer,
Vagrant,
Internet browsers,
etc.

There are basically three configuration parameters:
* URL itself
  URL is composed from three parts:
  * `proxy_url_schema` - example: `http://`
  * `proxy_url_hostname` - example: `example.com`
  * `proxy_url_port` - example: `8000`
  In order to form full URL, the following lines are concatenated as:
  ```
  {{ proxy_url_schema }}{{ proxy_url_hostname }}:{{ proxy_url_port }}/
  ```
  If authentication info is required to be embedded inside URL itself,
  the following concatenation is uses:
  ```
  {{ proxy_url_schema }}{{ username }}:{{ password_value }}@{{ proxy_url_hostname }}:{{ proxy_url_port }}/
  ```
* Authentication info:
  * `proxy_username`
  * `proxy_password_secret_id`

* Automatic configuration script (which may be used for Internet browsers);
  * `auto_config_url`

    For example,
    ```
    http://example.com/autoconf/proxy.pac
    ```

