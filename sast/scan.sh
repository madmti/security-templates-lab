#!/usr/bin/env bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

REPORTS_DIR="../reports"
mkdir -p "$REPORTS_DIR"

declare -A REPO_CONFIGS
REPO_CONFIGS["juice-shop"]="p/owasp-top-ten p/typescript p/javascript"
REPO_CONFIGS["pygoat"]="p/owasp-top-ten p/python p/django"
REPO_CONFIGS["vulhub"]="p/owasp-top-ten p/docker p/docker-compose"

DEFAULT_CONFIG="p/security-audit"

scan() {
    local repo_name=$1
    local configs=$2
    local target_path=$3
    local report_path="$REPORTS_DIR/${repo_name}.sast.json"

    read -ra CONFIG_ARRAY <<< "$configs"

    local SEMGREP_ARGS=()
    for cfg in "${CONFIG_ARRAY[@]}"; do
        SEMGREP_ARGS+=("--config" "$cfg")
    done
    # -------------------------------------

    printf "[SAST SCAN] $repo_name : "

    semgrep scan "${SEMGREP_ARGS[@]}" --json -o "$report_path" "$target_path" >/dev/null 2>&1

    RES=$?

    if [ $RES -eq 0 ]; then
        if [ -s "$report_path" ] && [ "$(jq '.results | length' "$report_path")" -gt 0 ]; then
            echo -e "${RED}Found vulnerabilities${NC}\t $report_path"
        else
            echo -e "${GREEN}No issues found${NC}"
            rm -f "$report_path"
        fi
    else
         echo -e "${RED}Scan failed or issues found${NC}"
    fi
}

echo "========================================"
echo "SAST Scanning Tests (Semgrep)"
echo "========================================"

for dir in ../test-repos/*/; do
    [ -e "$dir" ] || continue
    repo=$(basename "$dir")

    if [[ -v REPO_CONFIGS[$repo] ]]; then
        current_configs=${REPO_CONFIGS[$repo]}
    else
        current_configs=$DEFAULT_CONFIG
    fi

    scan "$repo" "$current_configs" "$dir"
done
