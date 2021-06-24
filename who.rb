# frozen_string_literal: true

# written by Victor Pereira <vpereira@suse.com>
require 'json'
require 'open3'
require 'optparse'

class JournalLog
  def self.parse
    return [] if $stdin.tty?

    # Ruby 2.7 = filter_map
    $stdin.read.each_line.map do |line|
      JSON.parse(line)
    end.select do |json_data|
      json_data['MESSAGE'] =~ /Accepted publickey/
    end.map do |data|
      { key: data['MESSAGE'].split('SHA256:').last, timestamp: data['__REALTIME_TIMESTAMP'] }
    end
  end
end

class RunCommand
  def initialize(auth_keys_file)
    @auth_keys_file = auth_keys_file
  end

  def run(key)
    out, err, status = Open3.capture3(*ssh_keygen_params)
    xout, xerr, xstatus = Open3.capture3(*grep_params(key), stdin_data: out)
    xout
  end

  private

  def grep_params(key)
    ['/usr/bin/grep', "SHA256:#{key}"]
  end

  def ssh_keygen_params
    ['/usr/bin/ssh-keygen', '-lf', @auth_keys_file]
  end
end

if $PROGRAM_NAME == __FILE__
  authorized_keys_file = ARGV[0].nil? ? "#{ENV['HOME']}/.ssh/authorized_keys" : ARGV[0]

  JournalLog.parse.reject do |entry|
    RunCommand.new(authorized_keys_file).run(entry[:key]).empty?
  end.each do |entry|
    cmd = RunCommand.new(authorized_keys_file).run(entry[:key])
    puts "#{Time.at(entry[:timestamp].to_i / 1_000_000)} - #{cmd}"
  end
end
