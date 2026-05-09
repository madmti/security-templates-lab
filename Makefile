.PHONY: help secret-scanning


help:
	@echo "hola"

secret-scanning:
	@cd ./secret-scanning && ./entry-point.sh
