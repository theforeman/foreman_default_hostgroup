# Foreman Default Hostgroup Plugin

A quick plugin to set a default hostgroup on hosts which check-in via Puppet without
a Hostgroup set.

## Installation

See [How_to_Install_a_Plugin](http://projects.theforeman.org/projects/foreman/wiki/How_to_Install_a_Plugin)
for how to install Foreman plugins

## Compatibility

| Foreman Version | Plugin Version |
| --------------- | --------------:|
| <= 1.2          | 0.1.0          |
|    1.3          | 1.0.1          |
|    1.4          | 1.1.0          |
|    1.5          | 2.0.1          |
| >= 1.6          | 3.0.0          |

## Usage

The configuration is done inside foreman's plugin settings directory which is
`~foreman/config/settings.plugins.d/`.

You can simply copy `default_hostgroup.yaml.example` and adjust it to fit
your needs. The format is shown in the example. The simplest form would be:

```
---
:default_hostgroup:
  :facts_map:
    "Default":
      "hostname": ".*"
```

*Important Note:* You have to restart foreman in order to apply changes in
`default_hostgroup.yaml`!

There are also two more settings under the Foreman UI `Settings -> DefaultHostgroup`

| Setting | Description |
| ------- | ----------- |
| `force_hostgroup_match` | Setting this to `true` will perform matching even on hosts that already have a hostgroup set. Enabling this needs `force_hostgroup_match_only_new` to be `false`.  Default: `false` |
| `force_hostgroup_match_only_new` | Setting this to `true` will only perform matching when a host uploads its facts for the first time, i.e. after provisioning or when adding an existing puppetmaster and thus its nodes into foreman. Default: `true` |

### Multiple Regex matching
Sometimes you will have complex regex matching patterns that you may want to split out into multiple regex strings.
In order to do this you must put regex strings inside an array.  It doesn't matter if the string contains
the forward slashes or not for each regex inside the array.

Example

```ruby
  ---
  :default_hostgroup:
    :facts_map:
      "Go_agents":
        "hostname":
          - "go_agent1"
          - "go_agent2"
          - "go_agent[1][1-3]"
      "Default":
        "hostname": ".*"
```
## TODO

* Deface the Hostgroup UI to add the regular expressions directly into the Hostgroup

## Contributing

Fork and send me a Pull Request. Thanks!

### Testing
For running the tests, see http://projects.theforeman.org/projects/foreman/wiki/How_to_Create_a_Plugin#Testing
in short, add the plugin to a normal Foreman source install and run "rake test" or "rake test:default_hostgroup"

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

