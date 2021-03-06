#
# Prepend DevKit into compilation phase
#
task compile: :devkit if RUBY_PLATFORM =~ /mingw/

require 'rake/extensiontask'

spec = Gem::Specification.load('byebug.gemspec')
Rake::ExtensionTask.new('byebug', spec) do |ext|
  ext.lib_dir = 'lib/byebug'
end

require 'rake/testtask'

module Rake
  #
  # Overrides default rake tests loader
  #
  class TestTask
    def rake_loader
      'test/test_helper.rb'
    end
  end
end

desc 'Run the test suite'
task :test do
  Rake::TestTask.new do |t|
    t.verbose = true
    t.warning = true
    t.pattern = 'test/**/*_test.rb'
  end
end

desc 'Activates DevKit'
task :devkit do
  begin
    require 'devkit'
  rescue LoadError
    abort "Failed to activate RubyInstaller's DevKit required for compilation."
  end
end

require 'rubocop/rake_task'

desc 'Run RuboCop'
task :rubocop do
  RuboCop::RakeTask.new
end

require_relative 'tasks/ccop.rb'
require_relative 'tasks/dev_utils.rb'

task default: [:compile, :test, :rubocop, :ccop]
