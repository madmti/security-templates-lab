#!/usr/bin/env bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

REPORTS_DIR="../reports"
mkdir -p "$REPORTS_DIR"

rm -f "$REPORTS_DIR"/*.secret-scanning.json

scan() {
    local repo=$1
    local mode=$2
    local extra_args=""
    local report_path="$REPORTS_DIR/${repo}_${mode}.secret-scanning.json"

    [ "$mode" == "nogit" ] && extra_args="--no-git"

    printf "[SCAN $mode] $repo : "

    gitleaks detect --source "../test-repos/$repo" \
        --config ./gitleaks.toml \
        --report-path "$report_path" \
        --report-format json \
        $extra_args >/dev/null 2>&1

    RES=$?

    if [ $RES -ne 0 ]; then
        echo -e "${RED}Found secrets${NC}\t\t ${report_path/..\//}"
    else
        echo -e "${GREEN}No secrets found${NC}"
        rm -f "$report_path"
    fi
}

if ! command -v gitleaks > /dev/null 2>&1; then
    echo "Error: Gitleaks not found."
    exit 1
fi

echo "========================================"
echo "Secret Scanning Tests"
echo "========================================"

for dir in ../test-repos/*/; do
    [ -e "$dir" ] || continue
    repo=$(basename "$dir")
    scan "$repo" "git"
    scan "$repo" "nogit"
done
