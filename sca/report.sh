#!/usr/bin/env bash

YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

REPORTS_DIR="../reports"

show_sca_reports() {
    echo -e "${YELLOW}--- CATEGORÍA: SCA (Dependencias) ---${NC}"

    files=("$REPORTS_DIR"/*.sca.json)

    if [ ! -e "${files[0]}" ]; then
        echo -e "No hay reportes de SCA encontrados.\n"
        return
    fi

    for report in "${files[@]}"; do
        repo_name=$(basename "$report" .sca.json)
        echo -e "Repo: $repo_name"

        jq -c '.results[]' "$report" | while read -r result; do
            source_file=$(echo "$result" | jq -r '.source.path' | sed "s|.*$repo_name/||")

            echo "$result" | jq -c '.packages[]' | while read -r pkg; do
                pkg_name=$(echo "$pkg" | jq -r '.package.name')
                pkg_version=$(echo "$pkg" | jq -r '.package.version')

                echo "$pkg" | jq -c '.vulnerabilities[]' | while read -r vuln; do
                    vuln_id=$(echo "$vuln" | jq -r '.id')
                    summary=$(echo "$vuln" | jq -r '.summary')

                    echo -e "[\u001b[31m!\u001b[0m] \u001b[1;31m$vuln_id\u001b[0m en \u001b[1;33m$pkg_name@$pkg_version\u001b[0m"
                    echo -e " => Source: \u001b[34m$source_file\u001b[0m"
                    echo -e " => Resumen: $summary\n"
                done
            done
        done
    done
}

if ! command -v jq > /dev/null 2>&1; then
    echo "Error: 'jq' es necesario para procesar los reportes."
    exit 1
fi

echo "========================================"
echo "SCA Scanning Reports (osv-scanner)"
echo "========================================"

show_sca_reports
