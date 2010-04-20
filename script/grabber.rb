#!/usr/bin/env ruby

require 'rubygems'
require 'daemons'

RailsRoot = File.dirname(__FILE__) + '/..'

Daemons.run("#{RailsRoot}/lib/grabber.rb",
            :dir => '../tmp/pids',
            :dir_mode => :script,
            :backtrace => true,
            :log_output => true
           )

