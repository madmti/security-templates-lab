#!/usr/bin/env bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

REPORTS_DIR="../reports"
mkdir -p "$REPORTS_DIR"

if ! command -v trivy > /dev/null 2>&1; then
    echo "Error: Trivy no está instalado."
    exit 1
fi

scan_iac() {
    local repo_name=$1
    local target_path=$2
    local report_path="$REPORTS_DIR/${repo_name}.iac.json"

    printf "[IaC SCAN] $repo_name : "

    trivy fs --scanners misconfig,vuln "$target_path" \
        --format json \
        --output "$report_path" \
        --severity HIGH,CRITICAL >/dev/null 2>&1

    if [ -s "$report_path" ] && [ "$(jq '.Results | length' "$report_path")" -gt 0 ]; then
        echo -e "${RED}Misconfigurations found${NC}\t $report_path"
    else
        echo -e "${GREEN}Infrastructure is clean${NC}"
        rm -f "$report_path"
    fi
}

echo "========================================"
echo "IaC Scanning (trivy)"
echo "========================================"

for dir in ../test-repos/*/; do
    [ -e "$dir" ] || continue
    repo=$(basename "$dir")
    scan_iac "$repo" "$dir"
done
