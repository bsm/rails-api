require 'bundler/setup'
require 'rake'
require 'rspec/core/rake_task'
require 'bundler/gem_tasks'

# Do not push gems!
ENV['gem_push'] = "false"

include Rake::DSL
RSpec::Core::RakeTask.new(:spec)

desc 'Default: run specs.'
task :default => :spec
