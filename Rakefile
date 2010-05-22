require 'rake'
require 'spec'
require 'spec/rake/spectask'
require 'rake/extensiontask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "bloomfilter"
    gemspec.summary = "Counting Bloom Filter implemented in Ruby"
    gemspec.description = gemspec.summary
    gemspec.email = "ilya@igvita.com"
    gemspec.homepage = "http://github.com/igrigorik/bloomfilter"
    gemspec.authors = ["Ilya Grigorik", "Tatsuya Mori"]
    gemspec.extensions = ["ext/cbloomfilter/extconf.rb"]
    gemspec.rubyforge_project = "bloomfilter"
    gemspec.files = FileList[`git ls-files`.split]
    gemspec.add_development_dependency 'rake'
    gemspec.add_development_dependency 'rspec'
    gemspec.add_development_dependency 'rake-compiler'
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

Spec::Rake::SpecTask.new do |t|
  t.spec_opts ||= []
  t.spec_opts << "-rubygems"
  t.spec_opts << "--options" << "spec/spec.opts"
  t.spec_files = FileList['spec/*_spec.rb']
end

Rake::ExtensionTask.new('cbloomfilter')