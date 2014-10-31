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
      host, result = import_host_and_facts_without_match_hostgroup(hostname, facts, certname, proxy_id)

      unless SETTINGS[:default_hostgroup] && SETTINGS[:default_hostgroup][:map]
        Rails.logger.warn "DefaultHostgroupMatch: Could not load default_hostgroup map from settings, check config."
        return host, result
      end

      Rails.logger.debug "DefaultHostgroupMatch: performing Hostgroup match"

      if Setting[:force_hostgroup_match_only_new]
        # host.new_record? will only test for the early return in the core method, a real host
        # will have already been saved at least once.
        unless host.present? && !host.new_record? && host.hostgroup.nil? && host.reports.empty?

          Rails.logger.debug "DefaultHostgroupMatch: skipping, host exists"
          return host, result
        end
      end

      unless Setting[:force_hostgroup_match]
        if host.hostgroup.present?
          Rails.logger.debug "DefaultHostgroupMatch: skipping, host has hostgroup"
          return host, result
        end
      end

      map = SETTINGS[:default_hostgroup][:map]
      new_hostgroup = nil

      map.each do |hostgroup, regex|
        unless valid_hostgroup?(hostgroup)
          Rails.logger.error "DefaultHostgroupMatch: #{hostgroup} is not a valid hostgroup, skipping."
          next
        end
        regex.gsub!(/(\A\/|\/\z)/, '')
        if Regexp.new(regex).match(hostname)
          new_hostgroup = Hostgroup.find_by_title(hostgroup)
          break
        end
      end

      return host, result unless new_hostgroup

      host.hostgroup = new_hostgroup
      host.save(:validate => false)
      Rails.logger.info "DefaultHostgroupMatch: #{hostname} added to #{new_hostgroup}"

      return host, result
    end

    def valid_hostgroup?(hostgroup)
      Hostgroup.find_by_title(hostgroup) ? true : false
    end
  end
end
