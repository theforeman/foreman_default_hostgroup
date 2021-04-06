require "default_hostgroup_base_host_patch"

module ForemanDefaultHostgroup
  class Engine < ::Rails::Engine
    engine_name "foreman_default_hostgroup"

    config.autoload_paths += Dir["#{config.root}/app/models"]

    initializer "foreman_default_hostgroup.load_default_settings",
                before: :load_config_initializers do
      require_dependency File.expand_path(
        "../../app/models/setting/default_hostgroup.rb", __dir__
      )
    end

    initializer "foreman_default_hostgroup.register_plugin",
                before: :finisher_hook do
      Foreman::Plugin.register :foreman_default_hostgroup do
        requires_foreman ">= 2.2"
      end
    end

    config.to_prepare do
      begin
        ::HostFactImporter.include DefaultHostgroupBaseHostPatch
        ::HostFactImporter.prepend DefaultHostgroupBaseHostPatch::ManagedOverrides
      rescue StandardError => e
        Rails.logger.warn "ForemanDefaultHostgroup: skipping engine hook (#{e})"
      end
    end
  end
end
