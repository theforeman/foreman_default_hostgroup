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
    def importHostAndFacts_with_apply_hostgroup hostname, facts, certname = nil
      host, result = importHostAndFacts_without_apply_hostgroup(hostname, facts, certname)
      Rails.logger.debug "DefaultHostgroup: performing Hostgroup check"
      if host.hostgroup.nil? and host.reports.empty? # Definitely a new host...
        host.hostgroup = Hostgroup.find_by_label(Setting[:default_hostgroup])
        result = host.save
        Rails.logger.debug "DefaultHostgroup: added #{host.name} to #{host.hostgroup.label}"
      end
      return host, result
    end
  end
end
