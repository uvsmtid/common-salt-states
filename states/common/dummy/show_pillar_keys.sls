# Handy dummy state which lists some pillar keys.

{% for mode in [ 'bootstrap_mode', 'offline_mode' ] %}
dummy_state_{{ mode }}:
    cmd.run:
        {% if mode in pillar %}
        - name: "echo {{ mode }} = {{ pillar[mode] }}"
        {% else %}
        - name: "echo {{ mode }} = [ missing in pillar ]"
        {% endif %}
{% endfor %}

