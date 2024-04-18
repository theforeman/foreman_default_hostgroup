require 'default_hostgroup_base_host_patch'

module ForemanDefaultHostgroup
  class Engine < ::Rails::Engine
    engine_name 'foreman_default_hostgroup'

    config.autoload_paths += Dir["#{config.root}/app/models"]

    # Add any db migrations
    initializer 'foreman_default_hostgroup.load_app_instance_data' do |app|
      ForemanDefaultHostgroup::Engine.paths['db/migrate'].existent.each do |path|
        app.config.paths['db/migrate'] << path
      end
    end

    initializer 'foreman_default_hostgroup.register_plugin',
                before: :finisher_hook do
      Foreman::Plugin.register :foreman_default_hostgroup do
        requires_foreman '>= 3.0'

        settings do
          category(:default_hostgroup, N_('Default Hostgroup')) do
            setting('force_hostgroup_match',
                    type: :boolean,
                    description: 'Apply hostgroup matching even if a host already has one.',
                    default: false)
            setting('force_hostgroup_match_only_new',
                    type: :boolean,
                    description: 'Apply hostgroup matching only on new hosts',
                    default: true)
            setting('force_host_environment',
                    type: :boolean,
                    description: "Apply hostgroup's environment to host even if a host already has a different one",
                    default: true)
          end
        end
      end
    end

    config.to_prepare do
      ::HostFactImporter.include DefaultHostgroupBaseHostPatch
      ::HostFactImporter.prepend DefaultHostgroupBaseHostPatch::ManagedOverrides
    end
  end
end
