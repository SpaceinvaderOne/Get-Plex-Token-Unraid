# Plex Token Extractor for Unraid

A bash script designed to automatically extract Plex API tokens from running Plex containers on Unraid servers. This tool is specifically designed to work with the Unraid User Scripts plugin and supports multiple popular Plex container configurations.

## Features

- Automatically detects running Plex containers
- Supports multiple popular Plex Docker images
- Searches for Plex configuration files in common locations
- Extracts API tokens from Preferences.xml files
- Provides clear error messages and troubleshooting guidance

## Supported Plex Containers

The script automatically detects these popular Plex containers:
- `binhex-plex`
- `binhex-plexpass`
- `plex`
- `Plex-Media-Server`
- `plexinc-pms-docker`
- `linuxserver-plex`

## Installation

### Option 1: Unraid User Scripts Plugin (Recommended)

1. Install the **User Scripts** plugin from Community Applications if not already installed
2. Go to **Settings** → **User Scripts**
3. Click **Add New Script**
4. Name it something like "Get Plex Token"
5. Copy the contents of `get-plex-token.sh` into the script editor
6. Save the script
7. Run script in webGUI to see the token

## Usage

Simply run the script and it will:

1. Scan for running Plex containers
2. Locate the Plex configuration directory
3. Find and parse the Preferences.xml file
4. Extract and display the API token

### Example Output

```
===========================================
    Plex Token Extractor for Unraid
===========================================

Scanning for running Plex containers...
Found running container: binhex-plex (ID: abc123def456)
Checking container mounts for /config...
Found /config mount: /mnt/user/appdata/binhex-plex
Searching for Plex Media Server folder...
Checking: /mnt/user/appdata/binhex-plex/Plex Media Server/Preferences.xml
SUCCESS: Plex token extracted successfully

Plex API Token:
================================================================================
xxxxxxxxxxxxxxxxxxxx
================================================================================

Copy this token and paste it into JellEmPlex Dedupe or other containers that need the Plex token
Token found in: /mnt/user/appdata/binhex-plex/Plex Media Server/Preferences.xml
```

## What is a Plex Token?

A Plex token is an authentication credential that allows applications to interact with your Plex Media Server without requiring username/password authentication. It's commonly needed for:

- Third-party applications like JellEmPlex Dedupe
- API integrations
- Monitoring tools
- Custom scripts

## Troubleshooting

### No Running Plex Containers Found

1. Ensure your Plex container is running
2. Check if your container name matches one of the supported patterns
3. Add your container name to the `PLEX_CONTAINERS` array in the script

### Token Extraction Failed

1. Make sure Plex has been set up and claimed to your account
2. Verify the Preferences.xml file exists in your appdata folder
3. Check container mount configurations

### Common Manual Locations

If the script fails, you can manually check these locations:
- `/mnt/user/appdata/plex/Library/Application Support/Plex Media Server/Preferences.xml`
- `/mnt/user/appdata/binhex-plex/Plex Media Server/Preferences.xml`

Look for the `PlexOnlineToken` attribute in the XML file.

## Security Notes

- Keep your Plex token secure and don't share it publicly
- The token provides access to your Plex server
- Consider regenerating the token if you suspect it's been compromised

## Requirements

- Unraid server with Userscripts plugin
- Running Plex container
- Plex server that has been claimed/set up

## Contributing

Feel free to submit issues or pull requests to improve the script or add support for additional container configurations.

## License

This script is provided as-is for personal use. Use at your own risk.
