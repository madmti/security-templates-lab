.PHONY: help secret-scanning secret-scanning-report sast-scan sast-report

help:
	@echo "Usage: make [target]"
	@echo "Targets:"
	@echo "  scan                   Run all scans (SAST and Secret Scanning)"
	@echo "  report                 Show all reports (SAST and Secret Scanning)"
	@echo "  sast-scan              Run SAST scan"
	@echo "  sast-report            Shows SAST report"
	@echo "  secret-scanning        Run Secret Scanning"
	@echo "  secret-scanning-report Shows Secret Scanning report"

scan: secret-scanning sast-scan iac-scan sca-scan

report: secret-scanning-report sast-report iac-report sca-report

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
