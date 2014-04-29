require 'test_plugin_helper'

class DefaultHostgroupTest < ActiveSupport::TestCase
  setup do
    disable_orchestration
    User.current = User.find_by_login "admin"
  end

  def parse_json_fixture(relative_path)
    return JSON.parse(File.read(File.expand_path(File.dirname(__FILE__) + relative_path)))
  end

  def setup_hostgroup
    # The settings.yml fixture in Core wipes out the Setting table,
    # so we use FactoryGirl to re-create it
    FactoryGirl.create(:setting,
                       :name => 'default_hostgroup',
                       :category => 'Setting::DefaultHostgroup')
    @hostgroup = Hostgroup.create :name => "MyGroup"
    Setting[:default_hostgroup] = @hostgroup.name
  end

  test "a new, fact-imported, host has a default hostgroup set" do
    setup_hostgroup
    raw = parse_json_fixture('/facts.json')
    assert Host.import_host_and_facts(raw['name'], raw['facts'])
    assert_equal @hostgroup, Host.find_by_name('sinn1636.lan').hostgroup
  end

  test "an invalid hostgroup setting does nothing" do
    setup_hostgroup
    Setting[:default_hostgroup] = "doesnotexist"
    raw = parse_json_fixture('/facts.json')
    assert Host.import_host_and_facts(raw['name'], raw['facts'])
    refute Host.find_by_name('sinn1636.lan').hostgroup
  end

  # Contrived example to check new plugin factories are loaded
  test "my factory exists" do
    refute Environment.find_by_name('defaulthostgrouptest')
    FactoryGirl.create(:environment)
    assert Environment.find_by_name('defaulthostgrouptest')
  end

end
