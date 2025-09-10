# Keep-Alive-Setup for netshares
***
An easy Keep-Alive-Setup (Script + LaunchAgent) that keeps your SMB share 
awake and reconnects it if it gets disconnected. You just need to adjust the placeholders.



# Installation

## One-time: Save the password in Keychain
Connect once via Finder (⌘K → smb://SERVER/SHARE) and check "Remember this password in my keychain."
After that, the script can run without needing a plaintext password.

## Create/copy the script
Create a small Bash script that:
* re-mounts if it’s not connected, and 
* performs a light access every 5 minutes (keep-alive).

```netshare-keepalive.sh
sudo mkdir -p /usr/local/bin
sudo nano /usr/local/bin/netshare-keepalive.sh
```

Copy the file netshare-keepalive.sh to the /usr/local/bin folder and 
adjust placeholders SERVER, SHARE, MY_SHARE; if needed, add user@ before SERVER).

Important: Make the script executable with `sudo chmod +x /usr/local/bin/netshare-keepalive.sh`.

## Create the LaunchAgent (every 5 minutes + at login)
This agent runs the script at login and then every 5 minutes.
```LaunchAgent
mkdir -p ~/Library/LaunchAgents
nano ~/Library/LaunchAgents/com.my.netshare.keepalive.plist
```
You can use the file `com.my.netshare.keepalive.plist`

## Load the agent
### New macOS
```new
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.my.netshare.keepalive.plist
launchctl kickstart -k gui/$(id -u)/com.my.netshare.keepalive
```
### Old macOS
```old
launchctl load -w ~/Library/LaunchAgents/com.mein.netshare.keepalive.plist
```

## Testing
Intentionally disconnect the connection (e.g. umount /Volumes/MY_SHARE or briefly unplug the cable/Wi-Fi).
Wait until the next 5-minute interval or start it manually:

```start
/usr/local/bin/netshare-keepalive.sh
```

View logs:
```logs
tail -f /tmp/netshare-keepalive.out /tmp/netshare-keepalive.err
```

# Security notes
No plaintext password in the script. The login credentials are stored securely in the Keychain (because you connected once via Finder).

The script’s permissions are set so that only you can execute it — you can additionally run chmod 700 for extra security.