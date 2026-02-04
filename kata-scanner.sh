#!/bin/bash

# Registry authentication logic
export REGISTRY_AUTH_FILE="${REGISTRY_AUTH_FILE:-$HOME/.docker/config.json}"

if [[ ! -f "$REGISTRY_AUTH_FILE" ]]; then
    echo "Note: Registry auth file not found at $REGISTRY_AUTH_FILE."
fi

# Input validation
if [[ -z "$1" ]]; then
    echo "Usage: $0 <start_version> [end_version]"
    echo "Example (Range):  $0 4.15 4.16.2"
    echo "Example (Single): $0 4.19.2"
    exit 1
fi

START_VER=$1
END_VER=${2:-$1}

declare -A KATA_RESULTS

echo "Fetching available versions from OpenShift mirror..."
ALL_VERSIONS=$(curl -s https://mirror.openshift.com/pub/openshift-v4/clients/ocp/ | \
               grep -oP "4\.[0-9]+\.[0-9]+" | sort -V | uniq)

if [[ "$START_VER" == "$END_VER" ]]; then
    echo "Scanning single version: $START_VER"
else
    echo "Scanning range: $START_VER to $END_VER"
fi
echo "-----------------------------------------------------------------------"

for v in $ALL_VERSIONS; do
    # Robust version comparison using sort -V
    # This checks if v is between START and END inclusive
    is_not_too_low=$(printf '%s\n%s' "$START_VER" "$v" | sort -V | head -n1)
    is_not_too_high=$(printf '%s\n%s' "$END_VER" "$v" | sort -V | tail -n1)

    if [[ "$is_not_too_low" == "$START_VER" ]] && [[ "$is_not_too_high" == "$END_VER" ]]; then
        echo -n "Checking $v... "
        
        # Get the pull spec
        IMAGE=$(oc adm release info --image-for rhel-coreos-extensions "quay.io/openshift-release-dev/ocp-release:${v}-x86_64" 2>/dev/null)
        
        if [[ -z "$IMAGE" ]]; then
            output="ERROR: Image pull spec not found"
        else
            # Run podman and strip the directory path
            raw_output=$(podman run --rm --quiet --authfile "$REGISTRY_AUTH_FILE" --entrypoint bash "$IMAGE" -c "ls /usr/share/rpm-ostree/extensions/*kata* 2>/dev/null")
            
            if [[ -z "$raw_output" ]]; then 
                output="No kata files found"
            else
                # Clean up the string: remove path, flatten to one line
                output=$(echo "$raw_output" | sed 's|/usr/share/rpm-ostree/extensions/||g' | tr '\n' ' ' | xargs)
            fi
        fi
        
        echo "$output"
        KATA_RESULTS["$output"]="${KATA_RESULTS["$output"]} $v"
    fi
done

if [[ ${#KATA_RESULTS[@]} -eq 0 ]]; then
    echo "No matching versions found."
    exit 0
fi

echo -e "\n======================================================================="
echo "RESULTS GROUPED BY RPM FILENAMES"
echo "======================================================================="

for key in "${!KATA_RESULTS[@]}"; do
    echo "EXTENSIONS: $key"
    echo "VERSIONS:"
    echo "${KATA_RESULTS[$key]}" | xargs -n 5 | sed 's/^/  /'
    echo "-----------------------------------------------------------------------"
done
