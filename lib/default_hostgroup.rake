namespace :test do
  desc "Test DefaultHostgroup plugin"
  Rake::TestTask.new(:default_hostgroup) do |t|
    test_dir = File.join(File.dirname(__FILE__), '..', 'test')
    t.libs << "test"
    t.pattern = "#{test_dir}/**/*_test.rb"
    t.verbose = true
  end

end

Rake::Task[:test].enhance do
  Rake::Task['test:default_hostgroup'].invoke
end

