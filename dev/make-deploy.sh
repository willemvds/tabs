#!/usr/bin/env bash

VERSION=$1
INCLUDE_VENDOR=$2

if [[ -z "$VERSION" ]]; then
    printf "Usage: make-deploy.sh <semantic-version> <include-vendor>\n"
    printf "Example:\n"
    printf "	make-deploy v1.0.0\n"
    printf "	make-deploy v1.0.1 vendor\n"
    printf "\n"
    exit 2
fi

if [ -n "$INCLUDE_VENDOR" ]; then
    INCLUDE_VENDOR="vendor/ruby/3.4.0"
fi

tar cvz -f tabs-$1.tar.xz bin/ lib/ ui/ $INCLUDE_VENDOR .ruby-version autoloader.rb Gemfile Gemfile.lock LICENSE README.md

