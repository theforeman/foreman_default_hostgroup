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
| >= 1.3          | 1.0.1          |

## Usage

The configuration is done inside foreman's plugin settings directory which is
```~foreman/config/settings.plugins.d/```.

You can simply copy ```default_hostgroup.yaml.example``` and adjust it to fit
your needs. You should change the example settings as they might break your
setup (very unlikely though).

*Important Note:* You have to restart foreman in order to apply changes in
```default_hostgroup.yaml```!

There are also two more settings under ```Settings -> DefaultHostgroup```

| Setting | Description |
| ------- | ----------- |
| ```force_hostgroup_match``` | Setting this to ```true``` will perform matching even on hosts that already have a hostgroup set. Enabling this needs ```force_hostgroup_match_only_new``` to be ```false```.  Default: ```false``` |
| ```force_hostgroup_match_only_new``` | Setting this to ```true``` will only perform matching when a host uploads its facts for the first time, i.e. after provisioning or when adding an existing puppetmaster and thus its nodes into foreman. Default: ```true``` |

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

