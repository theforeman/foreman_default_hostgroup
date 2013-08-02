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
    def importHostAndFacts_with_apply_hostgroup yaml
      importHostAndFacts_without_apply_hostgroup yaml
      Rails.logger.debug "DefaultHostgroup: performing Hostgroup check"
      # The aliased method just returns true/false so we have to reparse the yaml
      # to find the host
      unless Setting[:default_hostgroup] == ''
        facts = YAML::load yaml
        case facts
          when Puppet::Node::Facts
            certname = facts.name
            name     = facts.values["fqdn"].downcase
          when Hash
            certname = facts["clientcert"] || facts["certname"] 
            name     = facts["fqdn"].downcase
        end
        h=nil
        if name == certname or certname.nil?
          h = Host.find_by_name name
        else
          h = Host.find_by_certname certname
          h ||= Host.find_by_name name
        end
        # Now we can update it
        if h.hostgroup.nil?
          h.hostgroup = Hostgroup.find_by_name(Setting[:default_hostgroup])
          h.save
          Rails.logger.debug "DefaultHostgroup: added #{h.name} to #{h.hostgroup.name}"
        end
      end
    end
  end
end
