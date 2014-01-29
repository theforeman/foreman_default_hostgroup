require 'test_plugin_helper'

class DefaultHostgroupTest < ActiveSupport::TestCase
  setup do
    disable_orchestration
    User.current = User.find_by_login "admin"
  end

  def parse_json_fixture(relative_path)
    return JSON.parse(File.read(File.expand_path(File.dirname(__FILE__) + relative_path)))
  end

  def setup_hostgroup_match
    FactoryGirl.create(:setting,
                       :name => 'force_hostgroup_match',
                       :category => 'Setting::DefaultHostgroup')
    FactoryGirl.create(:setting,
                       :name => 'force_hostgroup_match_only_new',
                       :category => 'Setting::DefaultHostgroup')
    Setting[:force_hostgroup_match] = false
    Setting[:force_hostgroup_match_only_new] = true
  end

  test "full matching regex not enclosed in /" do
    setup_hostgroup_match
    SETTINGS[:default_hostgroup][:map] = { "Test Full" => '^sinn1636.lan$' }

    hostgroup = Hostgroup.create(:name => "Test Full")
    raw = parse_json_fixture('/facts.json')

    assert Host.importHostAndFacts(raw['name'], raw['facts'])
    assert_equal hostgroup, Host.find_by_name('sinn1636.lan').hostgroup
  end

  test "partial matching regex enclosed in /" do
    setup_hostgroup_match
    SETTINGS[:default_hostgroup][:map] = { "Test Partial" => '/\.lan$/' }

    hostgroup = Hostgroup.create(:name => "Test Partial")
    raw = parse_json_fixture('/facts.json')

    assert Host.importHostAndFacts(raw['name'], raw['facts'])
    assert_equal hostgroup, Host.find_by_name('sinn1636.lan').hostgroup
  end

  test "invalid hostgroup does nothing" do
    setup_hostgroup_match
    SETTINGS[:default_hostgroup][:map] = { "Nonexistent Group" => '.*', "Existent Group" => '/\.lan$/' }

    hostgroup = Hostgroup.create(:name => "Existent Group")
    raw = parse_json_fixture('/facts.json')

    assert Host.importHostAndFacts(raw['name'], raw['facts'])
    assert_equal hostgroup, Host.find_by_name('sinn1636.lan').hostgroup
  end

  test "default hostgroup" do
    setup_hostgroup_match
    SETTINGS[:default_hostgroup][:map] = { "Test Default" => '.*' }

    hostgroup = Hostgroup.create(:name => "Test Default")
    raw = parse_json_fixture('/facts.json')

    assert Host.importHostAndFacts(raw['name'], raw['facts'])
    assert_equal hostgroup, Host.find_by_name('sinn1636.lan').hostgroup
  end

  test "host already has a hostgroup" do
    setup_hostgroup_match
    SETTINGS[:default_hostgroup][:map] = { "Test Default" => '^(.*)$' }

    hostgroup = Hostgroup.create(:name => "Test Group")
    Hostgroup.create(:name => "Test Default")
    raw = parse_json_fixture('/facts.json')

    host, result = Host.importHostAndFacts_without_match_hostgroup(raw['name'], raw['facts'])
    host.hostgroup = hostgroup
    host.save(:validate => false)

    assert Host.importHostAndFacts(raw['name'], raw['facts'])
    assert_equal hostgroup, Host.find_by_name('sinn1636.lan').hostgroup
  end

  test "force hostgroup match on host with existing hostgroup" do
    setup_hostgroup_match
    Setting[:force_hostgroup_match] = true
    Setting[:force_hostgroup_match_only_new] = false
    SETTINGS[:default_hostgroup][:map] = { "Test Default" => '.*' }

    hostgroup = Hostgroup.create(:name => "Test Group")
    default = Hostgroup.create(:name => "Test Default")
    raw = parse_json_fixture('/facts.json')

    host, result = Host.importHostAndFacts_without_match_hostgroup(raw['name'], raw['facts'])
    host.hostgroup = hostgroup
    host.save(:validate => false)

    assert Host.importHostAndFacts(raw['name'], raw['facts'])
    assert_equal default, Host.find_by_name('sinn1636.lan').hostgroup
  end

  test "return if host is not new" do
    setup_hostgroup_match
    Setting[:force_hostgroup_match] = true
    SETTINGS[:default_hostgroup][:map] = { "Test Default" => '.*' }

    hostgroup = Hostgroup.create(:name => "Test Group")
    Hostgroup.create(:name => "Test Default")
    raw = parse_json_fixture('/facts.json')

    host, result = Host.importHostAndFacts_without_match_hostgroup(raw['name'], raw['facts'])
    host.hostgroup = hostgroup
    host.save(:validate => false)

    assert Host.importHostAndFacts(raw['name'], raw['facts'])
    assert_equal hostgroup, Host.find_by_name('sinn1636.lan').hostgroup
  end

  # Contrived example to check new plugin factories are loaded
  test "my factory exists" do
    refute Environment.find_by_name('defaulthostgrouptest')
    FactoryGirl.create(:environment)
    assert Environment.find_by_name('defaulthostgrouptest')
  end

end
