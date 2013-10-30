require 'yaml'
module DefaultHostgroupManagedHostPatch
  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      class << self
        alias_method_chain :importHostAndFacts, :apply_hostgroup
      end
    end
  end

  module ClassMethods
    def importHostAndFacts_with_apply_hostgroup hostname, facts, certname = nil, proxy_id = nil
      host, result = importHostAndFacts_without_apply_hostgroup(hostname, facts, certname, proxy_id)
      Rails.logger.debug "DefaultHostgroup: performing Hostgroup check"

      unless valid_hostgroup?
        Rails.logger.debug "DefaultHostgroup: Could not find Hostgroup '#{Setting[:default_hostgroup]}'"
        return host, result
      end

      # host.new_record? will only test for the early return in the core method, a real host
      # will have already been saved at least once.
      if host.present? && !host.new_record? && host.hostgroup.nil? && host.reports.empty?
        host.hostgroup = Hostgroup.find_by_label(Setting[:default_hostgroup])
        host.save(:validate => false)
        Rails.logger.debug "DefaultHostgroup: added #{host.name} to #{host.hostgroup.label}"
      end
      return host, result
    end

    def valid_hostgroup?
      Hostgroup.find_by_label(Setting[:default_hostgroup]) ? true : false
    end
  end
end
