#!/bin/bash

pat=":"
if [[ "$TSDATE" =~ [$pat] ]]; then
  target_date="${TSDATE#*:}"
  date_options='--tsrange '"$TSDATE"
else
  if [ "$TSDATE" == '' ]; then
    target_date=$(date +'%Y-%m-%d')
  else
    target_date=$(date -j -f '%Y-%m-%d' "$TSDATE" +'%Y-%m-%d')
  fi
  date_options="--tsrange $target_date:$target_date"
fi

echo "Copying sample for $target_date using '$date_options'"

slackcat_cmd=$(printf "%q" "REAL_TAB=\$(echo -e \"\\\\t\"); target_date=$target_date; SLACK_TOKEN=\$(cat ~/.slackcat) slackcat --timesheet $date_options; echo -e \$(cat time_sheet_report.txt) | sed 'x;G;1!h;s/\\\\n//g;\$!d' | jq -r '.report | to_entries | map(select(.key != \"hours\") | .value.entries | map(\"\(.ts) \(.diff) \(.permalink) \(.text)\") | join(\"\\\\n\")) | join(\"\\\\n\\\\n\")' | sed '/^\([[:digit:]]\{4\}\)-\([[:digit:]]\{2\}\)-\([[:digit:]]\{2\}\) \([[:digit:]]\{2\}\):\([[:digit:]]\{2\}\):\([[:digit:]]\{2\}\) [^[:space:]]\{1,\} \([\.[:digit:]]\{1,\}\) \([^[:space:]]\{1,\}\) \(.*\)/ {; s/^\([[:digit:]]\{4\}\)-\([[:digit:]]\{2\}\)-\([[:digit:]]\{2\}\) \([[:digit:]]\{2\}\):\([[:digit:]]\{2\}\):\([[:digit:]]\{2\}\) [^[:space:]]\{1,\} \([\.[:digit:]]\{1,\}\) \([^[:space:]]\{1,\}\) \(.*\)/\\\\1'\$REAL_TAB'\\\\2'\$REAL_TAB'\\\\3'\$REAL_TAB'\\\\4'\$REAL_TAB'\\\\5'\$REAL_TAB'\\\\6'\$REAL_TAB'\\\\7'\$REAL_TAB\$REAL_TAB\$REAL_TAB\$REAL_TAB\$REAL_TAB\$REAL_TAB\$REAL_TAB\$REAL_TAB'\\\\9'\$REAL_TAB'\\\\8/; }' > time_sheet_report-\$target_date.txt; cat time_sheet_report-\$target_date.txt | pbcopy; echo \"hours today: \$(cat time_sheet_report.txt | jq '(.report.\"'\$target_date'\".hours)')\"; echo \"hours for the period: \$(cat time_sheet_report.txt | jq '(.report.hours)')\"; echo \"mvim time_sheet_report-\$target_date.txt\""); echo -e "$slackcat_cmd" | sed -E 's/\\(.)/\1/g' | pbcopy

