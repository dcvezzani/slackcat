#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: ./adhoc.sh 'brb'"
  echo "Usage: ./adhoc.sh 'brb' 2016-06-27"
  echo "Usage: ./adhoc.sh 'brb' 2016-06-27 engineering"
  echo "Usage: ./adhoc.sh 'brb' 2016-06-27 engineering,engineering-firefight,engineering-private,internal-engineering"
  exit 1
fi

ruby '/Users/davidvezzani/reliacode/crystal_commerce/slackcat/bin/slack_one_off.rb' "$1" $2 $3 | jq -r '.' 2>&1 | tee -a "resp-$(date +%Y%m%d).json"

