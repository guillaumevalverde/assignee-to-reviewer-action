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
reviewers=$(jq --raw-output '.pull_request.requested_reviewers|map(."login")' "$GITHUB_EVENT_PATH")
assignee=$(jq --raw-output .assignee.login "$GITHUB_EVENT_PATH")
list_reviewers=${reviewers//\"/\\\"}
listReviewerWithoutSpace=`echo "${list_reviewers}" | tr -d '[:space:]'`
listReviewerWithoutSpace2=`echo ${list_reviewers} | tr -d '[:space:]'`
#listReviewerWithoutSpace = `echo ${list_reviewers} | tr -d '[:space:]'`
                            
echo "set as reviewer: "
echo "${assignee}"
echo "${list_reviewers}"
echo "${listReviewerWithoutSpace}"
echo "${listReviewerWithoutSpace2}"
#echo ${listReviewerWithoutSpace}
#echo $list_reviewers

update_review_request() {
  curl -sSL \
    -H "Content-Type: application/json" \
    -H "${AUTH_HEADER}" \
    -H "${API_HEADER}" \
    -X $1 \
    -d "{\"assignees\":"${listReviewerWithoutSpace2}"}" \
    "https://api.github.com/repos/${GITHUB_REPOSITORY}/issues/${number}/assignees"
}
#    -d "{\"assignees\":[\"slopezju\",\"drevlav\"]}" \

if [[ "$action" == "review_requested" ]]; then
  update_review_request 'POST'
elif [[ "$action" == "review_request_removed" ]]; then
  update_review_request 'DELETE'
else
  echo "Ignoring action ${action}"
  exit 0
fi
