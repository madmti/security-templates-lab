#!/usr/bin/env bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

show-reports-git() {
    echo -e "\nDetails:\n"

    files=(./reports-git/*.json)
    if [ ! -e "${files[0]}" ]; then
        echo "No reports found."
        return
    fi

    for report in "${files[@]}"; do
        jq -r '.[] |
            "[\u001b[31m!\u001b[0m] \(.Message) by \(.Author) <\(.Email)>\n" +
            " => leak on \(.File) at line \(.StartLine)\n" +
            " => detected \u001b[31m\(.Match)\u001b[0m\n"' "$report"
    done
}

show-reports-no-git() {
    echo -e "\nDetails:\n"

    files=(./reports-no-git/*.json)
    if [ ! -e "${files[0]}" ]; then
        echo "No reports found."
        return
    fi

    for report in "${files[@]}"; do
        jq -r '.[] |
            "[\u001b[31m!\u001b[0m] \(.Description)\n" +
            " => leak on \(.File) at line \(.StartLine)\n" +
            " => detected \u001b[31m\(.Match)\u001b[0m\n"' "$report"
    done
}

scan-git() {
    printf "[SCAN] $1 : "
    RES=$(gitleaks detect --source "./tests/$1" --config ./gitleaks.toml --report-path "./reports-git/$1.json" --report-format json >/dev/null 2>&1; echo $?)
    if [ $RES -ne 0 ]; then
        echo -e "${RED}Found secrets${NC}\t\t ./reports-git/$1.json"
    else
        echo -e "${GREEN}No secrets found${NC}"
    fi
}

scan-no-git() {
    printf "[SCAN] $1 : "
    RES=$(gitleaks detect --source "./tests/$1" --config ./gitleaks.toml --report-path "./reports-no-git/$1.json" --report-format json --no-git >/dev/null 2>&1; echo $?)
    if [ $RES -ne 0 ]; then
        echo -e "${RED}Found secrets${NC}\t\t ./reports-no-git/$1.json"
    else
        echo -e "${GREEN}No secrets found${NC}"
    fi
}

# ================================================================

if command -v gitleaks > /dev/null 2>&1; then
    echo "Gitleaks exists."
else
    echo "Gitleaks does not exist."
fi

rm -rf ./reports-git
mkdir -p ./reports-git

echo "====================="
echo "Scanning GIT"
echo "====================="

for dir in ./tests/*/; do
    dir="${dir/.\/tests\//}"
    dir="${dir/\/}"
    scan-git $dir
done

show-reports-git

rm -rf ./reports-no-git
mkdir -p ./reports-no-git

echo "====================="
echo "Scanning NO GIT"
echo "====================="

for dir in ./tests/*/; do
    dir="${dir/.\/tests\//}"
    dir="${dir/\/}"
    scan-no-git $dir
done

show-reports-no-git
