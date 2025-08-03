#!/usr/bin/env bash

VERSION=$1

# Excluding .ruby-version till we can figure out debian vs arch situation.
tar cvz -f tabs-$1.tar.xz bin/ lib/ ui/ autoloader.rb Gemfile Gemfile.lock LICENSE README.md

