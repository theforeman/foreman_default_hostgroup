module DefaultHostgroupBaseHostPatch
  extend ActiveSupport::Concern

  included do
    alias_method_chain :import_facts, :match_hostgroup
  end

  def import_facts_with_match_hostgroup facts

    #Load the facts anyway, hook onto the end of it
    result = import_facts_without_match_hostgroup(facts)

    unless SETTINGS[:default_hostgroup] && SETTINGS[:default_hostgroup][:facts_map]
      Rails.logger.warn "DefaultHostgroupMatch: Could not load default_hostgroup map from settings, check config."
      return result
    end

    Rails.logger.debug "DefaultHostgroupMatch: performing Hostgroup match"

    if Setting[:force_hostgroup_match_only_new]
      # hosts have already been saved during import_host, so test the creation age instead
      new_host = ((self.created_at - Time.now) < 300)
      unless !new_host && self.hostgroup.nil? && self.reports.empty?

        Rails.logger.debug "DefaultHostgroupMatch: skipping, host exists"
        return result
      end
    end

    unless Setting[:force_hostgroup_match]
      if self.hostgroup.present?
        Rails.logger.debug "DefaultHostgroupMatch: skipping, host has hostgroup"
        return result
      end
    end

    facts_map = SETTINGS[:default_hostgroup][:facts_map]
    new_hostgroup = find_match(facts_map)

    return result unless new_hostgroup

    self.hostgroup = new_hostgroup
    self.save(:validate => false)
    Rails.logger.info "DefaultHostgroupMatch: #{hostname} added to #{new_hostgroup}"

    return result
  end

  def group_matches?(fact)
    fact.each do |fact_name, fact_regex|
      fact_regex.gsub!(/(\A\/|\/\z)/, '')
      host_fact_value = self.facts_hash[fact_name]
      Rails.logger.info "Fact = #{fact_name}"
      Rails.logger.info "Regex = #{fact_regex}"
      return true if Regexp.new(fact_regex).match(host_fact_value)
    end
    return false
  end

  def find_match(facts_map)
    facts_map.each do |group_name, facts|
      return Hostgroup.find_by_title(group_name) if group_matches?(facts) and valid_hostgroup?(group_name)
    end
    Rails.logger.info "No match ..."
    return false
  end

  def valid_hostgroup?(hostgroup)
    Hostgroup.find_by_title(hostgroup) ? true : false
  end
end
