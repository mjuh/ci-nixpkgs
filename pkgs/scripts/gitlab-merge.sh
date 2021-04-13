#!/usr/bin/env bash

set -e
set -o pipefail

export PATH=@curl@/bin:@jq@/bin:"$PATH"

PRIVATE_TOKEN="${GITLAB_PRIVATE_TOKEN}"
PROJECT_NAME="${GITLAB_PROJECT_NAME:-$(basename "$PWD")}"
PROJECT_GROUP="${GITLAB_GROUP_NAME:-$(basename "$(dirname "$PWD")")}"
PROJECT_ID="${GITLAB_GROUP_ID:-$(curl --insecure --header 'Content-Type: application/json' --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" "https://gitlab.intr/api/v4/projects/$PROJECT_GROUP%2F$PROJECT_NAME" | jq .id)}"
ASSIGNEE_USER="${GITLAB_ASSIGNEE_USER:-rezvov}"
SQUASH="${GITLAB_SQUASH:-false}"
BROWSE="${GITLAB_BROWSE:-true}"

assignee_id()
{
    curl --insecure \
         --header "Content-Type: application/json" \
         --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" \
         "https://gitlab.intr/api/v4/users?active=true" \
        | jq --raw-output ".[] | select(.username == \"$1\") | .id"
}
ASSIGNEE_ID="${GITLAB_ASSIGNEE_ID:-$(assignee_id "$ASSIGNEE_USER")}"

merge_request()
{
    curl --insecure \
         --request POST \
         --header 'Content-Type: application/json' \
         --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" \
         "https://gitlab.intr/api/v4/projects/$PROJECT_ID/merge_requests" \
         --data "{\"source_branch\": \"$(git branch --show-current)\", \"target_branch\": \"${GITLAB_TARGET_BRANCH:-master}\", \"title\": \"$(git log -1 --format=%s)\", \"assignee_id\": \"$ASSIGNEE_ID\", \"remove_source_branch\": \"true\", \"squash\": \"$SQUASH\"}"
}

web_url="$(merge_request | jq --raw-output .web_url)"

printf "%s\n" "$web_url"
