#!/bin/bash

# exit on failures
set -e
set -o pipefail

# get all repos with whippet.lock in root
REPOS=$(gh api -X GET search/code -f q='filename:whippet.lock org:dxw path:/' --paginate  -q '[ .items[].repository.full_name ]' | jq -r '.[]')
for REPO in $REPOS; do
  # skip archived repos
  REPO_IS_ARCHIVED=$(eval "gh api -X GET repos/$REPO -q '.archived'")
  if [ "$REPO_IS_ARCHIVED" = true ]; then
    continue
  fi

  # get the repo topics
  TOPICS=$(eval "gh api -X GET repos/$REPO/topics -H accept:application/vnd.github.mercy-preview+json -q '[ .names[] ]' | jq -r '.[]'")
  # skip if it already includes the whippet-app topic
  if [[ ! " ${TOPICS[*]} " =~ "whippet-app" ]]; then
    touch input.json
    NEW_TOPICS=${TOPICS}
    if [ ${#TOPICS} -gt 0 ]; then
      NEW_TOPICS+=('whippet-app')
    else
      NEW_TOPICS=('whippet-app')
    fi
    printf '%s\n' "${NEW_TOPICS[@]}" | jq -R . | jq -s '{ "names": . }' > input.json
    eval "gh api -X PUT repos/$REPO/topics -H accept:application/vnd.github.mercy-preview+json --input input.json --silent"
    echo "$REPO updated"
    unset NEW_TOPICS
  fi

done

# cleanup
rm input.json
