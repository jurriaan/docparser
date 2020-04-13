# frozen_string_literal: true

require 'simplecov'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
]
SimpleCov.start do
  # add_filter '/test/'
end
require 'minitest/autorun'
require 'minitest/hell'
require 'minitest/pride'
require 'tempfile'
require 'tmpdir'
require 'simple_mock'
require File.expand_path('../lib/docparser.rb', __dir__)

$TEST_DIR = __dir__
$ROOT_DIR = File.expand_path('..', $TEST_DIR)
$SUPPORT_DIR = File.join(__dir__, 'support/')
