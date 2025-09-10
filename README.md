# Keep-Alive Setup for Network Shares
***
A simple Keep-Alive setup (script + LaunchAgent) that keeps your SMB 
share awake and automatically reconnects it if it gets disconnected. 
You only need to adjust the placeholders.

## Author: Andreas Löwer
GitHub: [@theandy](https://github.com/theandy) · Mail: info@andreasloewer.de

# Installation

## One-time: Save the password in Keychain
Connect once via Finder (⌘K → smb://SERVER/SHARE) and check "**Remember this password in my keychain.**"
After that, the **script can run without requiring a plaintext password**.

## Create or copy the script
Create a small Bash script that:
* re-mounts the share if it’s not connected, and 
* performs a light access every 5 minutes to keep it alive.

```netshare-keepalive.sh
sudo mkdir -p /usr/local/bin
sudo nano /usr/local/bin/netshare-keepalive.sh
```

Copy the file `netshare-keepalive.sh` into the */usr/local/bin* folder and 
adjust the placeholders *SERVER*, *SHARE*, and *MY_SHARE*.
If necessary, add user@ before *SERVER*.

**Important: Make the script executable:** `sudo chmod +x /usr/local/bin/netshare-keepalive.sh`.

## Create the LaunchAgent (every 5 minutes + at login)
This agent runs the script at login and then every 5 minutes.
```LaunchAgent
mkdir -p ~/Library/LaunchAgents
nano ~/Library/LaunchAgents/com.my.netshare.keepalive.plist
```
You can use the file `com.my.netshare.keepalive.plist`

## Load the agent
### On newer versions of macOS
```new
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.my.netshare.keepalive.plist
launchctl kickstart -k gui/$(id -u)/com.my.netshare.keepalive
```
### On older versions of macOS
```old
launchctl load -w ~/Library/LaunchAgents/com.mein.netshare.keepalive.plist
```

## Testing
Intentionally disconnect the share (for example with umount /Volumes/MY_SHARE or by briefly unplugging the cable/Wi-Fi).
Wait until the next 5-minute interval or start it manually

```start
/usr/local/bin/netshare-keepalive.sh
```

To view logs:
```logs
tail -f /tmp/netshare-keepalive.out /tmp/netshare-keepalive.err
```

# Security notes
The script does not contain a plaintext password. Your login credentials are securely stored in the Keychain (from the initial Finder connection).

Script permissions are restricted to your user account. For extra security, you can run:
```security
chmod 700 /usr/local/bin/netshare-keepalive.sh
```