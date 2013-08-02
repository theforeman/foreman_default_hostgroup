# Foreman Default Hostgroup Plugin

A quick plugin to set a default hostgroup on hosts which check-in via Puppet without
a Hostgroup set.

## Installation

Usual Rails Engine installation - add to your Gemfile:

    gem 'foreman_default_hostgroup', :git => 'https://github.com/GregSutcliffe/foreman_default_hostgroup'

then run `bundle update` and restart Foreman

## Usage

Go to `Settings -> DefaultHostgroup` and enter the name of the default hostgroup. Leaving
this blank disables the plugin.

Once set, any upload to `/fact_values/create` for a Host with no Hostgroup set will
cause the Hostgroup to be set to the value in the Settings. THis happens *before* the
ENC data is downloaded, meaning it applies for a Host's very first run.

## TODO

* Make this work for report uploads
* Test with nested hostgroups
* Tests

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

