require 'test_plugin_helper'

# Tests for the plugin
class DefaultHostgroupTest < ActiveSupport::TestCase
  include FactImporterIsolation

  allow_transactions_for_any_importer

  setup do
    disable_orchestration
    set_admin
    setup_hostgroup_matchers
    setup_host_and_facts
  end

  def setup_hostgroup_matchers
    # The settings.yml fixture in Core wipes out the Setting table,
    # so we use FactoryBot to re-create it
    FactoryBot.create(:setting,
                      name: 'force_hostgroup_match')
    FactoryBot.create(:setting,
                      name: 'force_hostgroup_match_only_new')
    FactoryBot.create(:setting,
                      name: 'force_host_environment')
    # Set the defaults
    Setting[:force_hostgroup_match] = false
    Setting[:force_hostgroup_match_only_new] = true
    Setting[:force_host_environment] = true

    # Mimic plugin config fron config file
    FactoryBot.create(:hostgroup, name: 'Test Default')
    SETTINGS[:default_hostgroup] = {}
    SETTINGS[:default_hostgroup][:facts_map] = {
      'Test Default' => { 'hostname' => '.*' }
    }
  end

  def setup_host_and_facts
    raw = JSON.parse(File.read(File.join(__dir__, 'facts.json')))
    @name = raw['name']
    @host = Host.import_host(raw['name'], 'puppet')
    @facts = raw['facts']
  end

  context 'import_facts_with_match_hostgroup' do
    test 'matched host is saved with new hostgroup' do
      assert HostFactImporter.new(@host).import_facts(@facts)
      assert_equal Hostgroup.find_by(name: 'Test Default'), Host.find_by(name: @name).hostgroup
    end

    test 'matched host not updated if host already has a hostgroup' do
      hostgroup = FactoryBot.create(:hostgroup)
      @host.hostgroup = hostgroup
      @host.save(validate: false)

      assert HostFactImporter.new(@host).import_facts(@facts)
      assert_equal hostgroup, Host.find_by(name: @name).hostgroup
    end

    test 'hostgroup is not updated if host is not new' do
      @host.created_at = Time.current - 1000
      @host.save(validate: false)

      assert HostFactImporter.new(@host).import_facts(@facts)
      assert_not Host.find_by(name: @name).hostgroup
    end
  end

  context 'find_match' do
    # takes a config map, returns a group or false
    test 'match a single hostgroup' do
      facts_map = SETTINGS[:default_hostgroup][:facts_map]
      assert HostFactImporter.new(@host).import_facts(@facts, nil, true)
      assert_equal Hostgroup.find_by(name: 'Test Default'), @host.find_match(facts_map)
    end

    test 'returns false for no match' do
      facts_map = SETTINGS[:default_hostgroup][:facts_map] = {
        'Test Default' => { 'hostname' => 'nosuchhost' }
      }
      assert HostFactImporter.new(@host).import_facts(@facts, nil, true)
      assert_not @host.find_match(facts_map)
    end

    test 'matches first available hostgroup' do
      facts_map = SETTINGS[:default_hostgroup][:facts_map] = {
        'Test Default' => { 'hostname' => '.*' },
        'Some Other Group' => { 'hostname' => '/\.lan$/' }
      }
      assert HostFactImporter.new(@host).import_facts(@facts, nil, true)
      assert_equal Hostgroup.find_by(name: 'Test Default'), @host.find_match(facts_map)
    end

    test 'nonexistant groups are ignored' do
      facts_map = SETTINGS[:default_hostgroup][:facts_map] = {
        'Some Other Group' => { 'hostname' => '.*' },
        'Test Default' => { 'hostname' => '/\.lan$/' }
      }
      assert HostFactImporter.new(@host).import_facts(@facts, nil, true)
      assert_equal Hostgroup.find_by(name: 'Test Default'), @host.find_match(facts_map)
    end
  end

  context 'group_matches?' do
    # passing a hash of (group_name, regex) pairs
    test 'full regex matches' do
      regex = { 'hostname' => '^sinn1636.lan$' }
      assert HostFactImporter.new(@host).import_facts(@facts, nil, true)
      assert @host.group_matches?(regex)
    end

    test 'partial regex matches' do
      regex = { 'hostname' => '.lan$' }
      assert HostFactImporter.new(@host).import_facts(@facts, nil, true)
      assert @host.group_matches?(regex)
    end

    test 'regex slashes are stripped' do
      regex = { 'hostname' => '/\.lan$/' }
      assert HostFactImporter.new(@host).import_facts(@facts, nil, true)
      assert @host.group_matches?(regex)
    end

    test 'invalid keys are ignored' do
      regex = { 'nosuchfact' => '.*' }
      assert HostFactImporter.new(@host).import_facts(@facts, nil, true)
      assert_not @host.group_matches?(regex)
    end

    test 'unmatched values are ignored' do
      regex = { 'hostname' => 'nosuchname' }
      assert HostFactImporter.new(@host).import_facts(@facts, nil, true)
      assert_not @host.group_matches?(regex)
    end

    test 'multiple entries with invalid keys / values match' do
      regex = {
        'nosuchfact' => '.*',
        'osfamily' => 'nosuchos',
        'hostname' => '.lan$'
      }
      assert HostFactImporter.new(@host).import_facts(@facts, nil, true)
      assert @host.group_matches?(regex)
    end
  end

  context 'settings_exist?' do
    test 'true when Settings exist' do
      h = FactoryBot.create(:host)
      assert h.settings_exist?
    end

    test 'false when Settings are missing' do
      SETTINGS[:default_hostgroup] = {}
      h = FactoryBot.create(:host)
      assert_not h.settings_exist?
    end
  end

  context 'host_new_or_forced?' do
    test 'true when host is new' do
      h = FactoryBot.create(:host, created_at: Time.current)
      assert h.host_new_or_forced?
    end

    test 'false when host has existed for > 300s' do
      h = FactoryBot.create(:host, created_at: Time.current - 1000)
      assert_not h.host_new_or_forced?
    end

    test 'false when host has a hostgroup' do
      h = FactoryBot.create(:host, :with_hostgroup, created_at: Time.current)
      assert_not h.host_new_or_forced?
    end

    test 'false when host has reports' do
      h = FactoryBot.create(:host, :with_reports, created_at: Time.current)
      assert_not h.host_new_or_forced?
    end

    test 'true when setting is forced' do
      Setting[:force_hostgroup_match_only_new] = false
      h = FactoryBot.create(:host, :with_hostgroup, created_at: Time.current)
      assert h.host_new_or_forced?
    end
  end

  context 'host_has_no_hostgroup_or_forced?' do
    test 'true if host has no hostgroup' do
      h = FactoryBot.create(:host)
      assert h.host_has_no_hostgroup_or_forced?
    end

    test 'false if host has hostgroup' do
      h = FactoryBot.create(:host, :with_hostgroup)
      assert_not h.host_has_no_hostgroup_or_forced?
    end

    test 'true if host has hostgroup and setting forced' do
      Setting[:force_hostgroup_match] = true
      h = FactoryBot.create(:host, :with_hostgroup)
      assert h.host_has_no_hostgroup_or_forced?
    end
  end
end
