#!/bin/bash

# Plex Token Extractor for Unraid
# Automatically finds and extracts Plex API token from running containers
# Designed to run in Unraid User Scripts plugin

# Common Plex container configurations on Unraid
# Format: "container_name:internal_config_path"
PLEX_CONTAINERS=(
    "binhex-plex:/config"
    "binhex-plexpass:/config"
    "plex:/config"
    "Plex-Media-Server:/config"
    "plexinc-pms-docker:/config"
    "linuxserver-plex:/config"
    "lscr.io/linuxserver/plex:/config"
    "plexinc/pms-docker:/config"
)

echo "==========================================="
echo "    Plex Token Extractor for Unraid"
echo "==========================================="
echo ""

# Function to extract token from Preferences.xml
extract_token() {
    local prefs_file="$1"
    if [[ -f "$prefs_file" ]]; then
        local token=$(grep -o 'PlexOnlineToken="[^"]*"' "$prefs_file" 2>/dev/null | cut -d'"' -f2)
        if [[ -n "$token" ]]; then
            echo "SUCCESS: Plex token extracted successfully"
            echo ""
            echo "Plex API Token:"
            echo "================================================================================"
            echo "$token"
            echo "================================================================================"
            echo ""
            echo "Copy this token and paste it into JellEmPlex Dedupe or other containers that need the Plex token"
            echo "Token found in: $prefs_file"
            return 0
        fi
    fi
    return 1
}

# Get list of running containers
echo "Scanning for running Plex containers..."

found_container=false

# Method 1: Check known container patterns
for container_config in "${PLEX_CONTAINERS[@]}"; do
    IFS=':' read -r container_pattern internal_path <<< "$container_config"
    
    # Get container ID if running (check both name and image)
    container_id=$(docker ps --format "{{.ID}} {{.Names}} {{.Image}}" | grep -i "$container_pattern" | awk '{print $1}' | head -1)
    
    if [[ -n "$container_id" ]]; then
        container_name=$(docker ps --format "{{.Names}}" --filter "id=$container_id")
        echo "Found running container: $container_name (ID: $container_id)"
        found_container=true
        
        # Get mount information for the internal config path
        echo "Checking container mounts for $internal_path..."
        
        # Look for the config mount using proper JSON parsing
        config_path=$(docker inspect "$container_id" --format '{{range .Mounts}}{{if eq .Destination "/config"}}{{.Source}}{{end}}{{end}}')
        
        if [[ -n "$config_path" ]]; then
            echo "Found $internal_path mount: $config_path"
            
            # Smart search for Plex Media Server folder and Preferences.xml
            echo "Searching for Plex Media Server folder..."
            
            # Try different possible paths where Preferences.xml might be
            potential_paths=(
                "$config_path/Library/Application Support/Plex Media Server/Preferences.xml"  # LinuxServer style
                "$config_path/Plex Media Server/Preferences.xml"                              # Binhex style
                "$config_path/config/Library/Application Support/Plex Media Server/Preferences.xml"  # Some other styles
            )
            
            # Also dynamically search for "Plex Media Server" folder
            if command -v find >/dev/null 2>&1; then
                echo "Dynamically searching for 'Plex Media Server' folder..."
                while IFS= read -r -d '' plex_folder; do
                    potential_file="$plex_folder/Preferences.xml"
                    potential_paths+=("$potential_file")
                    echo "   Found Plex folder: $plex_folder"
                done < <(find "$config_path" -type d -name "Plex Media Server" -print0 2>/dev/null)
            fi
            
            # Try each potential path
            for prefs_file in "${potential_paths[@]}"; do
                echo "Checking: $prefs_file"
                if extract_token "$prefs_file"; then
                    exit 0
                fi
            done
            
            echo "WARNING: Could not find Preferences.xml in any expected location under: $config_path"
        else
            echo "WARNING: Could not find $internal_path mount for container: $container_name"
            echo "Debug: All mounts for this container:"
            docker inspect "$container_id" --format '{{range .Mounts}}Source: {{.Source}} -> Destination: {{.Destination}}{{println}}{{end}}'
        fi
        echo ""
    fi
done

# Method 2: Direct check of common Unraid paths (fallback)
echo "Checking common Unraid appdata paths directly..."
common_paths=(
    "/mnt/user/appdata/plex/Library/Application Support/Plex Media Server/Preferences.xml"
    "/mnt/user/appdata/binhex-plex/Plex Media Server/Preferences.xml"
    "/mnt/user/appdata/linuxserver-plex/config/Library/Application Support/Plex Media Server/Preferences.xml"
)

for prefs_file in "${common_paths[@]}"; do
    if [[ -f "$prefs_file" ]]; then
        echo "Found Preferences.xml at: $prefs_file"
        if extract_token "$prefs_file"; then
            exit 0
        fi
    fi
done

if [[ "$found_container" == false ]]; then
    echo "ERROR: No running Plex containers found"
    echo ""
    echo "Make sure your Plex container is running and named one of:"
    for container_config in "${PLEX_CONTAINERS[@]}"; do
        IFS=':' read -r container_name internal_path <<< "$container_config"
        echo "   - $container_name"
    done
    echo ""
    echo "If your container has a different name, you can:"
    echo "   1. Add it to the PLEX_CONTAINERS array in this script"
    echo "   2. Or manually find your token in the Preferences.xml file"
    echo ""
    echo "Common Unraid paths:"
    echo "   /mnt/user/appdata/plex/Library/Application Support/Plex Media Server/Preferences.xml"
    echo "   /mnt/user/appdata/binhex-plex/Plex Media Server/Preferences.xml"
else
    echo "ERROR: Token extraction failed"
    echo ""
    echo "Troubleshooting steps:"
    echo "   1. Make sure Plex has been set up and claimed"
    echo "   2. Check if Preferences.xml exists in your appdata"
    echo "   3. Verify the container mounts are correct"
    echo ""
    echo "You can manually check these common locations:"
    echo "   /mnt/user/appdata/plex/Library/Application Support/Plex Media Server/Preferences.xml"
    echo "   /mnt/user/appdata/binhex-plex/Plex Media Server/Preferences.xml"
fi

echo ""
echo "===========================================" 
echo "         Script execution completed"
echo "==========================================="
