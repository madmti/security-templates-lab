.PHONY: help secret-scanning secret-scanning-report sast-scan sast-report iac-scan iac-report sca-scan sca-report dast-nuclei-scan dast-nuclei-report clean

help:
	@echo "Usage: make [target]"
	@echo "Targets:"
	@echo "  clean                  Remove all generated files"
	@echo "  scan                   Run all scans (SAST and Secret Scanning)"
	@echo "  report                 Show all reports (SAST and Secret Scanning)"
	@echo "  sast-scan              Run SAST scan"
	@echo "  sast-report            Shows SAST report"
	@echo "  secret-scanning        Run Secret Scanning"
	@echo "  secret-scanning-report Shows Secret Scanning report"
	@echo "  iac-scan               Run IaC scan"
	@echo "  iac-report             Shows IaC report"
	@echo "  sca-scan               Run SCA scan"
	@echo "  sca-report             Shows SCA report"
	@echo "  dast-nuclei-scan       Run DAST Nuclei scan"
	@echo "  dast-nuclei-report     Shows DAST Nuclei report"

scan: secret-scanning sast-scan iac-scan sca-scan

report: secret-scanning-report sast-report iac-report sca-report

dast-nuclei-scan:
	@cd ./dast-nuclei && ./scan.sh

dast-nuclei-report:
	@cd ./dast-nuclei && ./report.sh

iac-scan:
	@cd ./iac && ./scan.sh

iac-report:
	@cd ./iac && ./report.sh

sast-scan:
	@cd ./sast && ./scan.sh

sast-report:
	@cd ./sast && ./report.sh

sca-scan:
	@cd ./sca && ./scan.sh

sca-report:
	@cd ./sca && ./report.sh

secret-scanning:
	@cd ./secret-scanning && ./scan.sh

secret-scanning-report:
	@cd ./secret-scanning && ./report.sh

clean:
	@rm -rf ./reports/*
