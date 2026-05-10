#!/usr/bin/env bash

GREEN='\033[0;32m'
NC='\033[0m'
REPORTS_DIR="../reports"
mkdir -p "$REPORTS_DIR"

TEMPLATES_FILE="templates.txt"
TARGETS_FILE="targets.txt"
REPORT_NAME="$REPORTS_DIR/full-dast-$(date +%Y%m%d_%H%M%S).json"

TEMPLATE_ARGS=()
while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^# ]] && continue

    FULL_PATH="${HOME}/nuclei-templates/${line}"
    TEMPLATE_ARGS+=("-t" "$FULL_PATH")
done < "$TEMPLATES_FILE"

echo "========================================"
echo "DAST Scanning (nuclei)"
echo "========================================"
echo -e "Targeting: $(wc -l < "$TARGETS_FILE") apps"
echo -e "Using: ${#TEMPLATE_ARGS[@]} template directories"

# Ejecutamos Nuclei pasando el array de argumentos expandidos
nuclei -list "$TARGETS_FILE" \
       "${TEMPLATE_ARGS[@]}" \
       -headless \
       -dast \
       -json-export "$REPORT_NAME" \
       -severity low,medium,high,critical

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Escaneo finalizado correctamente.${NC}"
else
    echo -e "❌ Hubo errores en el escaneo."
fi
