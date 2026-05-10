# security-templates-lab

Laboratorio integral para el escaneo de vulnerabilidades utilizando múltiples capas de seguridad (SAST, SCA, Secret Scanning, IaC y DAST). Diseñado para centralizar reportes de herramientas líderes en la industria mediante scripts automatizados en Bash.

## 📂 Estructura del Proyecto

* `secret-scanning/`: Detección de credenciales expuestas con **Gitleaks**.
* `sast/`: Análisis estático de código fuente con **Semgrep**.
* `sca/`: Escaneo de dependencias vulnerables con **OSV-Scanner**.
* `iac/`: Análisis de configuración de infraestructura con **Trivy**.
* `dast-nuclei/`: Escaneo dinámico de aplicaciones en ejecución con **Nuclei**.
* `test-repos/`: Submódulos Git con aplicaciones vulnerables (Juice Shop, PyGoat, etc.) para pruebas.
* `reports/`: Directorio centralizado donde se generan los resultados en formato JSON.

## Quisck Start

El laboratorio utiliza un `Makefile` para orquestar los escaneos de forma sencilla.

### 1. Preparar el entorno
Asegúrate de inicializar los submódulos para tener los repositorios de prueba:
```bash
git submodule update --init --recursive
```

### 2. Ejecutar Escaneos

Puedes ejecutar cada capa de forma independiente:

```bash
make sast-scan           # Ejecuta Semgrep
make sca-scan            # Ejecuta OSV-Scanner
make secrets-scan        # Ejecuta Gitleaks (git/nogit)
make iac-scan            # Ejecuta Trivy (config)
make dast-nuclei-scan    # Ejecuta Nuclei (vía targets.txt y templates.txt)
```

### 3. Generar Reportes

Una vez realizados los escaneos, consolida la información visualmente:

```bash
make report              # Genera el reporte unificado de todas las capas excepto DAST
```

