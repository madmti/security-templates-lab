#!/usr/bin/env bash

YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

REPORTS_DIR="../reports"

show_sast_reports() {
    echo -e "${YELLOW}--- CATEGORÍA: SAST (Semgrep) ---${NC}"

    files=("$REPORTS_DIR"/*.sast.json)

    if [ ! -e "${files[0]}" ]; then
        echo -e "No hay reportes de SAST encontrados.\n"
        return
    fi

    for report in "${files[@]}"; do
        repo_name=$(basename "$report" .sast.json)
        echo -e "Repo: $repo_name"

        jq -c '.results[]' "$report" | while read -r result; do
            message=$(echo "$result" | jq -r '.extra.message')
            file_path=$(echo "$result" | jq -r '.path')

            # Extraemos inicio y fin
            start_line=$(echo "$result" | jq -r '.start.line')
            end_line=$(echo "$result" | jq -r '.end.line')

            if [ -f "$file_path" ]; then
                code_block=$(sed -n "${start_line},${end_line}p" "$file_path")
            else
                code_block="[No se pudo leer el archivo]"
            fi

            echo -e "[\u001b[31m!\u001b[0m] $message"
            echo -e " => leak on \u001b[1;33m$file_path\u001b[0m at \u001b[1;33mlines $start_line-$end_line\u001b[0m"
            echo -e " => detected:"
            echo -e "\u001b[31m$code_block\u001b[0m\n"
        done
    done
}

echo "========================================"
echo "SAST Scanning Reports (Semgrep)"
echo "========================================"
show_sast_reports
