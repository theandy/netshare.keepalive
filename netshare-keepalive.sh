#!/usr/bin/env bash
set -euo pipefail

USER="werbestudio"
SERVER="192.168.100.240"
SHARE="Sonstiges"
URL="smb://${USER}@${SERVER}/${SHARE}"

# Ist das Share gemountet? (optional -N Suffix sauber behandelt)
is_mounted() {
  mount | grep -qE "on /Volumes/${SHARE}(-[0-9]+)? .*smbfs"
}

# aktuellen Mountpoint ermitteln (/Volumes/SHARE oder /Volumes/SHARE-1 ...)
resolve_mountpoint() {
  ls -d "/Volumes/${SHARE}" "/Volumes/${SHARE}-"* 2>/dev/null | head -n1
}

# Mount über AppleScript (nutzt Schlüsselbund-Creds, wenn vorher dort gespeichert)
mount_share() {
/usr/bin/osascript <<EOF
try
  mount volume "$URL"
end try
EOF
}

# --- Ablauf ---
if ! is_mounted; then
  echo "[netshare] nicht gemountet → mounte $URL ..."
  mount_share
  sleep 2
fi

MP="$(resolve_mountpoint || true)"

if [ -n "${MP:-}" ] && [ -d "$MP" ]; then
  # Keep-Alive
  ls "$MP" >/dev/null 2>&1 || true
  touch "$MP/.keepalive" 2>/dev/null || true
  stat "$MP/.keepalive" >/dev/null 2>&1 || true
  echo "[netshare] ok auf $MP"
else
  echo "[netshare] Mountpoint nicht gefunden"
fi
