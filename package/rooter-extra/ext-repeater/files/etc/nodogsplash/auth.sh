#!/bin/sh
. /lib/functions.sh

log() {
	logger -t "Portal Auth" "$@"
}

METHOD="$1"
MAC="$2"
USERNAME="$3"
PASSWORD="$4"
newpass=$(uci -q get portal.portal.portalpassword)

case "$METHOD" in
  auth_client)
    if [ "$USERNAME" = "admin" -a "$PASSWORD" = $newpass ]; then
      # Allow client to access the Internet for one hour (3600 seconds)
      # Further values are upload and download limits in bytes. 0 for no limit.
	  time=$(uci -q get portal.portal.time)
	  if [ $time -lt 0 ]; then
		time=1
	  fi
      echo $time 0 0
      exit 0
    else
      # Deny client to access the Internet.
      exit 1
    fi
    ;;
  client_auth|client_deauth|idle_deauth|timeout_deauth|ndsctl_auth|ndsctl_deauth|shutdown_deauth)
    INGOING_BYTES="$3"
    OUTGOING_BYTES="$4"
    SESSION_START="$5"
    SESSION_END="$6"
    # client_auth: Client authenticated via this script.
    # client_deauth: Client deauthenticated by the client via splash page.
    # idle_deauth: Client was deauthenticated because of inactivity.
    # timeout_deauth: Client was deauthenticated because the session timed out.
    # ndsctl_auth: Client was authenticated by the ndsctl tool.
    # ndsctl_deauth: Client was deauthenticated by the ndsctl tool.
    # shutdown_deauth: Client was deauthenticated by Nodogsplash terminating.
    ;;
esac