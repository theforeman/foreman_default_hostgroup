$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'foreman_default_hostgroup/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = 'foreman_default_hostgroup'
  s.version = ForemanDefaultHostgroup::VERSION
  s.authors = ['Greg Sutcliffe']
  s.email = 'gsutclif@redhat.com'
  s.description = 'Adds the option to specify a default hostgroup for new hosts created from facts/reports'
  s.extra_rdoc_files = [
    'LICENSE',
    'README.md'
  ]
  s.files = Dir['{app,extra,config,db,lib}/**/*'] + ['LICENSE', 'README.md', 'default_hostgroup.yaml.example']
  s.test_files = Dir['test/**/*']
  s.homepage = 'https://github.com/theforeman/foreman_default_hostgroup'
  s.license = 'GPL-3.0'
  s.summary = 'Default Hostgroup Plugin for Foreman'
end
