.PHONY: all update rebuild clean generate-keys help

# Configuration
SHELL := /bin/bash

all: help

help:
	@echo "Pinky APT Repository - Système de gestion"
	@echo ""
	@echo "Commandes disponibles:"
	@echo "  make update         - Met à jour les fichiers du dépôt APT"
	@echo "  make generate-keys  - Génère une nouvelle paire de clés GPG"
	@echo "  make rebuild        - Reconstruit entièrement le dépôt"
	@echo "  make clean          - Nettoie les fichiers générés"
	@echo "  make help           - Affiche cette aide"

update:
	@echo "🔄 Mise à jour du dépôt APT..."
	@bash scripts/generate.sh
	@echo "✅ Mise à jour terminée."

generate-keys:
	@echo "🔑 Génération des clés GPG..."
	@bash scripts/generate-keys.sh
	@echo "✅ Génération des clés terminée."

rebuild: clean update
	@echo "🏗️ Reconstruction du dépôt terminée."

clean:
	@echo "🧹 Nettoyage des fichiers générés..."
	@rm -rf dists/*/*/binary-*/Packages*
	@rm -f dists/*/Release*
	@rm -f dists/*/InRelease
	@echo "✅ Nettoyage terminé."
