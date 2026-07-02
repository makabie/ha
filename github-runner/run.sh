#!/bin/bash
set -euo pipefail

# The container has no other users and only ever runs this one job, so running
# the runner as root is fine here and avoids losing SUPERVISOR_TOKEN (and any
# other env vars) that `sudo -u` would otherwise strip from the job's environment.
export RUNNER_ALLOW_RUNASROOT=1

OPTIONS_FILE="/data/options.json"
REPO="$(jq -r '.repo' "$OPTIONS_FILE")"
GITHUB_PAT="$(jq -r '.github_pat' "$OPTIONS_FILE")"
RUNNER_NAME="$(jq -r '.runner_name' "$OPTIONS_FILE")"

if [ -z "$REPO" ] || [ -z "$GITHUB_PAT" ]; then
    echo "repo and github_pat options must be set" >&2
    exit 1
fi

cd /home/runner/actions-runner

fetch_token() {
    curl -fsSL -X POST \
        -H "Authorization: Bearer ${GITHUB_PAT}" \
        -H "Accept: application/vnd.github+json" \
        "https://api.github.com/repos/${REPO}/actions/runners/registration-token" \
        | jq -r '.token'
}

REG_TOKEN="$(fetch_token)"

./config.sh \
    --url "https://github.com/${REPO}" \
    --token "${REG_TOKEN}" \
    --name "${RUNNER_NAME}" \
    --work _work \
    --unattended \
    --replace

deregister() {
    echo "Deregistering runner..."
    REMOVE_TOKEN="$(curl -fsSL -X POST \
        -H "Authorization: Bearer ${GITHUB_PAT}" \
        -H "Accept: application/vnd.github+json" \
        "https://api.github.com/repos/${REPO}/actions/runners/remove-token" \
        | jq -r '.token')"
    ./config.sh remove --token "${REMOVE_TOKEN}" || true
}
trap deregister TERM INT

./run.sh &
wait $!