#!/usr/bin/env bash

cd $TABS_ROOT
bundle exec ruby bin/check/check.rb "$@"

