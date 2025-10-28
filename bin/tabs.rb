#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative "../autoloader"

EXIT_CODE_USAGE = 1

args = ARGV
if args.length < 1
  puts "Usage: tabs <command>"
  puts "Commands:"
  puts "  - tabs domains"
  exit(EXIT_CODE_USAGE)
end

command = args[0]
Cli::Domains.main(args[1, args.length - 1]) if command == "domains"
