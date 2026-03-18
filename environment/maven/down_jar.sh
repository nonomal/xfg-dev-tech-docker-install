#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 1. Check for mvn command
if ! command_exists mvn; then
    echo "Error: 'mvn' command not found. Please install Maven and make sure it is in your PATH."
    exit 1
fi

# Check for curl or wget
if command_exists curl; then
    DOWNLOAD_CMD="curl -L -o"
elif command_exists wget; then
    DOWNLOAD_CMD="wget -O"
else
    echo "Error: Neither 'curl' nor 'wget' found. Please install one of them to download files."
    exit 1
fi

# Check if arguments are provided via command line or prompt user
URLS=()

if [ $# -gt 0 ]; then
    URLS=("$@")
else
    # Prompt user for input
    echo "请输入 Maven Jar 包下载地址 (支持多个地址，用空格分隔):"
    read -r INPUT_STRING
    
    if [ -z "$INPUT_STRING" ]; then
        echo "未输入地址，脚本退出。"
        exit 0
    fi
    
    # Split input string into array
    for url in $INPUT_STRING; do
        URLS+=("$url")
    done
fi

# Common repository path prefixes to ignore when detecting GroupId
# These are directories that often appear before the actual group ID in Maven repo URLs
IGNORE_LIST="maven2|central|repository|public|repositories|libs-release|libs-snapshot|content|groups|browse|artifactory|nexus"

# Process each URL
for URL in "${URLS[@]}"; do
    echo "----------------------------------------------------------------"
    echo "Processing URL: $URL"

    # Clean URL (remove query parameters like ?Expires=...)
    CLEAN_URL=$(echo "$URL" | sed 's/?.*//')
    
    # Extract filename
    FILENAME=$(basename "$CLEAN_URL")
    
    # Create a temporary directory for download
    TEMP_DIR=$(mktemp -d)
    FILE_PATH="$TEMP_DIR/$FILENAME"
    
    echo "Downloading $FILENAME..."
    # Execute download
    $DOWNLOAD_CMD "$FILE_PATH" "$URL"
    
    # Check if download was successful
    if [ $? -ne 0 ]; then
        echo "Error: Failed to download $URL"
        rm -rf "$TEMP_DIR"
        continue
    fi
    
    # Verify file exists and is not empty
    if [ ! -s "$FILE_PATH" ]; then
        echo "Error: Downloaded file is empty or does not exist."
        rm -rf "$TEMP_DIR"
        continue
    fi

    # Parse coordinates from URL structure
    # Expected standard format: .../repository-root/groupId/artifactId/version/filename
    
    # Remove protocol (http:// or https://)
    FULL_PATH_NO_PROTO=$(echo "$CLEAN_URL" | sed -E 's|^https?://[^/]+||')
    
    # Get directory of the file (contains version)
    DIR_PATH=$(dirname "$FULL_PATH_NO_PROTO")
    
    # Extract Version (last component of directory)
    VERSION=$(basename "$DIR_PATH")
    
    # Extract ArtifactId (parent of version directory)
    ARTIFACT_ID=$(basename "$(dirname "$DIR_PATH")")
    
    # Extract GroupId
    # The GroupId path is everything before ArtifactId, minus the repository root prefix.
    GROUP_PATH_RAW=$(dirname "$(dirname "$DIR_PATH")")
    
    # Remove leading slash
    CLEAN_GROUP_PATH=$(echo "$GROUP_PATH_RAW" | sed 's|^/||')
    
    # Split path into segments to filter out repo prefixes
    IFS='/' read -ra SEGMENTS <<< "$CLEAN_GROUP_PATH"
    
    GROUP_ID=""
    START_COLLECTING=false
    
    for segment in "${SEGMENTS[@]}"; do
        if [ "$START_COLLECTING" = true ]; then
            if [ -z "$GROUP_ID" ]; then
                GROUP_ID="$segment"
            else
                GROUP_ID="${GROUP_ID}.$segment"
            fi
        else
            # Check if this segment is in our ignore list
            # We use grep for checking against the pipe-separated list
            if ! echo "$segment" | grep -Eq "^($IGNORE_LIST)$"; then
                # If it's not a stop word, it's likely the start of the group
                START_COLLECTING=true
                GROUP_ID="$segment"
            fi
        fi
    done
    
    # Fallback: If we couldn't filter anything (or empty), use the raw path converted to dots
    if [ -z "$GROUP_ID" ]; then
        echo "Warning: Could not auto-detect GroupId structure. Using full path."
        GROUP_ID=$(echo "$CLEAN_GROUP_PATH" | sed 's|/|.|g')
    fi
    
    echo "Detected coordinates:"
    echo "  GroupId:    $GROUP_ID"
    echo "  ArtifactId: $ARTIFACT_ID"
    echo "  Version:    $VERSION"
    echo "  File:       $FILE_PATH"
    
    # Construct and run mvn install command
    echo "Installing to local Maven repository..."
    mvn install:install-file \
        "-Dfile=$FILE_PATH" \
        "-DgroupId=$GROUP_ID" \
        "-DartifactId=$ARTIFACT_ID" \
        "-Dversion=$VERSION" \
        "-Dpackaging=jar"
        
    if [ $? -eq 0 ]; then
        echo "Success: Installed $FILENAME to local repository."
    else
        echo "Error: Failed to execute mvn install command."
    fi
    
    # Cleanup temporary file
    rm -rf "$TEMP_DIR"
done

echo "----------------------------------------------------------------"
echo "Done."
