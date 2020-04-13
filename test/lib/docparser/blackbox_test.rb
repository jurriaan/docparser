# frozen_string_literal: true

require_relative '../../test_helper'
require 'open3'
require 'shellwords'

def cmd_to_sys(command)
  Open3.popen3(command) do |_stdin, stdout, stderr|
    [stdout.read, stderr.read]
  end
end

describe DocParser do
  it 'should run the example without problems' do
    curwd = Dir.getwd
    Dir.mktmpdir do |dir|
      Dir.chdir(dir)
      example_file = Shellwords.escape(File.join($ROOT_DIR, 'example.rb'))
      _, err = cmd_to_sys '/usr/bin/env ruby ' + example_file
      rows = err.scan(/(\d+) rows/).flatten
      rows.length.must_equal 5
      row_lengths = rows.group_by(&:to_i)
      row_lengths.length.must_equal 1
      # HaD: 40 pages of 7 articles
      row_lengths.keys.first.must_equal(7 * 40)
      err.must_match(/Done processing/)
    end
    Dir.chdir(curwd)
  end
end
