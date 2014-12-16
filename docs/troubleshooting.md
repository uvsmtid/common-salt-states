

## Check connected minions

```
salt-key
```

## Basic connection check

```
salt '*' test.ping
```

## Make sure Salt master is configured

Review steps for required configuration of `/etc/salt/master` on [this page](inital_salt_master_setup.md).

## Make sure initial system setup is done

Review steps for required system configuration on [this page](getting_started.md).

There are various requirements to make Salt:
* IP addresses and routing
* DNS server
* proxy configuration for YUM
* initial source code links

## Run `highstate` in test mode

```
salt -v '*' state.highstate test=True
```

## Review output of executed jobs

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

## Three data components of Salt framework

## States


### Check how Salt minion sees its top file


### Check how Salt minion sees specific state

```
```

## Running states in test mode

## Pillars

## Grains





