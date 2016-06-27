module DefaultHostgroupBaseHostPatch
  extend ActiveSupport::Concern

  included do
    alias_method_chain :import_facts, :match_hostgroup
  end

  def import_facts_with_match_hostgroup(facts)
    # Load the facts anyway, hook onto the end of it
    result = import_facts_without_match_hostgroup(facts)

    return result unless settings_exist?

    Rails.logger.debug 'DefaultHostgroupMatch: performing Hostgroup match'

    return result unless host_new_or_forced?
    return result unless host_has_no_hostgroup_or_forced?

    facts_map = SETTINGS[:default_hostgroup][:facts_map]
    new_hostgroup = find_match(facts_map)

    return result unless new_hostgroup

    self.hostgroup = new_hostgroup
    if Setting[:force_host_environment] == true
      self.environment = new_hostgroup.environment
    end
    save(validate: false)
    Rails.logger.info "DefaultHostgroupMatch: #{hostname} added to #{new_hostgroup}"

    result
  end

  def find_match(facts_map)
    facts_map.each do |group_name, facts|
      hg = Hostgroup.find_by_title(group_name)
      return hg if hg.present? && group_matches?(facts)
    end
    Rails.logger.info 'No match ...'
    false
  end

  def group_matches?(facts)
    facts.each do |fact_name, fact_regex|
      fact_regex.gsub!(%r{(\A/|/\z)}, '')
      host_fact_value = facts_hash[fact_name]
      Rails.logger.info "Fact = #{fact_name}"
      Rails.logger.info "Regex = #{fact_regex}"
      return true if Regexp.new(fact_regex).match(host_fact_value)
    end
    false
  end

  def settings_exist?
    unless SETTINGS[:default_hostgroup] && SETTINGS[:default_hostgroup][:facts_map]
      Rails.logger.warn 'DefaultHostgroupMatch: Could not load :default_hostgroup map from Settings.'
      return false
    end
    true
  end

  def host_new_or_forced?
    if Setting[:force_hostgroup_match_only_new]
      # hosts have already been saved during import_host, so test the creation age instead
      new_host = ((Time.current - created_at) < 300)
      unless new_host && hostgroup.nil? && reports.empty?
        Rails.logger.debug 'DefaultHostgroupMatch: skipping, host exists'
        return false
      end
    end
    true
  end

  def host_has_no_hostgroup_or_forced?
    unless Setting[:force_hostgroup_match]
      if hostgroup.present?
        Rails.logger.debug 'DefaultHostgroupMatch: skipping, host has hostgroup'
        return false
      end
    end
    true
  end
end
