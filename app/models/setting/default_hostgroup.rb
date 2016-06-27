class Setting::DefaultHostgroup < ::Setting
  BLANK_ATTRS << 'default_hostgroup'

  def self.load_defaults
    # Check the table exists
    return unless ActiveRecord::Base.connection.table_exists?('settings')
    return unless super

    Setting.transaction do
      [
        set('force_hostgroup_match', 'Apply hostgroup matching even if a host already has one.', false),
        set('force_hostgroup_match_only_new', 'Apply hostgroup matching only on new hosts', true),
        set('force_host_environment', "Apply hostgroup's environment to host even if a host already has a different one", true)
      ].compact.each { |s| create s.update(category: 'Setting::DefaultHostgroup') }
    end

    true
  end
end
