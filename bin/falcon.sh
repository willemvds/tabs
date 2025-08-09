#!/usr/bin/env bash

SCRIPT_FULL_PATH="$(realpath "${BASH_SOURCE[0]:-$0}")"
SCRIPT_DIR="$(dirname "${SCRIPT_FULL_PATH}")"
cd "$SCRIPT_DIR/.."
eval "$(rbenv init -)"

bundle exec falcon host bin/falcon.rb

