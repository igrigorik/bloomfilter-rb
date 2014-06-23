require 'bundler/gem_tasks'
require 'rake'
require 'rspec'
require 'rspec/core/rake_task'
require 'rake/extensiontask'

Bundler::GemHelper.install_tasks
RSpec::Core::RakeTask.new(:spec)
Rake::Task[:spec].prerequisites << :clean

unless defined?(RUBY_ENGINE) && RUBY_ENGINE == "jruby"
  Rake::ExtensionTask.new('cbloomfilter')
  Rake::Task[:spec].prerequisites << :compile
end
