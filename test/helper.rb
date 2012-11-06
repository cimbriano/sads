require 'simplecov'
require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'minitest/unit'
require "minitest/reporters"
require 'minitest/autorun'
MiniTest::Reporters.use! MiniTest::Reporters::DefaultReporter.new

MiniTest::Reporters::SpecReporter.new

#require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'sads'

class MiniTest::Unit::TestCase
end

MiniTest::Unit.autorun