Dir[File.join(Dir.pwd, 'tasks', '**', '*.rb')].each { |f| require f }
Dir[File.join(Dir.pwd, 'tasks', '*.rake')].each { |f| load f }

require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'git-version-bump/rake-tasks'

RSpec::Core::RakeTask.new(:spec)

Distribution.configure do |config|
  config.package_name = 'brief'
  config.version = Brief::VERSION
  config.rb_version = '20150210-2.1.5'
  config.packaging_dir = File.expand_path 'packaging'
  config.native_extensions = [
    'github-markdown-0.6.8',
    'escape_utils-1.0.1',
    #'charlock_holmes-0.7.3',
    #'posix-spawn-0.3.9',
    #'nokogumbo-1.3.0',
    #'rugged-0.21.4',
    'nokogiri-1.6.5',
    'eventmachine-1.0.6',
    'thin-1.6.3',
    'unf_ext-0.0.6'
  ]
end

task :default => :spec
