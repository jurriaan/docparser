# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop'
require 'yard'
YARD::Rake::YardocTask.new

Rake::TestTask.new do |t|
  t.libs << 'lib/docparser'
  t.test_files = FileList['test/lib/**/*_test.rb']
  t.verbose = true
end

task test: :rubocop

task :rubocop do
  puts "Running Rubocop #{RuboCop::Version::STRING}"
  args = FileList['**/*.rb', 'Rakefile', 'docparser.gemspec', 'Gemfile']
  cli = RuboCop::CLI.new
  raise unless cli.run(args).zero?
end

task default: :test
