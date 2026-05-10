#!/usr/bin/env bash

YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

REPORTS_DIR="../reports"

show_iac_reports() {
    echo -e "${YELLOW}--- CATEGORÍA: IaC (Infraestructura) ---${NC}"

    files=("$REPORTS_DIR"/*.iac.json)
    if [ ! -e "${files[0]}" ]; then
        echo -e "No hay reportes de IaC encontrados.\n"
        return
    fi

    for report in "${files[@]}"; do
        repo_name=$(basename "$report" .iac.json)
        echo -e "Repo: $repo_name"

        jq -c '.Results[] | select(.Misconfigurations != null) | {Target, Misconfigurations}' "$report" | while read -r result; do
            target=$(echo "$result" | jq -r '.Target')

            echo "$result" | jq -c '.Misconfigurations[]' | while read -r misconf; do
                id=$(echo "$misconf" | jq -r '.ID')
                title=$(echo "$misconf" | jq -r '.Title')
                severity=$(echo "$misconf" | jq -r '.Severity')
                msg=$(echo "$misconf" | jq -r '.Message')

                line=$(echo "$misconf" | jq -r '.CauseMetadata.StartLine // "N/A"')

                echo -e "[\u001b[31m!\u001b[0m] \u001b[1;31m$id ($severity)\u001b[0m: $title"
                echo -e " => File: \u001b[1;33m$target\u001b[0m (Line: $line)"
                echo -e " => Detected: $msg\n"
            done
        done
    done
}

echo "========================================"
echo "IaC / Misconfigurations Report"
echo "========================================"
show_iac_reports
