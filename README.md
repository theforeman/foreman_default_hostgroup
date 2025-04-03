# Foreman Default Hostgroup Plugin

A quick plugin to set a default hostgroup on hosts which check-in via Puppet without
a Hostgroup set.

## Installation

See Foreman's [plugin installation documentation](https://theforeman.org/plugins/#2.Installation).

## Compatibility

| Foreman Version | Plugin Version |
| --------------- | -------------: |
| <= 1.2          |          0.1.0 |
| 1.3             |          1.0.1 |
| 1.4             |          1.1.0 |
| 1.5             |          2.0.1 |
| 1.6 - 1.11      |          3.0.0 |
| >= 1.12         |          4.0.0 |
| >= 1.16         |          4.0.1 |
| >= 1.16         |          5.0.0 |
| >= 2.2.0        |          6.0.0 |
| >= 3.0          |          7.0.0 |

## Usage

The configuration is done inside foreman's plugin settings directory which is
`/etc/foreman/plugins/`.

You can simply copy `default_hostgroup.yaml.example` and adjust it to fit
your needs. The format is shown in the example. The simplest form would be:

```
---
:default_hostgroup:
  :facts_map:
    "Default":
      "hostname": ".*"
```

`Default` is the host group name (more precisely title) that will be assigned if all its the rules matches.
Under the host group name, there's a list of rules. If all of them (in this example just one) is matching,
the host is assigned to the `Default` host group. The `hostname` is the name of the fact while the value `.*`
is used as a regular expression. This rule means host with any `hostname` is added to the `Default` host group.

If you are ugrading from plugin version 2.0.1 or older the format of this
file changes and you will need modify `default_hostgroup.yaml.example` to
follow the format above.

*Important Note:* You have to restart foreman in order to apply changes in
`default_hostgroup.yaml`!

There are also two more settings under `Settings -> DefaultHostgroup`

| Setting                          | Description                                                                                                                                                                                                          |
| -------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `force_hostgroup_match`          | Setting this to `true` will perform matching even on hosts that already have a hostgroup set. Enabling this needs `force_hostgroup_match_only_new` to be `false`.  Default: `false`                                  |
| `force_hostgroup_match_only_new` | Setting this to `true` will only perform matching when a host uploads its facts for the first time, i.e. after provisioning or when adding an existing puppetmaster and thus its nodes into foreman. Default: `true` |
| `force_host_environment` | Apply hostgroup's environment to host even if a host already has a different one.  Default: `true`) |
| `replace_facts_in_hostgroup_name` | Allow replacement of facts in the hostgroup name. Facts can be accessed via **%{fact_name}**. Due to the facts being generated on the client, their content may be altered which can cause a security issue! Default: `false` |

## TODO

* Deface the Hostgroup UI to add the regular expressions directly into the Hostgroup

## Contributing

Fork and send me a Pull Request. Thanks!

## Copyright

Copyright (c) 2013 Greg Sutcliffe

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

