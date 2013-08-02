class Setting::DefaultHostgroup < ::Setting
  BLANK_ATTRS << 'default_hostgroup'

  def self.load_defaults
    # Check the table exists
    return unless super

      Setting.transaction do
        [
          self.set('default_hostgroup', 'The default Hostgroup to place new Hosts in', ''),
        ].compact.each { |s| self.create s.update(:category => 'Setting::DefaultHostgroup')}
      end

    true

  end

end
