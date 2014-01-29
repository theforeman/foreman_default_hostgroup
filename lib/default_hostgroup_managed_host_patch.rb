module DefaultHostgroupManagedHostPatch
  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      class << self
        alias_method_chain :importHostAndFacts, :match_hostgroup
      end
    end
  end

  module ClassMethods
    def importHostAndFacts_with_match_hostgroup hostname, facts, certname = nil, proxy_id = nil
      raise Foreman::Exception.new "Could not load default_hostgroup settings, check config" unless SETTINGS[:default_hostgroup]
      raise Foreman::Exception.new "Could not load default_hostgroup map from settings, check config." unless SETTINGS[:default_hostgroup][:map]

      Rails.logger.debug "DefaultHostgroupMatch: performing Hostgroup match"
      host, result = importHostAndFacts_without_match_hostgroup(hostname, facts, certname, proxy_id)

      if Setting[:force_hostgroup_match_only_new]
        return host, result unless host.present? && !host.new_record? && host.hostgroup.nil? && host.reports.empty?
      end

      unless Setting[:force_hostgroup_match]
        return host, result if host.hostgroup
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
          new_hostgroup = Hostgroup.find_by_label(hostgroup)
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
      Hostgroup.find_by_label(hostgroup) ? true : false
    end
  end
end
