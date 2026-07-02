#!/bin/sh
set -e

# Home Assistant Supervisor injects SUPERVISOR_TOKEN when the add-on requests
# `homeassistant_api: true`. That token is valid against Home Assistant Core's
# normal REST/WebSocket API reachable at the internal DNS alias "homeassistant".
export HomeAssistant__Host="${HomeAssistant__Host:-homeassistant}"
export HomeAssistant__Port="${HomeAssistant__Port:-8123}"
export HomeAssistant__Ssl="${HomeAssistant__Ssl:-false}"
export HomeAssistant__Token="${SUPERVISOR_TOKEN}"

exec dotnet Apps.dll
