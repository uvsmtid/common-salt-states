
# Note that, unfortunately,  similar settings in Vagrantfile
# do not work (with trailing slash or without):
#   config.proxy.http     = "http://username:password@example.com:8000"
#   config.proxy.https    = 'http://username:password@example.com:8000"
#
# NOTE: You will still have to use `--insecure` option to download box:
#         vagrant box add uvsmtid/centos-7.0-minimal --insecure

{% set proxy_config = pillar['system_features']['external_http_proxy'] %}
{% if proxy_config['feature_enabled'] %}

# Proxy settings
export http_proxy='{{ proxy_config['proxy_url_schema'] }}{{ proxy_config['proxy_username'] }}:{{ proxy_config['proxy_password'] }}@{{ proxy_config['proxy_url_hostname'] }}:{{ proxy_config['proxy_url_port'] }}/'
export https_proxy="${http_proxy}"

{% endif %}

