# frozen_string_literal: true

class FixDefaultHostgroupSettingsCategoryToDsl < ActiveRecord::Migration[6.0]
  def up
    # rubocop:disable Rails/SkipsModelValidations
    Setting.where(category: 'Setting::DefaultHostgroup').update_all(category: 'Setting') if column_exists?(:settings, :category)
    # rubocop:enable Rails/SkipsModelValidations
  end
end
