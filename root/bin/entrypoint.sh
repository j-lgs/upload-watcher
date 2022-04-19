#!/bin/sh
find "$BETANIN_INBOX" -maxdepth 1 -type f -exec "$@" \
     {} "$BETANIN_INBOX" "$BETANIN_APIKEY" "$BETANIN_HOST" \;
