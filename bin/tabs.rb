#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative '../autoloader'

EXIT_CODE_USAGE = 1

args = ARGV
if args.length < 2
  puts 'Usage: tabs <command>'
  exit(EXIT_CODE_USAGE)
end

command = args[0]
Cli::Domains.main(args[1, args.length - 1]) if command == 'domains'
