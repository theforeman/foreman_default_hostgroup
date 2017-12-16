require 'default_hostgroup_base_host_patch'

module ForemanDefaultHostgroup
  # Inherit from the Rails module of the parent app (Foreman), not
  # the plugin. Thus, inherits from ::Rails::Engine and not from
  # Rails::Engine
  class Engine < ::Rails::Engine
    engine_name 'foreman_default_hostgroup'

    initializer 'foreman_default_hostgroup.load_default_settings',
                before: :load_config_initializers do
      require_dependency File.expand_path(
        '../../../app/models/setting/default_hostgroup.rb', __FILE__)
    end

    initializer 'foreman_default_hostgroup.register_plugin',
                before: :finisher_hook do
      Foreman::Plugin.register :foreman_default_hostgroup do
        requires_foreman '>= 1.12'
      end
    end

    config.to_prepare do
      begin
        ::Host::Base.send(:include, DefaultHostgroupBaseHostPatch)
      rescue => e
        Rails.logger.warn "ForemanDefaultHostgroup: skipping engine hook (#{e})"
      end
    end

    rake_tasks do
      load 'default_hostgroup.rake'
    end
  end
end
