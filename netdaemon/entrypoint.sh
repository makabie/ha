#!/bin/sh
set -e

# SUPERVISOR_TOKEN is only valid against Supervisor's own API, not against
# Home Assistant Core's REST/WebSocket API directly - use a normal
# Long-Lived Access Token instead, created in the HA profile and set as
# this add-on's "ha_token" option.
HA_TOKEN=$(jq -r '.ha_token // empty' /data/options.json)

if [ -z "$HA_TOKEN" ]; then
    echo "The 'ha_token' add-on option must be set to a Home Assistant Long-Lived Access Token" >&2
    exit 1
fi

export HomeAssistant__Host="${HomeAssistant__Host:-homeassistant}"
export HomeAssistant__Port="${HomeAssistant__Port:-8123}"
export HomeAssistant__Ssl="${HomeAssistant__Ssl:-false}"
export HomeAssistant__Token="$HA_TOKEN"

exec dotnet Apps.dll
