#!/usr/bin/env bash
set -euo pipefail

SERVER="192.168.100.240"          	# z.B. nas.local oder 192.168.100.240
SHARE="Bilder"         			# z.B. Daten
MOUNTPOINT="/Volumes/SYNOLOGY_NAS"  	# wie das Volume heißen soll
# URL="smb://$SERVER/$SHARE"
URL="smb://werbestudio@$SERVER/$SHARE"

# Prüfen, ob gemountet
is_mounted() {
  mount | grep -q "on $MOUNTPOINT "
}

# Sanft mounten über AppleScript -> nutzt Schlüsselbund-Creds
mount_share() {
  /usr/bin/osascript <<EOF
try
  mount volume "$URL"
end try
EOF
}

mkdir -p "$MOUNTPOINT"

if ! is_mounted; then
  echo "[netshare] nicht gemountet → versuche Mount..."
  mount_share
  # kurze Wartezeit
  sleep 2
fi

if is_mounted; then
  # Keep-Alive: leichtes Listing und eine winzige Datei anfassen
  ls "$MOUNTPOINT" >/dev/null 2>&1 || true
  touch "$MOUNTPOINT/.keepalive" 2>/dev/null || true
  stat "$MOUNTPOINT/.keepalive" >/dev/null 2>&1 || true
  echo "[netshare] ok"
else
  echo "[netshare] Mount fehlgeschlagen"
fi
