module DefaultHostgroupManagedHostPatch
  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      class << self
        alias_method_chain :import_host_and_facts, :match_hostgroup
      end
    end
  end

  module ClassMethods
    def import_host_and_facts_with_match_hostgroup hostname, facts, certname = nil, proxy_id = nil
      @host, result = import_host_and_facts_without_match_hostgroup(hostname, facts, certname, proxy_id)

      unless SETTINGS[:default_hostgroup] && SETTINGS[:default_hostgroup][:facts_map]
        Rails.logger.warn "DefaultHostgroupMatch: Could not load default_hostgroup map from settings, check config."
        return @host, result
      end

      Rails.logger.debug "DefaultHostgroupMatch: performing Hostgroup match"

      if Setting[:force_hostgroup_match_only_new]
        # host.new_record? will only test for the early return in the core method, a real host
        # will have already been saved at least once.
        unless @host.present? && !@host.new_record? && @host.hostgroup.nil? && @host.reports.empty?

          Rails.logger.debug "DefaultHostgroupMatch: skipping, host exists"
          return @host, result
        end
      end

      unless Setting[:force_hostgroup_match]
        if @host.hostgroup.present?
          Rails.logger.debug "DefaultHostgroupMatch: skipping, host has hostgroup"
          return @host, result
        end
      end

      facts_map = SETTINGS[:default_hostgroup][:facts_map]
      new_hostgroup = find_match(facts_map)

      return @host, result unless new_hostgroup

      @host.hostgroup = new_hostgroup
      @host.save(:validate => false)
      Rails.logger.info "DefaultHostgroupMatch: #{hostname} added to #{new_hostgroup}"

      return @host, result
    end

    def group_matches?(fact)
      fact.each do |fact_name, fact_regex|
        fact_regex.gsub!(/(\A\/|\/\z)/, '')
        host_fact_value = @host.facts_hash[fact_name]
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
end
