# Foreman Default Hostgroup Plugin

A quick plugin to set a default hostgroup on hosts which check-in via Puppet without
a Hostgroup set.

## Installation

See [How_to_Install_a_Plugin](http://projects.theforeman.org/projects/foreman/wiki/How_to_Install_a_Plugin)
for how to install Foreman plugins

## Usage

Go to `Settings -> DefaultHostgroup` and enter the name of the default
hostgroup. Leaving this blank disables the plugin. Nested Hostgroups should be
specified with the full label, e.g. `Base/Level1/Level2`

Once set, any upload to `/fact_values/create` for a Host with no Hostgroup set
will cause the Hostgroup to be set to the value in the Settings. THis happens
*before* the ENC data is downloaded, meaning it applies for a Host's very first
run.

The plugin only sets the Hostgroup for Hosts which have no Hostgroup, and no
reports (i.e new Hosts only).

## TODO

* Tests
* Rewrite this in a less hacky way

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

