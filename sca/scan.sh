#!/usr/bin/env bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

REPORTS_DIR="../reports"
mkdir -p "$REPORTS_DIR"

if ! command -v osv-scanner > /dev/null 2>&1; then
    echo "Error: osv-scanner no está instalado."
    exit 1
fi

scan_dependencies() {
    local repo_name=$1
    local target_path=$2
    local report_path="$REPORTS_DIR/${repo_name}.sca.json"

    printf "[SCA SCAN] $repo_name : "

    osv-scanner -r "$target_path" --format json > "$report_path" 2>/dev/null

    if [ -s "$report_path" ] && [ "$(jq '.results | length' "$report_path")" -gt 0 ]; then
        echo -e "${RED}Vulnerable dependencies found${NC}\t $report_path"
    else
        echo -e "${GREEN}Dependencies are safe${NC}"
        rm -f "$report_path"
    fi
}

echo "========================================"
echo "SCA Scanning (osv-scanner)"
echo "========================================"

for dir in ../test-repos/*/; do
    [ -e "$dir" ] || continue
    repo=$(basename "$dir")
    scan_dependencies "$repo" "$dir"
done
