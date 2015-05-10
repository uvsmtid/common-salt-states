

## Check approved minions ##

```
salt-key
```
These minions may not exists, but they will be contacted every time `*` used as target.

## Basic connection check ##

```
salt '*' test.ping
```

## Make sure Salt master is configured ##

Review steps for required configuration of `/etc/salt/master` on [this page](getting_started.md).

## Make sure initial system setup is done ##

Review steps for required system configuration on [this page](getting_started.md).

There are various requirements to make Salt:
* IP addresses and routing
* DNS server
* proxy configuration for YUM
* initial source code links

## Run `highstate` or any state in test mode ##

```
salt '*' state.highstate test=True
```
This can also be applied to any state run through `state.sls` function.
```
salt '*' state.sls common.dummy test=True
```

## Review output of executed jobs ##

Find jid (job id) in question:
```
salt-run jobs.list_jobs
```

Get job output:
```
salt-run jobs.lookup_jid [jid]
```
If such job exists and completed, Salt will show its output in YAML.

Use IO redirection to save output to the file for later review:
```
salt-run jobs.lookup_jid [jid] > results.yaml
```

The key information is whether any state failed (and if yes,
what is the stderr, stdout, error code, etc.).
The filed status of the states can be found by searching for `False`
in `Result:` fields of the output, for example:
```
...
          ID: deleteme_state
    Function: file.exists
        Name: /deleteme.txt
      Result: False
     Comment: Specified path /deleteme.txt does not exist
     Started: 16:54:38.851035
    Duration: 0.443 ms
     Changes:
...
```

## Three data components of Salt framework ##

### States ###

#### Check how Salt minion sees its top file ####

```
salt '*' state.show_top
```

#### Check how Salt minion sees specific state ####

```
salt '*' state.show_sls [state]
```

For example:
```
salt '*' state.show_sls common.source_symlinks
```

### Pillars ###

```
salt '*' pillar.items
```

Some rendering problems with pillars are not obvious - they may not be seen,
but pillars won't have all data.

In order to make sure there is no issues, collect output of the command
and make sure there is no `_errors` key in the output.
```
salt '*' pillar.items | tee pillar.items.output
```

For example, this is the top of `pillar.items.output` in case of error:
```
minion_sls:
    ----------
    _errors:
        - Include Declaration in SLS 'project.main' is not formed as a list
    include:
        None
    master:
...
```

### Grains ###

```
salt '*' grains.items
```

## Try executing job from Minion ##

TODO:
* `salt-call`

## How to render any template and see the output? ##

TODO

## State execution failures due to template issues ##


The following output is an example of problem when template cannot be instantiated:
```
local:
    Data failed to compile:
----------
    Traceback (most recent call last):
  File "/usr/lib/python2.7/site-packages/salt/state.py", line 2459, in call_highstate
    top = self.get_top()
  File "/usr/lib/python2.7/site-packages/salt/state.py", line 2027, in get_top
    tops = self.get_tops()
  File "/usr/lib/python2.7/site-packages/salt/state.py", line 1907, in get_tops
    saltenv=saltenv
  File "/usr/lib/python2.7/site-packages/salt/template.py", line 74, in compile_template
    ret = render(input_data, saltenv, sls, **render_kwargs)
  File "/usr/lib/python2.7/site-packages/salt/renderers/jinja.py", line 39, in render
    **kws)
  File "/usr/lib/python2.7/site-packages/salt/utils/templates.py", line 83, in render_tmpl
    output = render_str(tmplstr, context, tmplpath)
  File "/usr/lib/python2.7/site-packages/salt/utils/templates.py", line 279, in render_jinja_tmpl
    tmplstr)
SaltRenderError: Jinja variable 'dict object' has no attribute 'hostname_resolution_type'; line 15

---
[...]

base:

    '*':

        {% if pillar['hostname_resolution_type'] == 'static_hosts_file' %}    <======================

        # Generate hosts files on minions.
        - {{ project }}.hosts

        {% endif %}
[...]
---
```

Review corresponding data (see pillars or grains) and try to figure out why referencing it fails.

## Minion refuses to work due to old master key ##

Minion will refuse to start with new master (this may happen when VM with a minion is reused with another master) if it was already connected to a master before.
The minion log (Windows: `C:\salt\var\log\salt\minion`, Linux: `/var/log/salt/minion`) in this case looks similar to this:
```
[DEBUG   ] Loaded minion key: c:\salt\conf\pki\minion\minion.pem
[ERROR   ] The master key has changed, the salt master could have been subverted, verify salt master's public key
[CRITICAL] The Salt Master server's public key did not authenticate!
The master may need to be updated if it is a version of Salt lower than 2014.1.0-5-g32d3463, or
If you are confident that you are connecting to a valid Salt Master, then remove the master public key and restart the Salt Minion.
The master public key can be found at:
c:\salt\conf\pki\minion\minion_master.pub
```

Simply remove the cached master key and restart minion again:
```
c:\>del c:\salt\conf\pki\minion\minion_master.pub
```





