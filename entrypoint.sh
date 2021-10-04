#!/bin/bash
set -eu

if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Set the GITHUB_TOKEN env variable."
  exit 1
fi

if [[ -z "$GITHUB_EVENT_NAME" ]]; then
  echo "Set the GITHUB_EVENT_NAME env variable."
  exit 1
fi

if [[ -z "$GITHUB_EVENT_PATH" ]]; then
  echo "Set the GITHUB_EVENT_PATH env variable."
  exit 1
fi

API_HEADER="Accept: application/vnd.github.v3+json; application/vnd.github.antiope-preview+json"
AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"

action=$(jq --raw-output .action "$GITHUB_EVENT_PATH")
number=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")
pullre=$(jq --raw-output . "$GITHUB_EVENT_PATH")
reviewer=$(jq --raw-output .pull_request.requested_reviewers "$GITHUB_EVENT_PATH")
#reviewerTest=$(jq --raw-output .pull_request.requested_reviewers.|map(."login") "$GITHUB_EVENT_PATH")

echo "debug"

echo "${pullre}"
echo "debug2"


echo "debug"

echo "${reviewerTest}"
echo "debug2"
update_review_request() {
  curl -sSL \
    -H "Content-Type: application/json" \
    -H "${AUTH_HEADER}" \
    -H "${API_HEADER}" \
    -X $1 \
    -d "{\"assignees\":[\"slopezju\",\"guillaumevalverde\"]}" \
    "https://api.github.com/repos/${GITHUB_REPOSITORY}/issues/${number}/assignees"
}

if [[ "$action" == "review_requested" ]]; then
  update_review_request 'POST'
elif [[ "$action" == "review_request_removed" ]]; then
  update_review_request 'DELETE'
else
  echo "Ignoring action ${action}"
  exit 0
fi
