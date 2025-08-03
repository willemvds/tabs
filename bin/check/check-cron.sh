#!/usr/bin/env bash

DATE=$(date +"%Y%m%d")

cd $TABS_ROOT
bin/check/check.sh storage/domains.lst >> storage/logs/check.$DATE.log

