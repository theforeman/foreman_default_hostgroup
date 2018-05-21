require 'rake/testtask'
# Tests
namespace :test do
  desc 'Test DefaultHostgroup plugin'
  Rake::TestTask.new(:foreman_default_hostgroup) do |t|
    test_dir = File.join(File.dirname(__FILE__), '../..', 'test')
    t.libs << ['test', test_dir]
    t.pattern = "#{test_dir}/**/*_test.rb"
    t.verbose = true
    t.warning = false
  end
end

namespace :foreman_default_hostgroup do
  task :rubocop do
    begin
      require 'rubocop/rake_task'
      RuboCop::RakeTask.new(:rubocop_foreman_default_hostgroup) do |task|
        task.patterns = ["#{ForemanDefaultHostgroup::Engine.root}/app/**/*.rb",
                         "#{ForemanDefaultHostgroup::Engine.root}/lib/**/*.rb",
                         "#{ForemanDefaultHostgroup::Engine.root}/test/**/*.rb"]
      end
    rescue StandardError
      puts 'Rubocop not loaded.'
    end

    Rake::Task['rubocop_foreman_default_hostgroup'].invoke
  end
end

Rake::Task[:test].enhance ['test:foreman_default_hostgroup']

load 'tasks/jenkins.rake'
if Rake::Task.task_defined?(:'jenkins:unit')
  Rake::Task['jenkins:unit'].enhance ['test:foreman_default_hostgroup', 'foreman_default_hostgroup:rubocop']
end
