class Setting::DefaultHostgroup < ::Setting
  BLANK_ATTRS << 'default_hostgroup'

  def self.load_defaults
    # Check the table exists
    return unless super

    Setting.transaction do
      [
        self.set('force_hostgroup_match', 'Apply hostgroup matching even if a host already has one.', false),
        self.set('force_hostgroup_match_only_new', 'Apply hostgroup matching only on new hosts', true)
      ].compact.each { |s| self.create s.update(category: 'Setting::DefaultHostgroup') }
    end

    true
  end
end
