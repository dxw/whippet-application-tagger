#!/bin/bash

# exit on failures
set -e
set -o pipefail

# get all repos with whippet.lock in root
echo "Getting list of repos to update..."
REPOS=$(gh api -X GET search/code -f q='filename:whippet.lock org:dxw path:/' --paginate  -q '[ .items[].repository.full_name ]' | jq -r '.[]')
for REPO in $REPOS; do
  echo "Checking $REPO"
  # skip archived repos
  REPO_IS_ARCHIVED=$(eval "gh api -X GET repos/$REPO -q '.archived'")
  if [ "$REPO_IS_ARCHIVED" = true ]; then
    echo "$REPO is archived, skipping"
    continue
  fi

  # get the repo topics
  TOPICS=$(eval "gh api -X GET repos/$REPO/topics -H accept:application/vnd.github.mercy-preview+json -q '[ .names[] ]' | jq -r '.[]'")
  # skip if it already includes the whippet-app topic
  if [[ ! " ${TOPICS[*]} " =~ "whippet-app" ]]; then
    echo "$REPO does not have tag"
    touch input.json
    NEW_TOPICS=${TOPICS}
    if [ ${#TOPICS} -gt 0 ]; then
      NEW_TOPICS+=('whippet-app')
    else
      NEW_TOPICS=('whippet-app')
    fi
    echo "Adding tag to $REPO"
    printf '%s\n' "${NEW_TOPICS[@]}" | jq -R . | jq -s '{ "names": . }' > input.json
    eval "gh api -X PUT repos/$REPO/topics -H accept:application/vnd.github.mercy-preview+json --input input.json --silent"
    echo "$REPO updated"
    unset NEW_TOPICS
    rm input.json
  else
    echo "$REPO already has tag"
  fi

done
