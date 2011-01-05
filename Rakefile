require 'rake'
require 'rspec'
require 'rspec/core/rake_task'
require 'rake/extensiontask'
require 'bundler'

Bundler::GemHelper.install_tasks
RSpec::Core::RakeTask.new(:spec)
Rake::ExtensionTask.new('cbloomfilter')