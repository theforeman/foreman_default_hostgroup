require 'test_helper'

class DefaultHostgroupTest < ActiveSupport::TestCase
  setup do
    disable_orchestration
    User.current = User.find_by_login "admin"

    # this is not being run automatically by the
    # initializers, for some strange reason....
    Setting::DefaultHostgroup.load_defaults
  end

  def parse_json_fixture(relative_path)
    return JSON.parse(File.read(File.expand_path(File.dirname(__FILE__) + relative_path)))
  end

  def setup_hostgroup
    @hostgroup = Hostgroup.create :name => "MyGroup"
    Setting[:default_hostgroup] = @hostgroup.name
  end

  test "a new, fact-imported, host has a default hostgroup set" do
    setup_hostgroup
    raw = parse_json_fixture('/facts.json')
    assert Host.importHostAndFacts(raw['name'], raw['facts'])
    assert_equal @hostgroup, Host.find_by_name('sinn1636.lan').hostgroup
  end

  test "an invalid hostgroup setting does nothing" do
    setup_hostgroup
    Setting[:default_hostgroup] = "doesnotexist"
    raw = parse_json_fixture('/facts.json')
    assert     Host.importHostAndFacts(raw['name'], raw['facts'])
    refute Host.find_by_name('sinn1636.lan').hostgroup
  end

end
