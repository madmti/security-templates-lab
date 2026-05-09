#!/usr/bin/env bash

YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

REPORTS_DIR="../reports"

show_category() {
    local type=$1
    local files=("$REPORTS_DIR"/*_"$type".secret-scanning.json)

    echo -e "${YELLOW}--- CATEGORÍA: SECRETS (${type^^}) ---${NC}"

    if [ ! -e "${files[0]}" ]; then
        echo -e "No hay hallazgos en esta categoría.\n"
        return
    fi

    for report in "${files[@]}"; do
        repo_name=$(basename "$report" "_$type.secret-scanning.json")
        echo -e "Repo: $repo_name"

        jq -c '.[]' "$report" | while read -r leak; do
            file_rel=$(echo "$leak" | jq -r '.File')
            start_line=$(echo "$leak" | jq -r '.StartLine')
            end_line=$(echo "$leak" | jq -r '.EndLine')

            file_path="../test-repos/$repo_name/$file_rel"
            if [ -f "$file_path" ]; then
                code_block=$(sed -n "${start_line},${end_line}p" "$file_path")
            else
                code_block=$(echo "$leak" | jq -r '.Match')
            fi

            if [ "$type" == "git" ]; then
                message=$(echo "$leak" | jq -r '.Message')
                author=$(echo "$leak" | jq -r '.Author // "N/A"')
                email=$(echo "$leak" | jq -r '.Email // "N/A"')

                echo -e "[\u001b[31m!\u001b[0m] $message by \u001b[1;36m$author\u001b[0m <$email>"
            else
                description=$(echo "$leak" | jq -r '.Description')

                echo -e "[\u001b[31m!\u001b[0m] $description"
            fi

            echo -e " => leak on \u001b[1;33m$file_rel\u001b[0m at \u001b[1;33mlines $start_line-$end_line\u001b[0m"
            echo -e " => detected:"
            echo -e "\u001b[31m$code_block\u001b[0m\n"
        done
    done
    echo ""
}

if ! command -v jq > /dev/null 2>&1; then
    echo "Error: 'jq' es necesario para procesar los reportes."
    exit 1
fi

echo "========================================"
echo "Secret Scanning Reports"
echo "========================================"

show_category "git"
show_category "nogit"
