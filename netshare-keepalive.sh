#!/usr/bin/env bash
set -euo pipefail

SERVER="192.168.100.240"   # z.B. synology.local oder 192.168.1.50
SHARE="SYNOLOGY_NAS"                # so heißt der Ordner unter /Volumes
# URL="smb://$SERVER/$SHARE"
URL="smb://werbestudio@$SERVER/$SHARE"

# Prüft, ob das Share gemountet ist (smbfs) – unabhängig von evtl. -1/-2 Suffixen
is_mounted() {
  mount | grep -qE "on /Volumes/${SHARE}(|-[0-9]+) .*smbfs"
}

# Findet den aktuellen Mountpoint (/Volumes/SHARE oder /Volumes/SHARE-1, …)
resolve_mountpoint() {
  ls -d "/Volumes/${SHARE}" "/Volumes/${SHARE}-"* 2>/dev/null | head -n1
}

# Mount per AppleScript -> nutzt Keychain-Creds (vorher im Finder einmal mit "im Schlüsselbund speichern" verbinden)
mount_share() {
/usr/bin/osascript <<EOF
try
  mount volume "$URL"
end try
EOF
}

# --- Hauptablauf ---
if ! is_mounted; then
  echo "[netshare] nicht gemountet → mounte $URL ..."
  mount_share
  sleep 2
fi

MP="$(resolve_mountpoint || true)"

if [ -n "${MP:-}" ] && [ -d "$MP" ]; then
  # Keep-Alive-Aktionen, damit Session wach bleibt
  ls "$MP" >/dev/null 2>&1 || true
  touch "$MP/.keepalive" 2>/dev/null || true
  stat "$MP/.keepalive" >/dev/null 2>&1 || true
  echo "[netshare] ok auf $MP"
else
  echo "[netshare] Mountpoint nicht gefunden"
fi