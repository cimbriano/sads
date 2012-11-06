# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "sads"
  gem.homepage = "http://github.com/cimbriano/sads"
  gem.license = "MIT"
  gem.summary = %Q{TODO: one-line summary of your gem}
  gem.description = %Q{TODO: longer description of your gem}
  gem.email = "Christopher.Imbriano@gmail.com"
  gem.authors = ["Chris Imbriano"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

Rake::TestTask.new(:spec) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'specs/**/spec_*.rb'
  test.verbose = true
end

# coverage task is not a Rake::Task b/c of issue described here:
# https://github.com/colszowka/simplecov/issues/37
task :cov do
  ENV['COVERAGE'] = "true"
  Rake::Task["test"].execute
  #`rake test COVERAGE=true`
  #`open coverage/index.html`
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "sads #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
