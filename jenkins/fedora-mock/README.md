## fedora-mock Docker

This container provides Fedora 28 with `mock` and `copr-cli` installed.

It also provides `sshd` and a `jenkins` user to be used as a Jenkins builder.

### SSH

To be able to use the container as an SSH driven Jenkins builder an `authorized_keys` file
must be provided in the `ssh/` folder

### COPR

A `copr` file must be provided to be able to use `copr-cli`. Example:

```
[copr-cli]
login = <login>
username = <username>
token = <token>
copr_url = https://copr.fedorainfracloud.org
```

### Notes

`mock` is executed with `config_opts['use_nspawn'] = False` to be compatible with Docker.
This beahaviour is configured globally via `/etc/mock/site-defaults.cfg`
