require 'default_hostgroup_base_host_patch'

module ForemanDefaultHostgroup
  #Inherit from the Rails module of the parent app (Foreman), not the plugin.
  #Thus, inherits from ::Rails::Engine and not from Rails::Engine
  class Engine < ::Rails::Engine

    # Load this before the Foreman config initizializers, so that the Setting.descendants
    # list includes the plugin STI setting class
    initializer 'foreman_discovery.load_default_settings', :before => :load_config_initializers do |app|
      require_dependency File.expand_path("../../../app/models/setting/default_hostgroup.rb", __FILE__) if (Setting.table_exists? rescue(false))
    end

    initializer 'foreman_default_hostgroup.register_plugin', :after=> :finisher_hook do |app|
      Foreman::Plugin.register :foreman_default_hostgroup do
      end if (Rails.env == "development" or defined? Foreman::Plugin)
    end

    config.to_prepare do
      ::Host::Base.send :include, DefaultHostgroupBaseHostPatch
    end

    rake_tasks do
      load "default_hostgroup.rake"
    end

  end
end
